import 'package:flutter/material.dart';
import 'expense_participant.dart';
import 'profile.dart';

class Expense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String category;
  final String paidBy;
  final DateTime expenseDate;
  final String createdBy;
  final DateTime createdAt;
  final Profile? payerProfile;
  final String? groupName;
  final List<ExpenseParticipant> participants;

  Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.expenseDate,
    required this.createdBy,
    required this.createdAt,
    this.payerProfile,
    this.groupName,
    this.participants = const [],
  });

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'movies':
      case 'movie':
      case 'cinema':
      case 'entertainment':
        return Icons.local_movies_outlined;
      case 'food':
      case 'restaurant':
      case 'dinner':
      case 'lunch':
      case 'cafe':
        return Icons.restaurant_outlined;
      case 'travel':
      case 'trip':
      case 'flight':
      case 'train':
        return Icons.flight_takeoff_outlined;
      case 'transport':
      case 'taxi':
      case 'uber':
      case 'gas':
        return Icons.directions_car_outlined;
      case 'home':
      case 'rent':
      case 'utilities':
      case 'wifi':
      case 'bills':
        return Icons.wifi_outlined;
      case 'shopping':
      case 'groceries':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    List<ExpenseParticipant> participantsList = [];
    if (json['expense_participants'] != null &&
        json['expense_participants'] is List) {
      participantsList = (json['expense_participants'] as List)
          .map((p) => ExpenseParticipant.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    Profile? payer;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      payer = Profile.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    String? gName;
    if (json['groups'] != null && json['groups'] is Map<String, dynamic>) {
      gName = json['groups']['name'] as String?;
    }

    return Expense(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      description: (json['description'] as String?) ?? 'Expense',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      category: (json['category'] as String?) ?? 'General',
      paidBy: json['paid_by'] as String,
      expenseDate: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      createdBy: (json['created_by'] as String?) ?? json['paid_by'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      payerProfile: payer,
      groupName: gName,
      participants: participantsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'description': description,
      'amount': amount,
      'category': category,
      'paid_by': paidBy,
      'expense_date': expenseDate.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
