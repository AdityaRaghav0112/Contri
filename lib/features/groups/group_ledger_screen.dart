import 'package:flutter/material.dart';
import '../../core/models/expense.dart';
import '../../core/models/group.dart';
import '../../core/models/profile.dart';
import '../../core/models/settlement.dart';
import '../../core/repositories/expense_repository.dart';
import '../../core/repositories/group_repository.dart';
import '../../core/repositories/settlement_repository.dart';
import '../../core/services/supabase_service.dart';
import '../expenses/add_expense_screen.dart';

class MemberGroupBalance {
  final Profile profile;
  final double netBalance; // positive = owes user, negative = user owes them
  final bool settled;

  MemberGroupBalance({
    required this.profile,
    required this.netBalance,
    required this.settled,
  });

  String get name => profile.name;
  String get initials => profile.initials;
}

class GroupLedgerScreen extends StatefulWidget {
  final String groupName;
  final IconData groupIcon;
  final String? groupId;

  const GroupLedgerScreen({
    super.key,
    required this.groupName,
    required this.groupIcon,
    this.groupId,
  });

  @override
  State<GroupLedgerScreen> createState() => _GroupLedgerScreenState();
}

class _GroupLedgerScreenState extends State<GroupLedgerScreen> {
  // ============================================================
  // COLORS
  // ============================================================
  static const Color primary = Color(0xFF005048);
  static const Color primaryFixed = Color(0xFF9FF2E4);
  static const Color onPrimaryFixed = Color(0xFF00201C);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);

  static const Color secondaryContainer = Color(0xFFCAE5E0);
  static const Color onSecondaryContainer = Color(0xFF4E6763);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color error = Color(0xFFBA1A1A);

  // ============================================================
  // REPOSITORIES & STATE
  // ============================================================
  final GroupRepository _groupRepository = GroupRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SettlementRepository _settlementRepository = SettlementRepository();
  final SupabaseService _supabaseService = SupabaseService();

  int _selectedFilter = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreExpenses = true;
  static const int _pageSize = 20;

  Group? _group;
  List<Expense> _expenses = [];
  List<Settlement> _settlements = [];
  List<MemberGroupBalance> _memberBalances = [];
  List<Profile> _allGroupMembers = [];

  final List<String> _filters = [
    'All',
    'You paid',
    'Unsettled',
    'Food',
    'Movies',
    'Travel',
    'Home',
  ];

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    // 1. Find group if groupId is provided or search by name
    String? gId = widget.groupId;
    if (gId == null) {
      final allGroups = await _groupRepository.getGroups(forceRefresh: forceRefresh);
      final match = allGroups.where((g) => g.name == widget.groupName).toList();
      if (match.isNotEmpty) {
        gId = match.first.id;
      }
    }

    if (gId != null) {
      _group = await _groupRepository.getGroupById(gId, forceRefresh: forceRefresh);
      _expenses = await _expenseRepository.getExpensesByGroup(
        gId,
        limit: _pageSize,
        offset: 0,
        forceRefresh: forceRefresh,
      );
      _hasMoreExpenses = _expenses.length >= _pageSize;
      _settlements = await _settlementRepository.getSettlementsByGroup(gId, forceRefresh: forceRefresh);

      // Extract all member profiles from group
      _allGroupMembers = _group?.members.map((m) => m.profile).whereType<Profile>().toList() ?? [];

      _recalculateMemberBalances(currentUserId);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _recalculateMemberBalances(String currentUserId) {
    final List<MemberGroupBalance> calculatedBalances = [];

    for (final member in _allGroupMembers) {
      if (member.id == currentUserId) continue;

      double pairwiseNet = 0.0;

      for (final exp in _expenses) {
        final paidBy = exp.paidBy;
        if (paidBy == currentUserId) {
          for (final p in exp.participants) {
            if (p.userId == member.id) {
              pairwiseNet += p.shareAmount;
            }
          }
        } else if (paidBy == member.id) {
          for (final p in exp.participants) {
            if (p.userId == currentUserId) {
              pairwiseNet -= p.shareAmount;
            }
          }
        }
      }

      for (final st in _settlements) {
        if (st.fromUser == member.id && st.toUser == currentUserId) {
          pairwiseNet -= st.amount;
        } else if (st.fromUser == currentUserId && st.toUser == member.id) {
          pairwiseNet += st.amount;
        }
      }

      final bool isSettled = pairwiseNet.abs() < 0.01;
      calculatedBalances.add(
        MemberGroupBalance(
          profile: member,
          netBalance: pairwiseNet,
          settled: isSettled,
        ),
      );
    }

    _memberBalances = calculatedBalances;
  }

  Future<void> _loadMoreExpenses() async {
    final gId = _group?.id ?? widget.groupId;
    if (gId == null || _isLoadingMore || !_hasMoreExpenses) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextBatch = await _expenseRepository.getExpensesByGroup(
      gId,
      limit: _pageSize,
      offset: _expenses.length,
    );

    if (!mounted) return;

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    setState(() {
      _expenses.addAll(nextBatch);
      _hasMoreExpenses = nextBatch.length >= _pageSize;
      _isLoadingMore = false;
      _recalculateMemberBalances(currentUserId);
    });
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================
  double get _totalSpent {
    return _expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  }

  double get _youAreOwed {
    return _memberBalances.where((m) => m.netBalance > 0).fold(0.0, (sum, m) => sum + m.netBalance);
  }

  double get _youOwe {
    return _memberBalances.where((m) => m.netBalance < 0).fold(0.0, (sum, m) => sum + m.netBalance.abs());
  }

  double get _netPosition => _youAreOwed - _youOwe;

  List<Expense> get _filteredExpenses {
    final currentUserId = _supabaseService.currentProfile?.id;
    return _expenses.where((exp) {
      switch (_selectedFilter) {
        case 1: // You paid
          return exp.paidBy == currentUserId;
        case 2: // Unsettled
          return true;
        case 3: // Food
          return exp.category.toLowerCase().contains('food') || exp.category.toLowerCase().contains('restaurant');
        case 4: // Movies
          return exp.category.toLowerCase().contains('movie') || exp.category.toLowerCase().contains('cinema');
        case 5: // Travel
          return exp.category.toLowerCase().contains('travel') || exp.category.toLowerCase().contains('trip');
        case 6: // Home
          return exp.category.toLowerCase().contains('home') || exp.category.toLowerCase().contains('wifi');
        default:
          return true;
      }
    }).toList();
  }

  // ============================================================
  // SETTLE ACTIONS
  // ============================================================
  Future<void> _settleSingleMember(MemberGroupBalance member) async {
    final gId = _group?.id ?? widget.groupId;
    if (gId == null || member.netBalance.abs() < 0.01) return;

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    if (member.netBalance > 0) {
      // Member owes user -> Member pays user
      await _settlementRepository.createSettlement(
        groupId: gId,
        fromUserId: member.profile.id,
        toUserId: currentUserId,
        amount: member.netBalance,
      );
    } else {
      // User owes member -> User pays member
      await _settlementRepository.createSettlement(
        groupId: gId,
        fromUserId: currentUserId,
        toUserId: member.profile.id,
        amount: member.netBalance.abs(),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settled with ${member.name}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadGroupData();
  }

  Future<void> _settleAllBalances() async {
    final gId = _group?.id ?? widget.groupId;
    if (gId == null) return;

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    for (final member in _memberBalances) {
      if (member.netBalance.abs() >= 0.01) {
        if (member.netBalance > 0) {
          await _settlementRepository.createSettlement(
            groupId: gId,
            fromUserId: member.profile.id,
            toUserId: currentUserId,
            amount: member.netBalance,
          );
        } else {
          await _settlementRepository.createSettlement(
            groupId: gId,
            fromUserId: currentUserId,
            toUserId: member.profile.id,
            amount: member.netBalance.abs(),
          );
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All balances settled successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 27),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.groupIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.groupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadGroupData,
            icon: const Icon(Icons.refresh, size: 22),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _supabaseService.currentProfile?.initials ?? 'AR',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SafeArea(
              top: false,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupPositionCard(),
                        const SizedBox(height: 18),
                        _buildMemberBalances(),
                        const SizedBox(height: 20),
                        _buildActivityLedger(),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _buildAddExpenseButton(),
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // GROUP POSITION CARD
  // ============================================================
  Widget _buildGroupPositionCard() {
    final netPositive = _netPosition >= 0;
    final balanceDesc = _memberBalances.isEmpty
        ? 'No members'
        : 'Across ${_memberBalances.length} members';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'GROUP POSITION',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 13,
                      color: onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _netPosition.abs() < 0.01 ? 'Settled Up' : 'Active Ledger',
                      style: const TextStyle(
                        fontSize: 10,
                        color: onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            netPositive ? 'You are owed' : 'You owe',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_netPosition.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: netPositive ? primary : error,
                ),
              ),
              const SizedBox(width: 7),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  balanceDesc,
                  style: const TextStyle(
                    fontSize: 10,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildBalanceSummary(
                  icon: Icons.arrow_downward,
                  label: 'You owe',
                  amount: '₹${_youOwe.toStringAsFixed(2)}',
                  positive: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBalanceSummary(
                  icon: Icons.arrow_upward,
                  label: 'You are owed',
                  amount: '₹${_youAreOwed.toStringAsFixed(2)}',
                  positive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPrimaryAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Settle All',
                  onTap: _showSettleAllDialog,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryAction(
                  icon: Icons.file_download_outlined,
                  label: 'Total: ₹${_totalSpent.toStringAsFixed(0)}',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary({
    required IconData icon,
    required String label,
    required String amount,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: positive ? primary : error),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: positive ? primary : error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: positive ? primary : error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MEMBER BALANCES
  // ============================================================
  Widget _buildMemberBalances() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Text(
                'Member Balances',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${_memberBalances.length} members',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        if (_memberBalances.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                'No other members in this group',
                style: TextStyle(fontSize: 13, color: onSurfaceVariant),
              ),
            ),
          )
        else
          ..._memberBalances.map((mb) {
            final String amountStr;
            if (mb.settled) {
              amountStr = 'Settled up · ₹0.00';
            } else if (mb.netBalance > 0) {
              amountStr = 'Owes you ₹${mb.netBalance.toStringAsFixed(2)}';
            } else {
              amountStr = 'You owe ₹${mb.netBalance.abs().toStringAsFixed(2)}';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMemberBalanceCard(
                name: mb.name,
                avatar: mb.initials,
                avatarColor: const Color(0xFFBFA77D),
                amount: amountStr,
                settled: mb.settled,
                onSettle: () => _settleSingleMember(mb),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMemberBalanceCard({
    required String name,
    required String avatar,
    required Color avatarColor,
    required String amount,
    required bool settled,
    required VoidCallback onSettle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              avatar,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 11,
                    color: settled ? onSurfaceVariant : primary,
                  ),
                ),
              ],
            ),
          ),
          if (settled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: surfaceContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'All clear',
                style: TextStyle(
                  fontSize: 10,
                  color: onSurfaceVariant,
                ),
              ),
            )
          else
            _smallActionButton(
              label: 'Settle',
              icon: Icons.check,
              onTap: onSettle,
              filled: true,
            ),
        ],
      ),
    );
  }

  Widget _smallActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: filled ? primaryFixed : surfaceContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: filled ? onPrimaryFixed : onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: filled ? onPrimaryFixed : onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY LEDGER
  // ============================================================
  Widget _buildActivityLedger() {
    final currentUserId = _supabaseService.currentProfile?.id;
    final filtered = _filteredExpenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Text(
                'Activity Ledger',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${_expenses.length} transactions',
                style: const TextStyle(
                  fontSize: 11,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              return _buildFilterChip(
                label: _filters[index],
                selected: _selectedFilter == index,
                onTap: () {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                'No expenses in this filter',
                style: TextStyle(fontSize: 13, color: onSurfaceVariant),
              ),
            ),
          )
        else
          ...filtered.map((exp) {
            final isPayer = exp.paidBy == currentUserId;
            final payerName = isPayer ? 'You' : (exp.payerProfile?.name ?? 'Member');

            double myShare = 0.0;
            for (final p in exp.participants) {
              if (p.userId == currentUserId) {
                myShare = p.shareAmount;
              }
            }

            final String amountText;
            final Color amountColor;
            final String balanceText;
            final IconData balanceIcon;
            final Color balanceColor;

            if (isPayer) {
              final lent = exp.amount - myShare;
              amountText = '+₹${exp.amount.toStringAsFixed(2)}';
              amountColor = primary;
              balanceText = 'You lent ₹${lent.toStringAsFixed(2)}';
              balanceIcon = Icons.arrow_outward;
              balanceColor = primary;
            } else {
              amountText = '-₹${myShare.toStringAsFixed(2)}';
              amountColor = error;
              balanceText = 'You owe ₹${myShare.toStringAsFixed(2)}';
              balanceIcon = Icons.call_made;
              balanceColor = error;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildExpenseCard(
                icon: exp.categoryIcon,
                iconBackground: secondaryContainer,
                iconColor: onSecondaryContainer,
                title: exp.description,
                amount: amountText,
                amountColor: amountColor,
                payer: payerName,
                total: '₹${exp.amount.toStringAsFixed(2)} total',
                split: 'Split ${exp.participants.length} ways',
                balanceText: balanceText,
                balanceIcon: balanceIcon,
                balanceColor: balanceColor,
                balanceBackground: surfaceContainer,
                time: _formatTime(exp.expenseDate),
              ),
            );
          }),
        if (_hasMoreExpenses)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Center(
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: primary,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: _loadMoreExpenses,
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: const Text('Load older transactions'),
                      style: TextButton.styleFrom(
                        foregroundColor: primary,
                        backgroundColor: surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}, $hour:$minute $period';
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: selected ? secondaryContainer : surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check,
                size: 14,
                color: onSecondaryContainer,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected ? onSecondaryContainer : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String amount,
    required Color amountColor,
    required String payer,
    required String? total,
    required String split,
    required String balanceText,
    required IconData balanceIcon,
    required Color balanceColor,
    required Color balanceBackground,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'Paid by '),
                      TextSpan(
                        text: payer,
                        style: const TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (total != null) TextSpan(text: ' ($total)'),
                      TextSpan(text: ' · $split'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: balanceBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(balanceIcon, size: 13, color: balanceColor),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                balanceText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: balanceColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD EXPENSE BUTTON
  // ============================================================
  Widget _buildAddExpenseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final added = await Navigator.push<bool?>(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                groupId: _group?.id ?? widget.groupId ?? '',
                groupName: widget.groupName,
                members: _allGroupMembers,
              ),
            ),
          );

          if (added == true) {
            _loadGroupData();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: primaryFixed,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 21, color: onPrimaryFixed),
              SizedBox(width: 7),
              Text(
                'Add expense',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onPrimaryFixed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SETTLE ALL DIALOG
  // ============================================================
  void _showSettleAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settle all balances?'),
          content: Text(
            'This will record settlements for all outstanding member balances in '
            '${widget.groupName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _settleAllBalances();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}