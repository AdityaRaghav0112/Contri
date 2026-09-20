import 'package:flutter/foundation.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/profile.dart';
import '../services/cache_service.dart';
import '../services/supabase_service.dart';

class GroupRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final CacheService _cacheService = CacheService();

  static const String _groupEmbeddedSelect = '''
    *,
    group_members (
      *,
      profiles:user_id (*)
    ),
    expenses (
      *,
      expense_participants (*)
    ),
    settlements (*)
  ''';

  /// Fetches all groups with computed total spend, member lists, and user net balance
  /// in a SINGLE embedded query with Cache-First support.
  Future<List<Group>> getGroups({bool forceRefresh = false}) async {
    // 1. Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cached = _cacheService.get<List<Group>>('groups_list');
      if (cached != null) {
        return cached;
      }
    }

    try {
      final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

      // 2. Fetch groups with embedded members, expenses, and settlements in 1 request
      final groupsRes = await _supabaseService.client
          .from('groups')
          .select(_groupEmbeddedSelect)
          .order('created_at', ascending: false);

      final List<Group> groups = [];
      for (final gJson in groupsRes as List) {
        final parsed = _parseGroupFromJson(gJson as Map<String, dynamic>, currentUserId);
        groups.add(parsed);
        // Cache individual group as well
        _cacheService.set('group_details_${parsed.id}', parsed);
      }

      // Update groups list in cache
      _cacheService.set('groups_list', groups);

      return groups;
    } catch (e) {
      debugPrint('Error getting groups with embedded query: $e. Falling back to sequential queries.');
      final fallbackGroups = await _getGroupsSequentialFallback();
      _cacheService.set('groups_list', fallbackGroups);
      return fallbackGroups;
    }
  }

  /// Parses a group JSON map containing embedded group_members, expenses, and settlements.
  Group _parseGroupFromJson(Map<String, dynamic> gJson, String currentUserId) {
    // 1. Parse members
    final membersJson = (gJson['group_members'] as List? ?? []);
    final List<GroupMember> members = membersJson
        .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
        .toList();

    // 2. Parse expenses & compute spend + balance
    final expensesJson = (gJson['expenses'] as List? ?? []);
    double totalSpent = 0.0;
    double userNetBalance = 0.0;

    for (final exp in expensesJson) {
      final amount = (exp['amount'] is num)
          ? (exp['amount'] as num).toDouble()
          : double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
      totalSpent += amount;

      final paidBy = exp['paid_by'] as String?;
      final participants = (exp['expense_participants'] as List? ?? []);

      double userShare = 0.0;
      for (final p in participants) {
        if (p['user_id'] == currentUserId) {
          userShare = (p['share_amount'] is num)
              ? (p['share_amount'] as num).toDouble()
              : double.tryParse(p['share_amount']?.toString() ?? '0') ?? 0.0;
        }
      }

      if (paidBy == currentUserId) {
        // User paid total, user is owed (amount - user's own share)
        userNetBalance += (amount - userShare);
      } else {
        // Someone else paid, user owes userShare
        userNetBalance -= userShare;
      }
    }

    // 3. Parse settlements & adjust userNetBalance
    final settlementsJson = (gJson['settlements'] as List? ?? []);
    for (final st in settlementsJson) {
      final stAmount = (st['amount'] is num)
          ? (st['amount'] as num).toDouble()
          : double.tryParse(st['amount']?.toString() ?? '0') ?? 0.0;

      if (st['from_user'] == currentUserId) {
        // User paid back someone -> increases user's balance towards 0
        userNetBalance += stAmount;
      } else if (st['to_user'] == currentUserId) {
        // Someone paid back user -> decreases what is owed to user
        userNetBalance -= stAmount;
      }
    }

    final bool settled = expensesJson.isNotEmpty && userNetBalance.abs() < 0.01;

    return Group.fromJson(
      gJson,
      members: members,
      totalSpent: totalSpent,
      userNetBalance: userNetBalance,
      settled: settled,
    );
  }

  /// Sequential fallback in case embedded query fails
  Future<List<Group>> _getGroupsSequentialFallback() async {
    try {
      final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

      final groupsRes = await _supabaseService.client
          .from('groups')
          .select()
          .order('created_at', ascending: false);

      final List<Group> groups = [];

      for (final gJson in groupsRes) {
        final groupId = gJson['id'] as String;

        List<GroupMember> members = [];
        try {
          final membersRes = await _supabaseService.client
              .from('group_members')
              .select('*, profiles:user_id(*)')
              .eq('group_id', groupId);

          members = (membersRes as List)
              .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
              .toList();
        } catch (e) {
          final membersRes = await _supabaseService.client
              .from('group_members')
              .select()
              .eq('group_id', groupId);

          for (final mJson in membersRes) {
            final pRes = await _supabaseService.client
                .from('profiles')
                .select()
                .eq('id', mJson['user_id'])
                .maybeSingle();

            final map = Map<String, dynamic>.from(mJson);
            if (pRes != null) map['profiles'] = pRes;
            members.add(GroupMember.fromJson(map));
          }
        }

        final expensesRes = await _supabaseService.client
            .from('expenses')
            .select('*, expense_participants(*)')
            .eq('group_id', groupId);

        double totalSpent = 0.0;
        double userNetBalance = 0.0;

        for (final exp in expensesRes) {
          final amount = (exp['amount'] is num)
              ? (exp['amount'] as num).toDouble()
              : double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
          totalSpent += amount;

          final paidBy = exp['paid_by'] as String;
          final participants = (exp['expense_participants'] as List? ?? []);

          double userShare = 0.0;
          for (final p in participants) {
            if (p['user_id'] == currentUserId) {
              userShare = (p['share_amount'] is num)
                  ? (p['share_amount'] as num).toDouble()
                  : double.tryParse(p['share_amount']?.toString() ?? '0') ?? 0.0;
            }
          }

          if (paidBy == currentUserId) {
            userNetBalance += (amount - userShare);
          } else {
            userNetBalance -= userShare;
          }
        }

        final settlementsRes = await _supabaseService.client
            .from('settlements')
            .select()
            .eq('group_id', groupId);

        for (final st in settlementsRes) {
          final stAmount = (st['amount'] is num)
              ? (st['amount'] as num).toDouble()
              : double.tryParse(st['amount']?.toString() ?? '0') ?? 0.0;

          if (st['from_user'] == currentUserId) {
            userNetBalance += stAmount;
          } else if (st['to_user'] == currentUserId) {
            userNetBalance -= stAmount;
          }
        }

        final bool settled = expensesRes.isNotEmpty && userNetBalance.abs() < 0.01;

        groups.add(
          Group.fromJson(
            gJson,
            members: members,
            totalSpent: totalSpent,
            userNetBalance: userNetBalance,
            settled: settled,
          ),
        );
      }

      return groups;
    } catch (e) {
      debugPrint('Error in sequential fallback: $e');
      return [];
    }
  }

  /// Fetches a single group with full details using single-query embedding with Cache-First support
  Future<Group?> getGroupById(String groupId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheService.get<Group>('group_details_$groupId');
      if (cached != null) return cached;
    }

    try {
      final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

      final res = await _supabaseService.client
          .from('groups')
          .select(_groupEmbeddedSelect)
          .eq('id', groupId)
          .maybeSingle();

      if (res != null) {
        final parsed = _parseGroupFromJson(res, currentUserId);
        _cacheService.set('group_details_$groupId', parsed);
        return parsed;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting group by id with embedding: $e');
      final all = await getGroups(forceRefresh: forceRefresh);
      try {
        final match = all.firstWhere((g) => g.id == groupId);
        _cacheService.set('group_details_$groupId', match);
        return match;
      } catch (_) {
        return null;
      }
    }
  }

  /// Creates a new group and joins creator + selected members
  Future<Group> createGroup({
    required String name,
    required String icon,
    String currency = 'INR',
    List<String> memberUserIds = const [],
  }) async {
    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    final groupData = {
      'name': name,
      'icon': icon,
      'currency': currency,
      'created_by': currentUserId,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabaseService.client
        .from('groups')
        .insert(groupData)
        .select()
        .single();

    final String newGroupId = res['id'] as String;

    // Add creator to group_members
    final Set<String> allMemberIds = {currentUserId, ...memberUserIds};
    final List<Map<String, dynamic>> membersList = allMemberIds.map((uId) {
      return {
        'group_id': newGroupId,
        'user_id': uId,
        'joined_at': DateTime.now().toIso8601String(),
      };
    }).toList();

    await _supabaseService.client.from('group_members').insert(membersList);

    // Invalidate group cache so next getGroups will fetch freshly created group
    _cacheService.invalidateGroups();

    return Group.fromJson(res);
  }

  /// Fetches all available profiles in the app to add as members
  Future<List<Profile>> getAllProfiles() async {
    try {
      final res = await _supabaseService.client
          .from('profiles')
          .select()
          .order('name');

      return (res as List).map((j) => Profile.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
      return [];
    }
  }
}
