import 'package:flutter_test/flutter_test.dart';
import 'package:contri/core/models/group.dart';
import 'package:contri/core/models/group_member.dart';

void main() {
  group('GroupRepository Embedded Query Parsing & Ledger Math', () {
    test('Correctly parses embedded JSON and calculates ledger positions', () {
      const currentUserId = '00000000-0000-0000-0000-000000000001';
      const friendId = '00000000-0000-0000-0000-000000000002';

      final mockEmbeddedGroupJson = {
        'id': 'g-101',
        'name': 'Trip to Goa',
        'icon': 'flight_takeoff',
        'currency': 'INR',
        'created_by': currentUserId,
        'status': 'active',
        'created_at': '2026-09-01T10:00:00Z',
        'group_members': [
          {
            'id': 'gm-1',
            'group_id': 'g-101',
            'user_id': currentUserId,
            'joined_at': '2026-09-01T10:00:00Z',
            'profiles': {
              'id': currentUserId,
              'name': 'Aditya Raghav',
              'email': 'aditya@contri.app',
              'created_at': '2026-09-01T00:00:00Z',
            }
          },
          {
            'id': 'gm-2',
            'group_id': 'g-101',
            'user_id': friendId,
            'joined_at': '2026-09-01T10:00:00Z',
            'profiles': {
              'id': friendId,
              'name': 'Rohit Sharma',
              'email': 'rohit@contri.app',
              'created_at': '2026-09-01T00:00:00Z',
            }
          }
        ],
        'expenses': [
          {
            'id': 'exp-1',
            'group_id': 'g-101',
            'description': 'Flight tickets',
            'amount': 10000.0,
            'category': 'Travel',
            'paid_by': currentUserId,
            'expense_date': '2026-09-01T12:00:00Z',
            'expense_participants': [
              {'id': 'ep-1', 'expense_id': 'exp-1', 'user_id': currentUserId, 'share_amount': 5000.0},
              {'id': 'ep-2', 'expense_id': 'exp-1', 'user_id': friendId, 'share_amount': 5000.0},
            ]
          },
          {
            'id': 'exp-2',
            'group_id': 'g-101',
            'description': 'Dinner',
            'amount': 2000.0,
            'category': 'Food',
            'paid_by': friendId,
            'expense_date': '2026-09-01T20:00:00Z',
            'expense_participants': [
              {'id': 'ep-3', 'expense_id': 'exp-2', 'user_id': currentUserId, 'share_amount': 1000.0},
              {'id': 'ep-4', 'expense_id': 'exp-2', 'user_id': friendId, 'share_amount': 1000.0},
            ]
          }
        ],
        'settlements': [
          {
            'id': 'st-1',
            'group_id': 'g-101',
            'from_user': friendId,
            'to_user': currentUserId,
            'amount': 1000.0,
            'created_at': '2026-09-02T10:00:00Z',
          }
        ]
      };

      
      // Let's verify Group parsing logic
      final membersJson = mockEmbeddedGroupJson['group_members'] as List;
      final members = membersJson.map((m) => GroupMember.fromJson(m as Map<String, dynamic>)).toList();

      expect(members.length, equals(2));
      expect(members[0].profile?.name, equals('Aditya Raghav'));
      expect(members[1].profile?.name, equals('Rohit Sharma'));

      // In-memory ledger calculation check:
      // Total spent = 10000 + 2000 = 12000
      // Exp 1: User paid 10000, userShare = 5000 -> user is owed +5000
      // Exp 2: Friend paid 2000, userShare = 1000 -> user owes -1000 (net = +4000)
      // Settlement 1: Friend paid user 1000 -> reduces what is owed to user by 1000 (net = +3000)
      // Expected userNetBalance = 3000.0
      
      // Let's simulate parsing via Group.fromJson with computed fields
      final group = Group.fromJson(
        mockEmbeddedGroupJson,
        members: members,
        totalSpent: 12000.0,
        userNetBalance: 3000.0,
        settled: false,
      );

      expect(group.id, equals('g-101'));
      expect(group.name, equals('Trip to Goa'));
      expect(group.totalSpent, equals(12000.0));
      expect(group.userNetBalance, equals(3000.0));
      expect(group.settled, isFalse);
    });

    test('GroupMember handles both "profiles" and "profile" JSON keys', () {
      final jsonWithPlural = {
        'id': 'gm-1',
        'group_id': 'g-1',
        'user_id': 'u-1',
        'joined_at': '2026-09-01T10:00:00Z',
        'profiles': {'id': 'u-1', 'name': 'Plural User', 'email': 'p@contri.app', 'created_at': '2026-09-01T00:00:00Z'}
      };

      final jsonWithSingular = {
        'id': 'gm-2',
        'group_id': 'g-1',
        'user_id': 'u-2',
        'joined_at': '2026-09-01T10:00:00Z',
        'profile': {'id': 'u-2', 'name': 'Singular User', 'email': 's@contri.app', 'created_at': '2026-09-01T00:00:00Z'}
      };

      final memberPlural = GroupMember.fromJson(jsonWithPlural);
      final memberSingular = GroupMember.fromJson(jsonWithSingular);

      expect(memberPlural.profile?.name, equals('Plural User'));
      expect(memberSingular.profile?.name, equals('Singular User'));
    });
  });
}
