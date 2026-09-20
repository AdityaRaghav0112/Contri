import 'profile.dart';

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final Profile? profile;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.joinedAt,
    this.leftAt,
    this.profile,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      leftAt: json['left_at'] != null
          ? DateTime.parse(json['left_at'] as String)
          : null,
      profile: (json['profiles'] != null && json['profiles'] is Map<String, dynamic>)
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : (json['profile'] != null && json['profile'] is Map<String, dynamic>)
              ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      if (leftAt != null) 'left_at': leftAt!.toIso8601String(),
    };
  }
}
