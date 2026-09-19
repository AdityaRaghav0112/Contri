import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';

class FriendBalanceItem {
  final Profile profile;
  final double balance;
  final bool isOwed;
  final bool isSettled;
  final List<String> sharedGroups;
  final String recentActivity;
  final Color avatarColor;

  FriendBalanceItem({
    required this.profile,
    required this.balance,
    required this.isOwed,
    required this.isSettled,
    required this.sharedGroups,
    required this.recentActivity,
    required this.avatarColor,
  });

  String get name => profile.name;
  String get email => profile.email;
  String get avatar => profile.initials;
}

class FriendRepository {
  final SupabaseService _supabaseService = SupabaseService();

  static const List<Color> _avatarColors = [
    Color(0xFFBFA77D),
    Color(0xFF879B8C),
    Color(0xFF5A7B8C),
    Color(0xFF69716E),
    Color(0xFF9E829C),
    Color(0xFF7A8B7B),
    Color(0xFF456179),
  ];

  /// Fetches all friends with pairwise calculated balances and shared group names
  Future<List<FriendBalanceItem>> getFriends() async {
    try {
      final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

      // 1. Fetch all profiles except current user
      final profilesRes = await _supabaseService.client
          .from('profiles')
          .select()
          .neq('id', currentUserId);

      final List<Profile> otherProfiles = (profilesRes as List)
          .map((j) => Profile.fromJson(j as Map<String, dynamic>))
          .toList();

      // 2. Fetch all groups and group_members to map shared groups
      final groupMembersRes = await _supabaseService.client
          .from('group_members')
          .select('group_id, user_id, groups(name)');

      final Map<String, Set<String>> userSharedGroups = {};
      final Set<String> currentUserGroupIds = {};

      for (final gm in groupMembersRes) {
        final uId = gm['user_id'] as String;
        final gId = gm['group_id'] as String;
        if (uId == currentUserId) {
          currentUserGroupIds.add(gId);
        }
      }

      for (final gm in groupMembersRes) {
        final uId = gm['user_id'] as String;
        final gId = gm['group_id'] as String;
        final gName = (gm['groups'] != null && gm['groups']['name'] != null)
            ? gm['groups']['name'] as String
            : 'Group';

        if (uId != currentUserId && currentUserGroupIds.contains(gId)) {
          userSharedGroups.putIfAbsent(uId, () => {}).add(gName);
        }
      }

      // 3. Fetch all expenses and participants
      final expensesRes = await _supabaseService.client
          .from('expenses')
          .select('id, group_id, description, paid_by, expense_date, expense_participants(user_id, share_amount)');

      // 4. Fetch all settlements
      final settlementsRes = await _supabaseService.client
          .from('settlements')
          .select('from_user, to_user, amount, group_id');

      final List<FriendBalanceItem> friends = [];
      int colorIndex = 0;

      for (final friendProfile in otherProfiles) {
        final friendId = friendProfile.id;
        double netBalance = 0.0;
        String latestDesc = 'No recent activity';
        DateTime? latestDate;

        // Calculate expense pairwise interactions
        for (final exp in expensesRes) {
          final paidBy = exp['paid_by'] as String;
          final desc = exp['description'] as String? ?? 'Expense';
          final expDate = exp['expense_date'] != null
              ? DateTime.parse(exp['expense_date'] as String)
              : DateTime.now();

          final participants = exp['expense_participants'] as List? ?? [];

          if (paidBy == currentUserId) {
            // Did friend participate?
            for (final p in participants) {
              if (p['user_id'] == friendId) {
                final share = (p['share_amount'] is num)
                    ? (p['share_amount'] as num).toDouble()
                    : double.tryParse(p['share_amount']?.toString() ?? '0') ?? 0.0;
                netBalance += share; // Friend owes user
                if (latestDate == null || expDate.isAfter(latestDate)) {
                  latestDate = expDate;
                  latestDesc = 'Owes you for $desc';
                }
              }
            }
          } else if (paidBy == friendId) {
            // Did current user participate?
            for (final p in participants) {
              if (p['user_id'] == currentUserId) {
                final share = (p['share_amount'] is num)
                    ? (p['share_amount'] as num).toDouble()
                    : double.tryParse(p['share_amount']?.toString() ?? '0') ?? 0.0;
                netBalance -= share; // User owes friend
                if (latestDate == null || expDate.isAfter(latestDate)) {
                  latestDate = expDate;
                  latestDesc = 'You owe for $desc';
                }
              }
            }
          }
        }

        // Calculate settlement interactions
        for (final st in settlementsRes) {
          final fromU = st['from_user'] as String;
          final toU = st['to_user'] as String;
          final amt = (st['amount'] is num)
              ? (st['amount'] as num).toDouble()
              : double.tryParse(st['amount']?.toString() ?? '0') ?? 0.0;

          if (fromU == friendId && toU == currentUserId) {
            // Friend paid user back
            netBalance -= amt;
          } else if (fromU == currentUserId && toU == friendId) {
            // User paid friend back
            netBalance += amt;
          }
        }

        final bool isSettled = netBalance.abs() < 0.01;
        final bool isOwed = netBalance >= 0;

        if (isSettled && latestDate != null) {
          latestDesc = 'Settled up';
        }

        final sharedGroupList = userSharedGroups[friendId]?.toList() ?? ['General'];
        if (sharedGroupList.isEmpty) sharedGroupList.add('General');

        friends.add(
          FriendBalanceItem(
            profile: friendProfile,
            balance: netBalance.abs(),
            isOwed: isOwed,
            isSettled: isSettled,
            sharedGroups: sharedGroupList,
            recentActivity: latestDesc,
            avatarColor: _avatarColors[colorIndex % _avatarColors.length],
          ),
        );
        colorIndex++;
      }

      return friends;
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }

  /// Adds a new friend profile and joins them into user's first active group
  Future<Profile> addFriend({required String name, required String email}) async {
    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    final newProfileData = {
      'name': name,
      'email': email.isNotEmpty ? email : '${name.toLowerCase().replaceAll(' ', '.')}@contri.app',
      'created_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabaseService.client
        .from('profiles')
        .insert(newProfileData)
        .select()
        .single();

    final newProfile = Profile.fromJson(res);

    // Join to user's first group if available
    try {
      final userGroups = await _supabaseService.client
          .from('group_members')
          .select('group_id')
          .eq('user_id', currentUserId)
          .limit(1);

      if (userGroups.isNotEmpty) {
        final gId = userGroups.first['group_id'] as String;
        await _supabaseService.client.from('group_members').insert({
          'group_id': gId,
          'user_id': newProfile.id,
          'joined_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Note on joining group for new friend: $e');
    }

    return newProfile;
  }

  /// Settles the outstanding balance with a friend
  Future<void> settleWithFriend(FriendBalanceItem friend) async {
    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';
    if (friend.balance <= 0) return;

    // Find first shared group
    String? sharedGroupId;
    final groupsRes = await _supabaseService.client
        .from('group_members')
        .select('group_id')
        .eq('user_id', friend.profile.id);

    if (groupsRes.isNotEmpty) {
      sharedGroupId = groupsRes.first['group_id'] as String;
    } else {
      final anyGroup = await _supabaseService.client.from('groups').select('id').limit(1);
      if (anyGroup.isNotEmpty) {
        sharedGroupId = anyGroup.first['id'] as String;
      }
    }

    if (sharedGroupId == null) return;

    if (friend.isOwed) {
      // Friend owes user -> Friend pays User
      await _supabaseService.client.from('settlements').insert({
        'group_id': sharedGroupId,
        'from_user': friend.profile.id,
        'to_user': currentUserId,
        'amount': friend.balance,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      // User owes friend -> User pays Friend
      await _supabaseService.client.from('settlements').insert({
        'group_id': sharedGroupId,
        'from_user': currentUserId,
        'to_user': friend.profile.id,
        'amount': friend.balance,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
