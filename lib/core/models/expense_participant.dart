import 'profile.dart';

class ExpenseParticipant {
  final String id;
  final String expenseId;
  final String userId;
  final double shareAmount;
  final Profile? profile;

  ExpenseParticipant({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.shareAmount,
    this.profile,
  });

  factory ExpenseParticipant.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipant(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      shareAmount: (json['share_amount'] is num)
          ? (json['share_amount'] as num).toDouble()
          : double.tryParse(json['share_amount']?.toString() ?? '0') ?? 0.0,
      profile: json['profiles'] != null && json['profiles'] is Map<String, dynamic>
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'share_amount': shareAmount,
    };
  }
}
