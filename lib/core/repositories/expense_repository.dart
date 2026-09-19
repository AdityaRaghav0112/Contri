import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/supabase_service.dart';

class ExpenseRepository {
  final SupabaseService _supabaseService = SupabaseService();

  /// Fetches all expenses for a particular group
  Future<List<Expense>> getExpensesByGroup(String groupId) async {
    try {
      final response = await _supabaseService.client
          .from('expenses')
          .select('*, profiles!paid_by(*), groups(name), expense_participants(*, profiles!user_id(*))')
          .eq('group_id', groupId)
          .order('expense_date', ascending: false);

      return (response as List).map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error with joined expenses query: $e. Falling back to base query.');
      try {
        final expResponse = await _supabaseService.client
            .from('expenses')
            .select()
            .eq('group_id', groupId)
            .order('expense_date', ascending: false);

        final List<Expense> results = [];
        for (final expJson in expResponse) {
          final expId = expJson['id'] as String;
          final partsResponse = await _supabaseService.client
              .from('expense_participants')
              .select('*, profiles!user_id(*)')
              .eq('expense_id', expId);

          final payerRes = await _supabaseService.client
              .from('profiles')
              .select()
              .eq('id', expJson['paid_by'])
              .maybeSingle();

          final expMap = Map<String, dynamic>.from(expJson);
          expMap['expense_participants'] = partsResponse;
          if (payerRes != null) expMap['profiles'] = payerRes;

          results.add(Expense.fromJson(expMap));
        }
        return results;
      } catch (fallbackErr) {
        debugPrint('Fallback expense fetch failed: $fallbackErr');
        return [];
      }
    }
  }

  /// Fetches recent expenses across all user's groups
  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    try {
      final response = await _supabaseService.client
          .from('expenses')
          .select('*, profiles!paid_by(*), groups(name), expense_participants(*, profiles!user_id(*))')
          .order('expense_date', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching recent expenses with join: $e');
      try {
        final expResponse = await _supabaseService.client
            .from('expenses')
            .select('*, groups(name)')
            .order('expense_date', ascending: false)
            .limit(limit);

        final List<Expense> results = [];
        for (final expJson in expResponse) {
          final payerRes = await _supabaseService.client
              .from('profiles')
              .select()
              .eq('id', expJson['paid_by'])
              .maybeSingle();

          final expMap = Map<String, dynamic>.from(expJson);
          if (payerRes != null) expMap['profiles'] = payerRes;
          results.add(Expense.fromJson(expMap));
        }
        return results;
      } catch (err) {
        debugPrint('Fallback recent expenses failed: $err');
        return [];
      }
    }
  }

  /// Adds a new expense and participant split records into Supabase
  Future<Expense> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String category,
    required String paidBy,
    required Map<String, double> participantShares,
  }) async {
    final currentUserId = _supabaseService.currentProfile?.id ?? paidBy;

    // 1. Insert into expenses table
    final expenseInsert = {
      'group_id': groupId,
      'description': description,
      'amount': amount,
      'category': category,
      'paid_by': paidBy,
      'expense_date': DateTime.now().toIso8601String(),
      'created_by': currentUserId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final expenseRes = await _supabaseService.client
        .from('expenses')
        .insert(expenseInsert)
        .select()
        .single();

    final String expenseId = expenseRes['id'] as String;

    // 2. Insert into expense_participants table
    final List<Map<String, dynamic>> participantsData = [];
    participantShares.forEach((userId, shareAmount) {
      participantsData.add({
        'expense_id': expenseId,
        'user_id': userId,
        'share_amount': shareAmount,
      });
    });

    if (participantsData.isNotEmpty) {
      await _supabaseService.client
          .from('expense_participants')
          .insert(participantsData);
    }

    final fullExpense = await _supabaseService.client
        .from('expenses')
        .select('*, profiles!paid_by(*), groups(name), expense_participants(*, profiles!user_id(*))')
        .eq('id', expenseId)
        .maybeSingle();

    if (fullExpense != null) {
      return Expense.fromJson(fullExpense);
    }

    return Expense.fromJson(expenseRes);
  }

  /// Deletes an expense and cascade removes its participants
  Future<void> deleteExpense(String expenseId) async {
    await _supabaseService.client
        .from('expense_participants')
        .delete()
        .eq('expense_id', expenseId);

    await _supabaseService.client
        .from('expenses')
        .delete()
        .eq('id', expenseId);
  }
}
