import 'package:flutter/material.dart';
import '../groups/group_ledger_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ------------------------------------------------------------
  // Design system colors
  // ------------------------------------------------------------

  static const Color primary = Color(0xFF005048);
  static const Color primaryContainer = Color(0xFF006A60);
  static const Color primaryFixed = Color(0xFF9FF2E4);
  static const Color onPrimaryFixed = Color(0xFF00201C);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);
  static const Color surfaceContainerHigh = Color(0xFFE1EAE7);

  static const Color secondaryContainer = Color(0xFFCAE5E0);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

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
            onPressed: () {},
            icon: const Icon(Icons.search),
            iconSize: 25,
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

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupsHeader(),

                const SizedBox(height: 12),

                // Weekend Kyoto Trip
                _buildGroupCard(
                  context,
                  icon: Icons.flight_takeoff,
                  iconBackground: secondaryContainer,
                  title: 'Weekend Kyoto Trip',
                  category: 'Travel',
                  totalSpent: '₹680.00',
                  memberCount: '3 members',
                  avatars: const ['M', 'A', 'You'],
                  balance: 'Maya owes you ₹45.00',
                  positive: true,
                ),

                const SizedBox(height: 10),

                // Flatmates 402
                _buildGroupCard(
                  context,
                  icon: Icons.apartment,
                  iconBackground: const Color(0xFFCDE8E3),
                  title: 'Flatmates 402',
                  category: 'Home',
                  totalSpent: '₹1,420.00',
                  memberCount: '4 members',
                  avatars: const ['S', 'A', '+2'],
                  balance: 'You owe ₹80.00',
                  positive: false,
                ),

                const SizedBox(height: 10),

                // Movie Night
                _buildGroupCard(
                  context,
                  icon: Icons.local_movies,
                  iconBackground: surfaceContainerHigh,
                  title: 'Movie Night & Snacks',
                  category: 'Leisure',
                  totalSpent: '₹390.00',
                  memberCount: '3 members',
                  avatars: const ['D', 'C', 'You'],
                  settled: true,
                ),

                const SizedBox(height: 10),

                // Road Trip
                _buildGroupCard(
                  context,
                  icon: Icons.directions_car,
                  iconBackground: const Color(0xFFB1CCC7),
                  title: 'Road Trip & Gas',
                  category: 'Trip',
                  totalSpent: '₹1,080.00',
                  memberCount: '5 members',
                  avatars: const ['LE', 'RK', '+3'],
                  balance: 'Leo owes you ₹18.50',
                  positive: true,
                ),

                const SizedBox(height: 28),

                _buildRecentExpensesHeader(),

                const SizedBox(height: 12),

                _buildRecentExpenses(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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

        const Text(
          '(4)',
          style: TextStyle(
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        ),

        const Spacer(),

        TextButton.icon(
          onPressed: () {},
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
  // GROUP CARD
  // ============================================================

  Widget _buildGroupCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String category,
    required String totalSpent,
    required String memberCount,
    required List<String> avatars,
    String? balance,
    bool positive = false,
    bool settled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupLedgerScreen(
                groupName: title,
                groupIcon: icon,
              ),
            ),
          );
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
          child: Stack(
            children: [
              // Soft ambient circle
            //   Positioned(
            //     right: -38,
            //     top: -45,
            //     child: Container(
            //       width: 125,
            //       height: 125,
            //       decoration: BoxDecoration(
            //         color: iconBackground.withValues(alpha: 0.48),
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //   ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // Category + icon
                  // ------------------------------------------------

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
                                    icon,
                                    size: 12,
                                    color: onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    category.toUpperCase(),
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
                              title,
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
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: 21,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // Spend + balance
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                totalSpent,
                                style: const TextStyle(
                                  fontSize: 19,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
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

                                const SizedBox(width: 3),

                                Flexible(
                                  child: Text(
                                    settled
                                        ? 'All settled up'
                                        : balance ?? '',
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

                  // ------------------------------------------------
                  // Members
                  // ------------------------------------------------

                  Row(
                    children: [
                      _buildAvatarStack(avatars),

                      const SizedBox(width: 8),

                      Text(
                        memberCount,
                        style: const TextStyle(
                          fontSize: 11,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
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
    return SizedBox(
      height: 30,
      width: avatars.length * 20.0 + 12,
      child: Stack(
        children: List.generate(
          avatars.length,
          (index) {
            final avatar = avatars[index];

            return Positioned(
              left: index * 20.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: index == avatars.length - 1
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
                    color: index == avatars.length - 1
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
    return Row(
      children: [
        const Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: () {},
          child: const Text('View activity'),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _buildExpenseRow(
            icon: Icons.restaurant,
            title: 'Dinner at Izakaya',
            subtitle:
                'Weekend Kyoto Trip • Paid by You (₹120.00)',
            date: 'Yesterday',
            amount: 'you lent ₹80.00',
            positive: true,
          ),

          _buildExpenseRow(
            icon: Icons.wifi,
            title: 'High Speed Wifi Bill',
            subtitle:
                'Flatmates 402 • Paid by Sam (₹60.00)',
            date: '3 days ago',
            amount: 'you owe ₹15.00',
            positive: false,
          ),

          _buildExpenseRow(
            icon: Icons.theaters,
            title: 'Cinema IMAX Tickets',
            subtitle:
                '3 people • Paid by You (₹300.00)',
            date: 'May 12',
            amount: 'you lent ₹200.00',
            positive: true,
            showDivider: false,
          ),
        ],
      ),
    );
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