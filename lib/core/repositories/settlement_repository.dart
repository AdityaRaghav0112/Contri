import 'package:flutter/foundation.dart';
import '../models/settlement.dart';
import '../services/cache_service.dart';
import '../services/supabase_service.dart';

class SettlementRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final CacheService _cacheService = CacheService();

  /// Records a settlement between two users in a group
  Future<Settlement> createSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    final insertData = {
      'group_id': groupId,
      'from_user': fromUserId,
      'to_user': toUserId,
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabaseService.client
        .from('settlements')
        .insert(insertData)
        .select()
        .single();

    // Invalidate affected caches immediately
    _cacheService.invalidateGroup(groupId);
    _cacheService.invalidateFriends();
    _cacheService.invalidateActivities();
    _cacheService.remove('settlements_group_$groupId');
    _cacheService.remove('all_settlements');

    return Settlement.fromJson(res);
  }

  /// Fetches all settlements for a specific group with caching
  Future<List<Settlement>> getSettlementsByGroup(String groupId, {bool forceRefresh = false}) async {
    final cacheKey = 'settlements_group_$groupId';
    if (!forceRefresh) {
      final cached = _cacheService.get<List<Settlement>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final res = await _supabaseService.client
          .from('settlements')
          .select('*, from_profile:profiles!from_user(*), to_profile:profiles!to_user(*), groups(name)')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      final results = (res as List).map((json) => Settlement.fromJson(json as Map<String, dynamic>)).toList();
      _cacheService.set(cacheKey, results);
      return results;
    } catch (e) {
      debugPrint('Error fetching settlements with joins: $e. Falling back to plain select.');
      try {
        final res = await _supabaseService.client
            .from('settlements')
            .select('*, groups(name)')
            .eq('group_id', groupId)
            .order('created_at', ascending: false);

        final List<Settlement> results = [];
        for (final item in res) {
          final fromP = await _supabaseService.client.from('profiles').select().eq('id', item['from_user']).maybeSingle();
          final toP = await _supabaseService.client.from('profiles').select().eq('id', item['to_user']).maybeSingle();

          final map = Map<String, dynamic>.from(item);
          if (fromP != null) map['from_profile'] = fromP;
          if (toP != null) map['to_profile'] = toP;

          results.add(Settlement.fromJson(map));
        }
        _cacheService.set(cacheKey, results);
        return results;
      } catch (err) {
        debugPrint('Fallback settlements query failed: $err');
        return [];
      }
    }
  }

  /// Fetches all settlements involving the user across all groups with caching
  Future<List<Settlement>> getAllSettlements({bool forceRefresh = false}) async {
    const cacheKey = 'all_settlements';
    if (!forceRefresh) {
      final cached = _cacheService.get<List<Settlement>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final res = await _supabaseService.client
          .from('settlements')
          .select('*, from_profile:profiles!from_user(*), to_profile:profiles!to_user(*), groups(name)')
          .order('created_at', ascending: false);

      final results = (res as List).map((json) => Settlement.fromJson(json as Map<String, dynamic>)).toList();
      _cacheService.set(cacheKey, results);
      return results;
    } catch (e) {
      debugPrint('Error fetching all settlements with joins: $e');
      try {
        final res = await _supabaseService.client
            .from('settlements')
            .select('*, groups(name)')
            .order('created_at', ascending: false);

        final List<Settlement> results = [];
        for (final item in res) {
          final fromP = await _supabaseService.client.from('profiles').select().eq('id', item['from_user']).maybeSingle();
          final toP = await _supabaseService.client.from('profiles').select().eq('id', item['to_user']).maybeSingle();

          final map = Map<String, dynamic>.from(item);
          if (fromP != null) map['from_profile'] = fromP;
          if (toP != null) map['to_profile'] = toP;

          results.add(Settlement.fromJson(map));
        }
        _cacheService.set(cacheKey, results);
        return results;
      } catch (err) {
        debugPrint('Fallback all settlements query failed: $err');
        return [];
      }
    }
  }
}
