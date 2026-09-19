import 'package:flutter/material.dart';
import '../../core/models/expense.dart';
import '../../core/models/group.dart';
import '../../core/repositories/expense_repository.dart';
import '../../core/repositories/group_repository.dart';
import '../../core/services/supabase_service.dart';
import '../groups/create_group_dialog.dart';
import '../groups/group_ledger_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ------------------------------------------------------------
  // Design system colors
  // ------------------------------------------------------------
  static const Color primary = Color(0xFF005048);
  static const Color primaryFixed = Color(0xFF9FF2E4);
  static const Color onPrimaryFixed = Color(0xFF00201C);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);

  static const Color secondaryContainer = Color(0xFFCAE5E0);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  final GroupRepository _groupRepository = GroupRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SupabaseService _supabaseService = SupabaseService();

  List<Group> _groups = [];
  List<Expense> _recentExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final groups = await _groupRepository.getGroups();
    final expenses = await _expenseRepository.getRecentExpenses(limit: 5);

    if (!mounted) return;
    setState(() {
      _groups = groups;
      _recentExpenses = expenses;
      _isLoading = false;
    });
  }

  Future<void> _openCreateGroup() async {
    final newGroup = await showModalBottomSheet<Group?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGroupDialog(),
    );

    if (newGroup != null) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,

      // ----------------------------------------------------------
      // App bar
      // ----------------------------------------------------------
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Groups',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh data',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            iconSize: 27,
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ----------------------------------------------------------
      // Body
      // ----------------------------------------------------------
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupsHeader(),
                    const SizedBox(height: 12),

                    if (_groups.isEmpty)
                      _buildEmptyGroupsState()
                    else
                      ..._groups.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildDynamicGroupCard(context, group),
                        );
                      }),

                    const SizedBox(height: 28),
                    _buildRecentExpensesHeader(),
                    const SizedBox(height: 12),
                    _buildRecentExpenses(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // GROUPS HEADER
  // ============================================================
  Widget _buildGroupsHeader() {
    return Row(
      children: [
        const Text(
          'Your Groups',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${_groups.length})',
          style: const TextStyle(
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _openCreateGroup,
          icon: const Icon(
            Icons.group_add_outlined,
            size: 18,
          ),
          label: const Text('New Group'),
          style: TextButton.styleFrom(
            foregroundColor: primary,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY GROUPS STATE
  // ============================================================
  Widget _buildEmptyGroupsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 48,
            color: primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first group to start tracking expenses with friends.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openCreateGroup,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DYNAMIC GROUP CARD
  // ============================================================
  Widget _buildDynamicGroupCard(BuildContext context, Group group) {
    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    String? balanceText;
    bool positive = false;
    bool settled = group.settled || group.userNetBalance.abs() < 0.01;

    if (!settled) {
      if (group.userNetBalance > 0) {
        balanceText = 'You are owed ₹${group.userNetBalance.toStringAsFixed(2)}';
        positive = true;
      } else {
        balanceText = 'You owe ₹${group.userNetBalance.abs().toStringAsFixed(2)}';
        positive = false;
      }
    }

    // Generate avatar initials
    final List<String> avatars = group.members.map((m) {
      if (m.userId == currentUserId) return 'You';
      return m.profile?.initials ?? 'M';
    }).toList();

    if (avatars.isEmpty) avatars.add('You');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupLedgerScreen(
                groupName: group.name,
                groupIcon: group.iconData,
                groupId: group.id,
              ),
            ),
          );
          _loadData();
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag + icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                group.iconData,
                                size: 12,
                                color: onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                group.currency,
                                style: const TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.45,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      group.iconData,
                      size: 21,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Spend + balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Group Total Spend',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.3,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${group.totalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: settled
                              ? secondaryContainer
                              : positive
                                  ? primaryFixed
                                  : errorContainer,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              settled
                                  ? Icons.check_circle_outline
                                  : positive
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                              size: 13,
                              color: settled
                                  ? onSurfaceVariant
                                  : positive
                                      ? onPrimaryFixed
                                      : error,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                settled
                                    ? 'All settled up'
                                    : (balanceText ?? ''),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: settled
                                      ? onSurfaceVariant
                                      : positive
                                          ? onPrimaryFixed
                                          : error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Member Avatars
              Row(
                children: [
                  _buildAvatarStack(avatars),
                  const SizedBox(width: 8),
                  Text(
                    '${group.members.length} members',
                    style: const TextStyle(
                      fontSize: 11,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR STACK
  // ============================================================
  Widget _buildAvatarStack(List<String> avatars) {
    final displayAvatars = avatars.take(4).toList();
    return SizedBox(
      height: 30,
      width: displayAvatars.length * 20.0 + 12,
      child: Stack(
        children: List.generate(
          displayAvatars.length,
          (index) {
            final avatar = displayAvatars[index];
            return Positioned(
              left: index * 20.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: index == displayAvatars.length - 1
                      ? primary
                      : secondaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: surfaceContainerLowest,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  avatar,
                  style: TextStyle(
                    fontSize: avatar.length > 2 ? 9 : 10,
                    fontWeight: FontWeight.w600,
                    color: index == displayAvatars.length - 1
                        ? Colors.white
                        : onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // RECENT EXPENSES
  // ============================================================
  Widget _buildRecentExpensesHeader() {
    return const Row(
      children: [
        Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    if (_recentExpenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No expenses recorded yet',
            style: TextStyle(fontSize: 13, color: onSurfaceVariant),
          ),
        ),
      );
    }

    final currentUserId = _supabaseService.currentProfile?.id ?? '00000000-0000-0000-0000-000000000001';

    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(_recentExpenses.length, (index) {
          final exp = _recentExpenses[index];
          final isPayer = exp.paidBy == currentUserId;
          final payerName = isPayer ? 'You' : (exp.payerProfile?.name ?? 'Member');

          double myShare = 0.0;
          for (final p in exp.participants) {
            if (p.userId == currentUserId) {
              myShare = p.shareAmount;
            }
          }

          final String amountText;
          final bool positive;

          if (isPayer) {
            final lent = exp.amount - myShare;
            amountText = 'you lent ₹${lent.toStringAsFixed(2)}';
            positive = true;
          } else {
            amountText = 'you owe ₹${myShare.toStringAsFixed(2)}';
            positive = false;
          }

          return _buildExpenseRow(
            icon: exp.categoryIcon,
            title: exp.description,
            subtitle: '${exp.groupName ?? 'Group'} • Paid by $payerName (₹${exp.amount.toStringAsFixed(2)})',
            date: _formatDate(exp.expenseDate),
            amount: amountText,
            positive: positive,
            showDivider: index != _recentExpenses.length - 1,
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  Widget _buildExpenseRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required String amount,
    required bool positive,
    bool showDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: surfaceContainerLow,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: onSurfaceVariant,
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
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: positive ? primary : error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}