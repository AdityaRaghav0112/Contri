import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupName;
  final List<String> members;

  const AddExpenseScreen({
    super.key,
    this.groupName = 'Movie & Weekend Getaway',
    this.members = const ['You', 'Alex Rivera', 'Maya Lin'],
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

  final TextEditingController _descriptionController =
      TextEditingController(text: 'Movie: Dune IMAX 3D');

  final TextEditingController _amountController =
      TextEditingController(text: '300.00');

  final TextEditingController _noteController = TextEditingController();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  String _selectedCategory = 'Movies';

  String _selectedPayer = 'You';

  bool _isSaving = false;

  bool _saved = false;

  final Set<String> _selectedParticipants = {
    'You',
    'Alex Rivera',
    'Maya Lin',
  };

  @override
  void initState() {
    super.initState();

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
    return _selectedParticipants.length;
  }

  double get _equalShare {
    if (_participantCount == 0) return 0;

    return _amount / _participantCount;
  }

  double _amountPaidBy(String member) {
    if (_selectedPayer == member) {
      return _amount;
    }

    return 0;
  }

  double _shareFor(String member) {
    if (!_selectedParticipants.contains(member)) {
      return 0;
    }

    return _equalShare;
  }

  double _netFor(String member) {
    return _amountPaidBy(member) - _shareFor(member);
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _showPayerPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
                ...widget.members.map(
                  (member) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: _avatar(member),
                    title: Text(
                      member,
                      style: const TextStyle(
                        fontSize: 16,
                        color: onSurface,
                      ),
                    ),
                    trailing: member == _selectedPayer
                        ? const Icon(
                            Icons.check,
                            color: primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context, member);
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
        _selectedPayer = result;
      });
    }
  }

  Future<void> _attachReceipt() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt attachment will be connected next.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    if (_selectedParticipants.isEmpty) {
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

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _saved = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  // ---------------------------------------------------------------------------
  // UI Helpers
  // ---------------------------------------------------------------------------

  Widget _avatar(String name) {
    final letter = name == 'You'
        ? 'Y'
        : name.trim().isEmpty
            ? '?'
            : name.trim()[0].toUpperCase();

    Color avatarColor = secondaryContainer;

    if (name == 'Maya Lin') {
      avatarColor = const Color(0xFF456179);
    }

    if (name == 'Alex Rivera') {
      avatarColor = const Color(0xFF4A635F);
    }

    return CircleAvatar(
      radius: 15,
      backgroundColor: avatarColor,
      child: Text(
        letter,
        style: TextStyle(
          color: name == 'Maya Lin' ? Colors.white : onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _categoryPill(
    String emoji,
    String title,
  ) {
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
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
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

  Widget _payerPill(String member) {
    final selected = _selectedPayer == member;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayer = member;
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
              member == 'You' ? 'You' : member.split(' ').first,
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

  // ---------------------------------------------------------------------------
  // Participant Row
  // ---------------------------------------------------------------------------

  Widget _participantRow(String member) {
    final included = _selectedParticipants.contains(member);
    final net = _netFor(member);
    final share = _shareFor(member);
    final paid = _amountPaidBy(member);

    final isPayer = member == _selectedPayer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (included) {
                  _selectedParticipants.remove(member);

                  // Never leave zero participants.
                  if (_selectedParticipants.isEmpty) {
                    _selectedParticipants.add(member);
                  }
                } else {
                  _selectedParticipants.add(member);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: included ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: included ? primary : outline,
                  width: 2,
                ),
              ),
              child: included
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
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
                        member,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isPayer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
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
                const SizedBox(height: 3),
                Text(
                  isPayer
                      ? 'Paid ${_money(paid)} • Share ${_money(share)}'
                      : 'Exact share: ${_participantCount == 0 ? '0' : '1/$_participantCount'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                net >= 0
                    ? '+ ${_money(net)}'
                    : '- ${_money(net.abs())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: net >= 0 ? primary : error,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                net > 0
                    ? 'you get back'
                    : net < 0
                        ? 'owes you'
                        : 'settled',
                style: TextStyle(
                  fontSize: 11,
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpenseHero(),
                      _buildCategories(),
                      _buildPaidBy(),
                      _buildSplitSummary(),
                      _buildSaveSection(),
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

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------

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
              icon: const Icon(
                Icons.arrow_back,
                size: 24,
              ),
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
                      letterSpacing: -.2,
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
              onTap: _isSaving || _saved ? null : _saveExpense,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expense Hero
  // ---------------------------------------------------------------------------

  Widget _buildExpenseHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: Icon(
                  _categoryIcon(),
                  color: onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    fontSize: 20,
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: outline,
                    ),
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 48,
                        color: primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Short Note / Tag input field (max 20 chars)
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.tag_outlined,
                  size: 18,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLength: 20,
                    maxLines: 1,
                    buildCounter: (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) =>
                        null,
                    style: const TextStyle(
                      fontSize: 13,
                      color: onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tag or short note (max 20 chars)',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: outline,
                      ),
                      counterText: '',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_noteController.text.length}/20',
                  style: const TextStyle(
                    fontSize: 11,
                    color: outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _attachReceipt,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 17,
                        color: primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add receipt / ticket',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.circle,
                size: 8,
                color: primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Auto date & time',
                style: TextStyle(
                  fontSize: 11,
                  color: outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon() {
    switch (_selectedCategory) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Rent':
        return Icons.home_outlined;
      case 'Groceries':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.movie_outlined;
    }
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _categoryPill('🎬', 'Movies'),
            const SizedBox(width: 7),
            _categoryPill('🍕', 'Food'),
            const SizedBox(width: 7),
            _categoryPill('🚕', 'Transport'),
            const SizedBox(width: 7),
            _categoryPill('🏠', 'Rent'),
            const SizedBox(width: 7),
            _categoryPill('🛒', 'Groceries'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Paid By
  // ---------------------------------------------------------------------------

  Widget _buildPaidBy() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Paid by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showPayerPicker,
                child: const Text(
                  'Tap to change payer',
                  style: TextStyle(
                    fontSize: 12,
                    color: outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...widget.members.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _payerPill(member),
                  ),
                ),
                GestureDetector(
                  onTap: _showPayerPicker,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: surfaceLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.group_add_outlined,
                          size: 19,
                          color: outline,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Multiple',
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // Split Summary
  // ---------------------------------------------------------------------------

  Widget _buildSplitSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: secondaryContainer.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_money(_amount)} split equally among $_participantCount ${_participantCount == 1 ? 'person' : 'people'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_money(_equalShare)}/ea',
                    style: const TextStyle(
                      fontSize: 12,
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...widget.members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _participantRow(member),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Save Section
  // ---------------------------------------------------------------------------

  Widget _buildSaveSection() {
    String buttonText;

    if (_isSaving) {
      buttonText = 'Saving transaction...';
    } else if (_saved) {
      buttonText = 'Expense Logged!';
    } else {
      buttonText = 'Save Expense • ${_money(_amount)}';
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isSaving || _saved ? null : _saveExpense,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: _saved ? primaryContainer : primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSaving
                      ? Icons.sync
                      : _saved
                          ? Icons.celebration_outlined
                          : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 23,
                ),
                const SizedBox(width: 9),
                Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'All $_participantCount participants will receive an instant notification.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: outline,
          ),
        ),
      ],
    );
  }
}