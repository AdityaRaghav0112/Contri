class _CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;

  _CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// In-memory cache manager supporting TTL and targeted cache invalidation.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, _CacheEntry<dynamic>> _cache = {};

  /// Default cache TTL is 5 minutes
  static const Duration defaultTtl = Duration(minutes: 5);

  /// Retrieves cached data if present and unexpired, otherwise returns null.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Stores data in cache with a specified or default TTL.
  void set<T>(String key, T data, {Duration ttl = defaultTtl}) {
    _cache[key] = _CacheEntry<T>(
      data: data,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
  }

  /// Removes a specific cache key.
  void remove(String key) {
    _cache.remove(key);
  }

  /// Removes all cache keys matching a prefix.
  void removeWhere(bool Function(String key) predicate) {
    _cache.removeWhere((key, _) => predicate(key));
  }

  /// Invalidates group-related caches (all groups list, specific group, group expenses, activities).
  void invalidateGroup(String groupId) {
    _cache.remove('groups_list');
    _cache.remove('group_details_$groupId');
    _cache.remove('group_expenses_$groupId');
    _cache.remove('activity_feed');
    _cache.remove('friends_list');
    removeWhere((key) => key.startsWith('expenses_group_${groupId}_'));
  }

  /// Invalidates all groups and activities.
  void invalidateGroups() {
    _cache.remove('groups_list');
    _cache.remove('activity_feed');
    removeWhere((key) => key.startsWith('group_'));
  }

  /// Invalidates friend list.
  void invalidateFriends() {
    _cache.remove('friends_list');
  }

  /// Invalidates activity feed and recent expenses.
  void invalidateActivities() {
    _cache.remove('activity_feed');
    removeWhere((key) => key.startsWith('recent_expenses_'));
  }

  /// Clears the entire in-memory cache.
  void clearAll() {
    _cache.clear();
  }
}
