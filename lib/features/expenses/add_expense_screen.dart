import 'package:flutter/material.dart';
import '../../core/models/profile.dart';
import '../../core/repositories/expense_repository.dart';
import '../../core/services/supabase_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<Profile> members;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    this.groupName = 'Contri Group',
    this.members = const [],
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------
  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEDF6F3);

  static const Color primary = Color(0xFF005048);
  static const Color primaryContainer = Color(0xFF006A60);

  static const Color secondaryContainer = Color(0xFFCAE5E0);
  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);
  static const Color outline = Color(0xFF6E7977);

  static const Color error = Color(0xFFBA1A1A);

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SupabaseService _supabaseService = SupabaseService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  String _selectedCategory = 'Food';
  late String _selectedPayerId;
  bool _isSaving = false;
  late Set<String> _selectedParticipantIds;

  late List<Profile> _effectiveMembers;

  @override
  void initState() {
    super.initState();

    final currentProfile = _supabaseService.currentProfile ??
        Profile(
          id: '00000000-0000-0000-0000-000000000001',
          name: 'You',
          email: 'you@contri.app',
          createdAt: DateTime.now(),
        );

    // Build member list ensuring current user is present
    if (widget.members.isEmpty) {
      _effectiveMembers = [currentProfile];
    } else {
      _effectiveMembers = List.from(widget.members);
      if (!_effectiveMembers.any((m) => m.id == currentProfile.id)) {
        _effectiveMembers.insert(0, currentProfile);
      }
    }

    _selectedPayerId = currentProfile.id;
    _selectedParticipantIds = _effectiveMembers.map((m) => m.id).toSet();

    _amountController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
    _noteController.addListener(_refresh);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Calculations
  // ---------------------------------------------------------------------------
  double get _amount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  int get _participantCount {
    return _selectedParticipantIds.length;
  }

  double get _equalShare {
    if (_participantCount == 0) return 0;
    return _amount / _participantCount;
  }

  double _amountPaidBy(String userId) {
    if (_selectedPayerId == userId) {
      return _amount;
    }
    return 0;
  }

  double _shareFor(String userId) {
    if (!_selectedParticipantIds.contains(userId)) {
      return 0;
    }
    return _equalShare;
  }

  double _netFor(String userId) {
    return _amountPaidBy(userId) - _shareFor(userId);
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _displayName(Profile profile) {
    final currentUserId = _supabaseService.currentProfile?.id;
    if (profile.id == currentUserId) return 'You';
    return profile.name;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  Future<void> _showPayerPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: outline.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Who paid?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._effectiveMembers.map(
                  (member) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: _avatar(member),
                    title: Text(
                      _displayName(member),
                      style: const TextStyle(
                        fontSize: 16,
                        color: onSurface,
                      ),
                    ),
                    trailing: member.id == _selectedPayerId
                        ? const Icon(Icons.check, color: primary)
                        : null,
                    onTap: () {
                      Navigator.pop(context, member.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPayerId = result;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an expense amount.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a description.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one participant.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, double> participantShares = {};
      for (final pId in _selectedParticipantIds) {
        participantShares[pId] = _equalShare;
      }

      await _expenseRepository.addExpense(
        groupId: widget.groupId,
        description: _descriptionController.text.trim(),
        amount: _amount,
        category: _selectedCategory,
        paidBy: _selectedPayerId,
        participantShares: participantShares,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving expense: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI Helpers
  // ---------------------------------------------------------------------------
  Widget _avatar(Profile member) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: secondaryContainer,
      child: Text(
        member.initials,
        style: const TextStyle(
          color: primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _categoryIcon() {
    switch (_selectedCategory.toLowerCase()) {
      case 'movies':
        return Icons.local_movies_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'travel':
        return Icons.flight_takeoff_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'home':
        return Icons.wifi_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Widget _categoryPill(String emoji, String title) {
    final selected = _selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? primaryContainer : surfaceLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : onSurfaceVariant,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payerPill(Profile member) {
    final selected = _selectedPayerId == member.id;
    final name = _displayName(member);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayerId = member.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? primary : surfaceLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
            else
              _avatar(member),
            const SizedBox(width: 7),
            Text(
              name == 'You' ? 'You' : name.split(' ').first,
              style: TextStyle(
                color: selected ? Colors.white : onSurfaceVariant,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _participantRow(Profile member) {
    final included = _selectedParticipantIds.contains(member.id);
    final net = _netFor(member.id);
    final share = _shareFor(member.id);
    final paid = _amountPaidBy(member.id);
    final isPayer = member.id == _selectedPayerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (included) {
                  _selectedParticipantIds.remove(member.id);
                  if (_selectedParticipantIds.isEmpty) {
                    _selectedParticipantIds.add(member.id);
                  }
                } else {
                  _selectedParticipantIds.add(member.id);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: included ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: included ? primary : outline,
                  width: 2,
                ),
              ),
              child: included
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _displayName(member),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isPayer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9FF2E4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Payer',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF00201C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isPayer
                      ? 'Paid ${_money(paid)} • Share ${_money(share)}'
                      : 'Exact share: ${_money(share)}',
                  style: const TextStyle(fontSize: 11, color: outline),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                net >= 0 ? '+ ${_money(net)}' : '- ${_money(net.abs())}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: net >= 0 ? primary : error,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                net > 0
                    ? 'gets back'
                    : net < 0
                        ? 'owes'
                        : 'settled',
                style: TextStyle(
                  fontSize: 10,
                  color: net >= 0 ? primary : error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpenseHero(),
                      const SizedBox(height: 18),
                      _buildCategories(),
                      const SizedBox(height: 18),
                      _buildPaidBy(),
                      const SizedBox(height: 18),
                      _buildSplitSummary(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: .96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 24),
              color: onSurface,
            ),
            const SizedBox(width: 4),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    widget.groupName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _isSaving ? null : _saveExpense,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else ...[
                      const Icon(Icons.check, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_categoryIcon(), color: onSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    fontSize: 18,
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Dinner, Groceries, Movie',
                    labelStyle: TextStyle(fontSize: 13, color: outline),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 38,
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 44,
                        color: primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0.00',
                        hintStyle: TextStyle(color: primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: outline,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryPill('🍔', 'Food'),
              const SizedBox(width: 8),
              _categoryPill('🎬', 'Movies'),
              const SizedBox(width: 8),
              _categoryPill('✈️', 'Travel'),
              const SizedBox(width: 8),
              _categoryPill('🚗', 'Transport'),
              const SizedBox(width: 8),
              _categoryPill('🏠', 'Home'),
              const SizedBox(width: 8),
              _categoryPill('🛍️', 'Shopping'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaidBy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PAID BY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: outline,
              ),
            ),
            GestureDetector(
              onTap: _showPayerPicker,
              child: const Text(
                'Change payer',
                style: TextStyle(
                  fontSize: 12,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _effectiveMembers.map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _payerPill(m),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SPLIT EQUALLY BETWEEN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: outline,
              ),
            ),
            Text(
              '$_participantCount of ${_effectiveMembers.length} people',
              style: const TextStyle(
                fontSize: 12,
                color: outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._effectiveMembers.map((m) => _participantRow(m)),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Save Expense',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}