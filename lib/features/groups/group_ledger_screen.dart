import 'package:flutter/material.dart';
import '../expenses/add_expense_screen.dart';

class GroupLedgerScreen extends StatefulWidget {
  final String groupName;
  final IconData groupIcon;

  const GroupLedgerScreen({
    super.key,
    required this.groupName,
    required this.groupIcon,
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
  static const Color surfaceContainerHighest = Color(0xFFDBE4E2);

  static const Color secondaryContainer = Color(0xFFCAE5E0);
  static const Color onSecondaryContainer = Color(0xFF4E6763);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color tertiaryFixed = Color(0xFFCCE5FF);
  static const Color onTertiaryFixed = Color(0xFF001E31);

  static const Color secondary = Color(0xFF4A635F);

  // ============================================================
  // STATE
  // ============================================================

  int _selectedFilter = 0;

  final Set<String> _settledMembers = {};

  final List<String> _filters = [
    'All',
    'You paid',
    'Unsettled',
    'Entertainment',
    'Food & Drink',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            size: 27,
          ),
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
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              size: 24,
            ),
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
              child: const Center(
                child: Text(
                  'AR',
                  style: TextStyle(
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

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                14,
                4,
                14,
                90,
              ),
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

            // ====================================================
            // ADD EXPENSE
            // ====================================================

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
  //
  // This is the same visual style as the card from the Groups
  // screen, but its numbers belong ONLY to the current group.
  // ============================================================

  Widget _buildGroupPositionCard() {
    final details = _groupDetails();

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
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
                      details.activeStatus,
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

          // ------------------------------------------------------
          // MAIN BALANCE
          // ------------------------------------------------------

          Text(
            details.netPositive
                ? 'You are owed'
                : 'You owe',
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
                details.netAmount,
                style: TextStyle(
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: details.netPositive
                      ? primary
                      : error,
                ),
              ),

              const SizedBox(width: 7),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  details.balanceDescription,
                  style: const TextStyle(
                    fontSize: 10,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // TWO BALANCE CARDS
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _buildBalanceSummary(
                  icon: Icons.arrow_downward,
                  label: 'You owe',
                  amount: details.youOwe,
                  positive: false,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildBalanceSummary(
                  icon: Icons.arrow_upward,
                  label: 'You are owed',
                  amount: details.youAreOwed,
                  positive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // ACTIONS
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _buildPrimaryAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Settle All',
                  onTap: () {
                    _showSettleAllDialog();
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildSecondaryAction(
                  icon: Icons.file_download_outlined,
                  label: 'Export Sheet',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BALANCE SUMMARY
  // ============================================================

  Widget _buildBalanceSummary({
    required IconData icon,
    required String label,
    required String amount,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: positive ? primary : error,
              ),

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

  // ============================================================
  // PRIMARY ACTION
  // ============================================================

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
              Icon(
                icon,
                size: 15,
                color: Colors.white,
              ),
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

  // ============================================================
  // SECONDARY ACTION
  // ============================================================

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
              Icon(
                icon,
                size: 15,
                color: onSurfaceVariant,
              ),
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
  // GROUP DATA
  // ============================================================

  _GroupDetails _groupDetails() {
    switch (widget.groupName) {
      case 'Weekend Kyoto Trip':
        return const _GroupDetails(
          netPositive: true,
          netAmount: '₹45.00',
          youOwe: '₹0.00',
          youAreOwed: '₹45.00',
          balanceDescription: 'from 1 member',
          memberCount: 3,
          totalSpent: '₹680.00',
          category: 'Travel',
          activeStatus: 'Settlements Active',
        );

      case 'Flatmates 402':
        return const _GroupDetails(
          netPositive: false,
          netAmount: '₹80.00',
          youOwe: '₹80.00',
          youAreOwed: '₹0.00',
          balanceDescription: 'to 2 members',
          memberCount: 4,
          totalSpent: '₹1,420.00',
          category: 'Home',
          activeStatus: 'Settlements Active',
        );

      case 'Movie Night & Snacks':
        return const _GroupDetails(
          netPositive: true,
          netAmount: '₹120.00',
          youOwe: '₹0.00',
          youAreOwed: '₹120.00',
          balanceDescription: 'from 2 members',
          memberCount: 3,
          totalSpent: '₹390.00',
          category: 'Leisure',
          activeStatus: 'Settlements Active',
        );

      case 'Road Trip & Gas':
        return const _GroupDetails(
          netPositive: true,
          netAmount: '₹18.50',
          youOwe: '₹0.00',
          youAreOwed: '₹18.50',
          balanceDescription: 'from 1 member',
          memberCount: 5,
          totalSpent: '₹1,080.00',
          category: 'Trip',
          activeStatus: 'Settlements Active',
        );

      default:
        return const _GroupDetails(
          netPositive: true,
          netAmount: '₹0.00',
          youOwe: '₹0.00',
          youAreOwed: '₹0.00',
          balanceDescription: 'no outstanding balance',
          memberCount: 0,
          totalSpent: '₹0.00',
          category: 'Group',
          activeStatus: 'Settlements Active',
        );
    }
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

              const Text(
                '3 of 4 involved',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 9),

        _buildMemberBalanceCard(
          name: 'Alex Rivera',
          avatar: 'A',
          avatarColor: const Color(0xFFBFA77D),
          amount: 'Owes you ₹70.00',
          settled: _settledMembers.contains('Alex Rivera'),
        ),

        const SizedBox(height: 8),

        _buildMemberBalanceCard(
          name: 'Maya Lin',
          avatar: 'M',
          avatarColor: const Color(0xFF879B8C),
          amount: 'Owes you ₹50.00',
          settled: _settledMembers.contains('Maya Lin'),
        ),

        const SizedBox(height: 8),

        _buildMemberBalanceCard(
          name: 'Sam Chen',
          avatar: 'S',
          avatarColor: const Color(0xFF69716E),
          amount: 'Settled up · ₹0.00',
          settled: true,
        ),
      ],
    );
  }

  Widget _buildMemberBalanceCard({
    required String name,
    required String avatar,
    required Color avatarColor,
    required String amount,
    required bool settled,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  settled
                      ? 'Settled up · ₹0.00'
                      : amount,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        settled ? onSurfaceVariant : primary,
                  ),
                ),
              ],
            ),
          ),

          if (settled)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _smallActionButton(
                  label: 'Remind',
                  icon: Icons.send_outlined,
                  onTap: () {},
                  filled: true,
                ),

                const SizedBox(width: 6),

                _smallActionButton(
                  label: 'Settle',
                  icon: Icons.check,
                  onTap: () {
                    setState(() {
                      _settledMembers.add(name);
                    });
                  },
                  filled: false,
                ),
              ],
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
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            color: filled
                ? primaryFixed
                : surfaceContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: filled
                    ? onPrimaryFixed
                    : onSurfaceVariant,
              ),

              const SizedBox(width: 3),

              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? onPrimaryFixed
                      : onSurfaceVariant,
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

              const Text(
                'October 2024',
                style: TextStyle(
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
            separatorBuilder: (_, _) =>
                const SizedBox(width: 6),
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

        _buildExpenseCard(
          icon: Icons.confirmation_number,
          iconBackground: secondaryContainer,
          iconColor: onSecondaryContainer,
          title: 'IMAX 3D Movie Tickets',
          amount: '+₹200.00',
          amountColor: primary,
          payer: 'You',
          total: '₹300.00 total',
          split: 'Split 3 ways',
          balanceText: 'You lent ₹200.00 (₹100/ea)',
          balanceIcon: Icons.arrow_outward,
          balanceColor: primary,
          balanceBackground: surfaceContainer,
          time: 'Today, 8:15 PM',
        ),

        const SizedBox(height: 8),

        _buildExpenseCard(
          icon: Icons.fastfood,
          iconBackground: tertiaryFixed,
          iconColor: onTertiaryFixed,
          title: 'Popcorn, Soda & Nachos Combo',
          amount: '-₹30.00',
          amountColor: error,
          payer: 'Alex Rivera',
          total: '₹90.00 total',
          split: 'Split 3 ways',
          balanceText: 'You owe ₹30.00',
          balanceIcon: Icons.call_made,
          balanceColor: error,
          balanceBackground:
              errorContainer.withValues(alpha: 0.4),
          time: 'Today, 7:45 PM',
        ),

        const SizedBox(height: 8),

        _buildExpenseCard(
          icon: Icons.local_taxi,
          iconBackground: surfaceContainerHighest,
          iconColor: onSurfaceVariant,
          title: 'Uber Ride Home',
          amount: '₹45.00',
          amountColor: onSurfaceVariant,
          payer: 'Maya Lin',
          total: null,
          split: 'Split equally',
          balanceText: 'Settled on Oct 14',
          balanceIcon: Icons.check_circle_outline,
          balanceColor: secondary,
          balanceBackground: Colors.transparent,
          time: 'Oct 14, 11:20 PM',
          settled: true,
        ),
      ],
    );
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? secondaryContainer
              : surfaceContainerLow,
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
                color: selected
                    ? onSecondaryContainer
                    : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPENSE CARD
  // ============================================================

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
    bool settled = false,
  }) {
    return Opacity(
      opacity: settled ? 0.88 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceContainerLow,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        const TextSpan(
                          text: 'Paid by ',
                        ),
                        TextSpan(
                          text: payer,
                          style: const TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (total != null)
                          TextSpan(
                            text: ' ($total)',
                          ),
                        TextSpan(
                          text: ' · $split',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: balanceBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                balanceIcon,
                                size: 13,
                                color: balanceColor,
                              ),

                              const SizedBox(width: 3),

                              Flexible(
                                child: Text(
                                  balanceText,
                                  overflow:
                                      TextOverflow.ellipsis,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                groupName: widget.groupName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
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
              Icon(
                Icons.add,
                size: 21,
                color: onPrimaryFixed,
              ),
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
            'This will start the settlement process for '
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
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// GROUP DETAILS
// ================================================================

class _GroupDetails {
  final bool netPositive;
  final String netAmount;
  final String youOwe;
  final String youAreOwed;
  final String balanceDescription;
  final int memberCount;
  final String totalSpent;
  final String category;
  final String activeStatus;

  const _GroupDetails({
    required this.netPositive,
    required this.netAmount,
    required this.youOwe,
    required this.youAreOwed,
    required this.balanceDescription,
    required this.memberCount,
    required this.totalSpent,
    required this.category,
    required this.activeStatus,
  });
}