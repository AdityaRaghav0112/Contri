import 'package:flutter/material.dart';

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
  // ------------------------------------------------------------
  // Design system colors
  // ------------------------------------------------------------

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);
  static const Color surfaceContainerHighest = Color(0xFFDBE4E2);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color primary = Color(0xFF005048);
  static const Color primaryFixed = Color(0xFF9FF2E4);
  static const Color onPrimaryFixed = Color(0xFF00201C);

  static const Color secondaryContainer = Color(0xFFCAE5E0);
  static const Color onSecondaryContainer = Color(0xFF4E6763);

  static const Color tertiaryFixed = Color(0xFFCCE5FF);
  static const Color onTertiaryFixed = Color(0xFF001E31);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color secondary = Color(0xFF4A635F);

  // ------------------------------------------------------------
  // Filter state
  // ------------------------------------------------------------

  int _selectedFilter = 0;
  final Set<String> _settledMembers = <String>{};

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

      // --------------------------------------------------------
      // App bar
      // --------------------------------------------------------

      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 28,
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

            const SizedBox(width: 8),

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
              size: 23,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFCAE5E0),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AR',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // --------------------------------------------------------
      // Main content
      // --------------------------------------------------------

      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                88,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGroupSummaryCard(),

                  const SizedBox(height: 12),

                  _buildMemberBalances(),

                  const SizedBox(height: 16),

                  _buildActivityLedger(),
                ],
              ),
            ),

            // --------------------------------------------------
            // Add expense FAB
            // --------------------------------------------------

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
  // GROUP SUMMARY CARD
  // ============================================================

  Widget _buildGroupSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Ambient background circle
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------
              // Category + settings
              // ----------------------------------------------

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
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryContainer,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.theater_comedy,
                                size: 12,
                                color: onSecondaryContainer,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'WEEKEND & LEISURE',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w600,
                                  color: onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Movie & Weekend Getaway',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  IconButton(
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 21,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------
              // Financial status
              // ----------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group Total Spend',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.3,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '\$390.00',
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryFixed,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: 14,
                                color: onPrimaryFixed,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'You are owed \$120.00',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onPrimaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------
              // Member avatars
              // ----------------------------------------------

              _buildMemberAvatarStack(),

              const SizedBox(height: 12),

              // ----------------------------------------------
              // Settle button
              // ----------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Settle Up',
                      icon: Icons.payments_outlined,
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MEMBER AVATARS
  // ============================================================

  Widget _buildMemberAvatarStack() {
    final avatars = [
      ('You', const Color(0xFFE7C8A8)),
      ('A', const Color(0xFFC8B58E)),
      ('M', const Color(0xFF73877D)),
      ('S', const Color(0xFF59655E)),
    ];

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 36,
          child: Stack(
            children: [
              for (int i = 0; i < avatars.length; i++)
                Positioned(
                  left: i * 22.0,
                  top: 1,
                  child: _buildAvatar(
                    label: avatars[i].$1,
                    backgroundColor: avatars[i].$2,
                    size: 34,
                    showOnline: i == 0,
                  ),
                ),

              Positioned(
                left: 78,
                top: 1,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: surfaceContainerLow,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 16,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({
    required String label,
    required Color backgroundColor,
    required double size,
    bool showOnline = false,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: surfaceContainerLow,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: onSurface,
                fontSize: size * 0.30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (showOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: surfaceContainerLow,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member Balances',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),

              Text(
                '3 of 4 involved',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        _buildBalanceCard(
          name: 'Alex Rivera',
          amount: 'Owes you \$70.00',
          avatarLabel: 'A',
          avatarColor: const Color(0xFFBFA77D),
          status: _balanceStatusFor('Alex Rivera'),
        ),

        const SizedBox(height: 8),

        _buildBalanceCard(
          name: 'Maya Lin',
          amount: 'Owes you \$50.00',
          avatarLabel: 'M',
          avatarColor: const Color(0xFF879B8C),
          status: _balanceStatusFor('Maya Lin'),
        ),

        const SizedBox(height: 8),

        _buildBalanceCard(
          name: 'Sam Chen',
          amount: 'Settled up · \$0.00',
          avatarLabel: 'S',
          avatarColor: const Color(0xFF69716E),
          status: BalanceStatus.settled,
        ),
      ],
    );
  }

  BalanceStatus _balanceStatusFor(String name) {
    return _settledMembers.contains(name)
        ? BalanceStatus.settled
        : BalanceStatus.owes;
  }

  Widget _buildBalanceCard({
    required String name,
    required String amount,
    required String avatarLabel,
    required Color avatarColor,
    required BalanceStatus status,
  }) {
    final bool settled = status == BalanceStatus.settled;

    return Dismissible(
      key: ValueKey(name),
      direction: settled
          ? DismissDirection.none
          : DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        if (!settled) {
          setState(() {
            _settledMembers.add(name);
          });
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18),
        decoration: BoxDecoration(
          color: primaryFixed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: onPrimaryFixed, size: 20),
            SizedBox(width: 6),
            Text(
              'Settle balance',
              style: TextStyle(
                color: onPrimaryFixed,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: settled
              ? surfaceContainerLow.withValues(alpha: 0.6)
              : surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildAvatar(
              label: avatarLabel,
              backgroundColor: avatarColor,
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: settled
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    settled ? 'Settled up · \$0.00' : amount,
                    style: TextStyle(
                      fontSize: 11,
                      color: settled ? onSurfaceVariant : primary,
                      fontWeight: settled
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildBalanceAction(status),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(BalanceStatus status) {
    switch (status) {
      case BalanceStatus.owes:
        return Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: primaryFixed,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.send_outlined,
                size: 14,
                color: onPrimaryFixed,
              ),
              SizedBox(width: 4),
              Text(
                'Remind',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: onPrimaryFixed,
                ),
              ),
            ],
          ),
        );

      case BalanceStatus.settled:
        return Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text(
              'All clear',
              style: TextStyle(
                fontSize: 10,
                color: onSurfaceVariant,
              ),
            ),
          ),
        );
    }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Ledger',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),

              const Text(
                'October 2024',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // ----------------------------------------------
        // Horizontal filters
        // ----------------------------------------------

        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 1),
            itemCount: _filters.length,
            separatorBuilder: (_, _) {
              return const SizedBox(width: 6);
            },
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

        const SizedBox(height: 6),

        // ----------------------------------------------
        // Expenses
        // ----------------------------------------------

        _buildExpenseCard(
          icon: Icons.confirmation_number,
          iconBackground: secondaryContainer,
          iconColor: onSecondaryContainer,
          title: 'IMAX 3D Movie Tickets',
          amount: '+\$200.00',
          amountColor: primary,
          payer: 'You',
          total: '\$300.00 total',
          split: 'Split 3 ways',
          balanceText: 'You lent \$200.00 (\$100/ea)',
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
          amount: '-\$30.00',
          amountColor: error,
          payer: 'Alex Rivera',
          total: '\$90.00 total',
          split: 'Split 3 ways',
          balanceText: 'You owe \$30.00',
          balanceIcon: Icons.call_made,
          balanceColor: error,
          balanceBackground: errorContainer.withValues(alpha: 0.4),
          time: 'Today, 7:45 PM',
        ),

        const SizedBox(height: 8),

        _buildExpenseCard(
          icon: Icons.local_taxi,
          iconBackground: surfaceContainerHighest,
          iconColor: onSurfaceVariant,
          title: 'Uber Ride Home',
          amount: '\$45.00',
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 11),
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
                letterSpacing: 0.5,
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
      opacity: settled ? 0.9 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: settled
              ? surfaceContainerLow.withValues(alpha: 0.6)
              : surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------
            // Expense icon
            // --------------------------------------------

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

            // --------------------------------------------
            // Expense content
            // --------------------------------------------

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

                  // ----------------------------------------
                  // Balance / settlement row
                  // ----------------------------------------

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
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.4,
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
                            letterSpacing: 0.4,
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
  // ADD EXPENSE
  // ============================================================

  Widget _buildAddExpenseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: primaryFixed,
            borderRadius: BorderRadius.circular(14),
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
              SizedBox(width: 8),
              Text(
                'Add expense',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: onPrimaryFixed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// BALANCE STATUS
// ================================================================

enum BalanceStatus {
  owes,
  settled,
}