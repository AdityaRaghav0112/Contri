import 'package:flutter/material.dart';
import 'group_member.dart';

class Group {
  final String id;
  final String name;
  final String icon;
  final String currency;
  final String createdBy;
  final String status;
  final DateTime createdAt;
  final List<GroupMember> members;
  final double totalSpent;
  final double userNetBalance;
  final bool settled;

  Group({
    required this.id,
    required this.name,
    required this.icon,
    required this.currency,
    required this.createdBy,
    required this.status,
    required this.createdAt,
    this.members = const [],
    this.totalSpent = 0.0,
    this.userNetBalance = 0.0,
    this.settled = false,
  });

  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'flight_takeoff':
      case 'flight':
      case 'travel':
        return Icons.flight_takeoff;
      case 'apartment':
      case 'home':
        return Icons.apartment;
      case 'local_movies':
      case 'movie':
      case 'movies':
        return Icons.local_movies;
      case 'directions_car':
      case 'car':
      case 'trip':
        return Icons.directions_car;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'shopping_cart':
      case 'shopping':
        return Icons.shopping_cart;
      case 'sports_soccer':
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.groups;
    }
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    List<GroupMember> members = const [],
    double totalSpent = 0.0,
    double userNetBalance = 0.0,
    bool settled = false,
  }) {
    return Group(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Unnamed Group',
      icon: (json['icon'] as String?) ?? 'groups',
      currency: (json['currency'] as String?) ?? 'INR',
      createdBy: json['created_by'] as String,
      status: (json['status'] as String?) ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      members: members,
      totalSpent: totalSpent,
      userNetBalance: userNetBalance,
      settled: settled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'currency': currency,
      'created_by': createdBy,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? icon,
    String? currency,
    String? createdBy,
    String? status,
    DateTime? createdAt,
    List<GroupMember>? members,
    double? totalSpent,
    double? userNetBalance,
    bool? settled,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      currency: currency ?? this.currency,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      totalSpent: totalSpent ?? this.totalSpent,
      userNetBalance: userNetBalance ?? this.userNetBalance,
      settled: settled ?? this.settled,
    );
  }
}
