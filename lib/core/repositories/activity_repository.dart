import 'package:flutter/material.dart';
import '../services/cache_service.dart';
import '../services/supabase_service.dart';
import 'expense_repository.dart';
import 'settlement_repository.dart';

class ActivityItem {
  final String id;
  final String title;
  final String group;
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final String date;
  final DateTime dateTime;
  final double totalAmount;
  final double userShare;
  final bool isUserPayer;
  final bool isSettlement;
  final String payerName;
  final int participantsCount;
  final String tag;
  final List<String> participants;

  ActivityItem({
    required this.id,
    required this.title,
    required this.group,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    required this.dateTime,
    required this.totalAmount,
    required this.userShare,
    required this.isUserPayer,
    this.isSettlement = false,
    required this.payerName,
    required this.participantsCount,
    required this.tag,
    required this.participants,
  });
}

class ActivitySection {
  final String period;
  final List<ActivityItem> activities;

  ActivitySection({
    required this.period,
    required this.activities,
  });
}

class ActivityRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SettlementRepository _settlementRepository = SettlementRepository();
  final CacheService _cacheService = CacheService();

  /// Fetches a unified activity timeline from Supabase with Cache-First support
  Future<List<ActivitySection>> getActivityFeed({bool forceRefresh = false}) async {
    const cacheKey = 'activity_feed';
    if (!forceRefresh) {
      final cached = _cacheService.get<List<ActivitySection>>(cacheKey);
      if (cached != null) return cached;
    }

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    final List<ActivityItem> allItems = [];

    // 1. Fetch Expenses
    final expenses = await _expenseRepository.getRecentExpenses(limit: 50);
    for (final exp in expenses) {
      final isPayer = exp.paidBy == currentUserId;
      final payerName = isPayer ? 'You' : (exp.payerProfile?.name ?? 'Member');

      double myShare = 0.0;
      for (final p in exp.participants) {
        if (p.userId == currentUserId) {
          myShare = p.shareAmount;
        }
      }

      double netShare;
      if (isPayer) {
        netShare = exp.amount - myShare;
      } else {
        netShare = -myShare;
      }

      final List<String> participantStrings = [];
      participantStrings.add('$payerName (Paid ₹${exp.amount.toStringAsFixed(2)})');
      for (final p in exp.participants) {
        if (p.userId != exp.paidBy) {
          final pName = (p.userId == currentUserId) ? 'You' : (p.profile?.name ?? 'Member');
          participantStrings.add('$pName (Share ₹${p.shareAmount.toStringAsFixed(2)})');
        }
      }

      allItems.add(
        ActivityItem(
          id: exp.id,
          title: exp.description,
          group: exp.groupName ?? 'Contri Group',
          category: exp.category,
          categoryIcon: exp.categoryIcon,
          categoryColor: _categoryColor(exp.category),
          date: _formatDate(exp.expenseDate),
          dateTime: exp.expenseDate,
          totalAmount: exp.amount,
          userShare: netShare,
          isUserPayer: isPayer,
          isSettlement: false,
          payerName: payerName,
          participantsCount: exp.participants.isNotEmpty ? exp.participants.length : 1,
          tag: '#${exp.category.toLowerCase().replaceAll(' ', '')}',
          participants: participantStrings,
        ),
      );
    }

    // 2. Fetch Settlements
    final settlements = await _settlementRepository.getAllSettlements();
    for (final st in settlements) {
      final isFromMe = st.fromUser == currentUserId;
      final isToMe = st.toUser == currentUserId;

      final fromName = isFromMe ? 'You' : (st.fromProfile?.name ?? 'Member');
      final toName = isToMe ? 'You' : (st.toProfile?.name ?? 'Member');

      final title = isFromMe
          ? 'Settled with $toName'
          : 'Settled by $fromName';

      allItems.add(
        ActivityItem(
          id: st.id,
          title: title,
          group: st.groupName ?? 'Direct Settlement',
          category: 'Settlement',
          categoryIcon: Icons.check_circle_outline,
          categoryColor: const Color(0xFF005048),
          date: _formatDate(st.createdAt),
          dateTime: st.createdAt,
          totalAmount: st.amount,
          userShare: isToMe ? st.amount : -st.amount,
          isUserPayer: isFromMe,
          isSettlement: true,
          payerName: fromName,
          participantsCount: 2,
          tag: '#settle',
          participants: [
            '$fromName (Paid ₹${st.amount.toStringAsFixed(2)})',
            '$toName (Received ₹${st.amount.toStringAsFixed(2)})',
          ],
        ),
      );
    }

    // Sort descending by date
    allItems.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Group into sections
    final Map<String, List<ActivityItem>> grouped = {};
    final now = DateTime.now();

    for (final item in allItems) {
      final diffDays = _daysBetween(item.dateTime, now);
      String period;
      if (diffDays == 0) {
        period = 'Today';
      } else if (diffDays == 1) {
        period = 'Yesterday';
      } else if (diffDays < 30) {
        period = 'Earlier this month';
      } else {
        period = 'Previous months';
      }

      grouped.putIfAbsent(period, () => []).add(item);
    }

    final sections = grouped.entries
        .map((e) => ActivitySection(period: e.key, activities: e.value))
        .toList();

    _cacheService.set('activity_feed', sections);
    return sections;
  }

  int _daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return (toDate.difference(fromDate).inHours / 24).round();
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diffDays = _daysBetween(dt, now);

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (diffDays == 0) {
      return 'Today, $timeStr';
    } else if (diffDays == 1) {
      return 'Yesterday, $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, $timeStr';
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'movies':
      case 'movie':
      case 'entertainment':
        return const Color(0xFF6B8E8E);
      case 'food':
      case 'restaurant':
        return const Color(0xFFBFA77D);
      case 'travel':
      case 'trip':
        return const Color(0xFF879B8C);
      case 'transport':
      case 'car':
        return const Color(0xFF5A7B8C);
      case 'home':
      case 'wifi':
        return const Color(0xFF9E829C);
      default:
        return const Color(0xFF005048);
    }
  }
}
