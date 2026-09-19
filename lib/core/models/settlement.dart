import 'profile.dart';

class Settlement {
  final String id;
  final String groupId;
  final String fromUser;
  final String toUser;
  final double amount;
  final DateTime createdAt;
  final Profile? fromProfile;
  final Profile? toProfile;
  final String? groupName;

  Settlement({
    required this.id,
    required this.groupId,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.createdAt,
    this.fromProfile,
    this.toProfile,
    this.groupName,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    Profile? fromP;
    if (json['from_profile'] != null && json['from_profile'] is Map<String, dynamic>) {
      fromP = Profile.fromJson(json['from_profile'] as Map<String, dynamic>);
    }

    Profile? toP;
    if (json['to_profile'] != null && json['to_profile'] is Map<String, dynamic>) {
      toP = Profile.fromJson(json['to_profile'] as Map<String, dynamic>);
    }

    String? gName;
    if (json['groups'] != null && json['groups'] is Map<String, dynamic>) {
      gName = json['groups']['name'] as String?;
    }

    return Settlement(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      fromProfile: fromP,
      toProfile: toP,
      groupName: gName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'from_user': fromUser,
      'to_user': toUser,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
