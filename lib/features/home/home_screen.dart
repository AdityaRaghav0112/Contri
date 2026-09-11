import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primary = Color(0xFF005048);
  static const Color primaryContainer = Color(0xFF006A60);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);
  static const Color surfaceContainerHigh = Color(0xFFE1EAE7);
  static const Color secondaryContainer = Color(0xFFCAE5E0);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color error = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,

      appBar: AppBar(
        backgroundColor: surface,
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

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _buildBalanceOverview(),

                const SizedBox(height: 28),

                _buildGroupsHeader(),

                const SizedBox(height: 12),

                _buildGroupCard(
                  icon: Icons.flight_takeoff,
                  iconBackground: secondaryContainer,
                  title: 'Weekend Kyoto Trip',
                  category: 'Travel',
                  subtitle:
                      '3 members: You, Maya, Alex • ₹680 spent',
                  avatars: const ['M', 'A', 'You'],
                  balance: 'Maya owes you ₹45.00',
                  positive: true,
                ),

                const SizedBox(height: 10),

                _buildGroupCard(
                  icon: Icons.apartment,
                  iconBackground: const Color(0xFFCDE8E3),
                  title: 'Flatmates 402',
                  category: 'Home',
                  subtitle:
                      '4 members • Rent & Utilities • ₹1,420 spent',
                  avatars: const ['S', 'A', '+2'],
                  balance: 'You owe ₹80.00',
                  positive: false,
                ),

                const SizedBox(height: 10),

                _buildGroupCard(
                  icon: Icons.local_movies,
                  iconBackground: surfaceContainerHigh,
                  title: 'Movie Night & Snacks',
                  category: 'Leisure',
                  subtitle: '3 members: Dave, Chloe, You',
                  avatars: const ['D', 'C'],
                  settled: true,
                ),

                const SizedBox(height: 10),

                _buildGroupCard(
                  icon: Icons.directions_car,
                  iconBackground: const Color(0xFFB1CCC7),
                  title: 'Road Trip & Gas',
                  category: 'Trip',
                  subtitle: '5 members • Highway split',
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

  Widget _buildBalanceOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'NET POSITION',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
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
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 15,
                      color: onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Settlements Active',
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Overall, you are owed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: onSurface,
            ),
          ),

          const SizedBox(height: 2),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹145.50',
                style: TextStyle(
                  fontSize: 45,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  letterSpacing: -1,
                ),
              ),

              SizedBox(width: 7),

              Text(
                'across 4 groups',
                style: TextStyle(
                  fontSize: 12,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildMiniBalance(
                  icon: Icons.arrow_downward,
                  label: 'You owe',
                  amount: '₹32.00',
                  color: error,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildMiniBalance(
                  icon: Icons.arrow_upward,
                  label: 'You are owed',
                  amount: '₹177.50',
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                  ),
                  label: const Text('Settle All'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.file_download_outlined,
                    size: 18,
                  ),
                  label: const Text('Export Sheet'),
                  style: FilledButton.styleFrom(
                    backgroundColor: surfaceContainerHigh,
                    foregroundColor: onSurface,
                    minimumSize: const Size(0, 48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalance({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),

              const SizedBox(width: 5),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildGroupCard({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String category,
    required String subtitle,
    required List<String> avatars,
    String? balance,
    bool positive = false,
    bool settled = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x1ABEC9C6),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 27,
                  color: onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildAvatarStack(avatars),

              const Spacer(),

              if (settled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 15,
                        color: onSurfaceVariant,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'All settled up',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  balance!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: positive ? primary : error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

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