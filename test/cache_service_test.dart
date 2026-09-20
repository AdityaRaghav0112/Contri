import 'package:flutter_test/flutter_test.dart';
import 'package:contri/core/services/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
      cacheService.clearAll();
    });

    test('Sets and gets cached value before TTL expires', () {
      cacheService.set('test_key', 'test_value');
      final value = cacheService.get<String>('test_key');
      expect(value, equals('test_value'));
    });

    test('Returns null when key is missing or expired', () async {
      expect(cacheService.get<String>('non_existent'), isNull);

      cacheService.set('short_lived', 'value', ttl: const Duration(milliseconds: 20));
      expect(cacheService.get<String>('short_lived'), equals('value'));

      await Future.delayed(const Duration(milliseconds: 30));
      expect(cacheService.get<String>('short_lived'), isNull);
    });

    test('invalidateGroup clears group-specific and related caches', () {
      cacheService.set('groups_list', ['group1', 'group2']);
      cacheService.set('group_details_g1', 'details1');
      cacheService.set('expenses_group_g1_0_20', ['exp1']);
      cacheService.set('activity_feed', ['act1']);
      cacheService.set('friends_list', ['f1']);

      // Unrelated group
      cacheService.set('group_details_g2', 'details2');

      cacheService.invalidateGroup('g1');

      expect(cacheService.get<List<String>>('groups_list'), isNull);
      expect(cacheService.get<String>('group_details_g1'), isNull);
      expect(cacheService.get<List<String>>('expenses_group_g1_0_20'), isNull);
      expect(cacheService.get<List<String>>('activity_feed'), isNull);
      expect(cacheService.get<List<String>>('friends_list'), isNull);

      // g2 details should remain
      expect(cacheService.get<String>('group_details_g2'), equals('details2'));
    });

    test('invalidateGroups clears all groups and activities', () {
      cacheService.set('groups_list', ['group1']);
      cacheService.set('group_details_g1', 'details1');
      cacheService.set('activity_feed', ['act1']);
      cacheService.set('friends_list', ['f1']);

      cacheService.invalidateGroups();

      expect(cacheService.get<List<String>>('groups_list'), isNull);
      expect(cacheService.get<String>('group_details_g1'), isNull);
      expect(cacheService.get<List<String>>('activity_feed'), isNull);
      expect(cacheService.get<List<String>>('friends_list'), equals(['f1']));
    });

    test('clearAll wipes everything', () {
      cacheService.set('k1', 'v1');
      cacheService.set('k2', 'v2');
      cacheService.clearAll();

      expect(cacheService.get<String>('k1'), isNull);
      expect(cacheService.get<String>('k2'), isNull);
    });
  });
}
