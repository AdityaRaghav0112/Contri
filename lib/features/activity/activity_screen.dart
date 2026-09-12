import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // ------------------------------------------------------------
  // Colors & Tokens
  // ------------------------------------------------------------
  static const Color primary = Color(0xFF005048);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEDF6F3);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);

  static const Color secondaryContainer = Color(0xFFCAE5E0);
  static const Color onSecondaryContainer = Color(0xFF4E6763);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);
  static const Color outline = Color(0xFF6E7977);

  static const Color error = Color(0xFFBA1A1A);

  // ------------------------------------------------------------
  // State
  // ------------------------------------------------------------
  int _selectedFilter = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  final List<String> _filters = [
    'All',
    'You paid',
    'You were added',
    'Settlements',
    'Movies',
    'Food',
    'Travel',
  ];

  late List<_ActivitySection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      _ActivitySection(
        period: 'Today',
        activities: [
          _ActivityItem(
            title: 'Movie: Dune IMAX 3D',
            group: 'Movie Night & Snacks',
            category: 'Movies',
            categoryIcon: Icons.local_movies_outlined,
            categoryColor: const Color(0xFF6B8E8E),
            date: 'Today, 8:15 PM',
            totalAmount: 300.00,
            userShare: 200.00,
            isUserPayer: true,
            payerName: 'You',
            participantsCount: 3,
            tag: '#imax',
            participants: const [
              'You (Paid ₹300.00)',
              'Alex Rivera (Share ₹100.00)',
              'Maya Lin (Share ₹100.00)',
            ],
          ),
          _ActivityItem(
            title: 'Dinner at Truffles Cafe',
            group: 'Flatmates 402',
            category: 'Food',
            categoryIcon: Icons.restaurant_outlined,
            categoryColor: const Color(0xFFBFA77D),
            date: 'Today, 2:40 PM',
            totalAmount: 850.00,
            userShare: -212.50,
            isUserPayer: false,
            payerName: 'Jordan Blake',
            participantsCount: 4,
            tag: '#dinner',
            participants: const [
              'Jordan Blake (Paid ₹850.00)',
              'You (Share ₹212.50)',
              'Alex Rivera (Share ₹212.50)',
              'Sam Chen (Share ₹212.50)',
            ],
          ),
        ],
      ),
      _ActivitySection(
        period: 'Yesterday',
        activities: [
          _ActivityItem(
            title: 'Settled with Alex Rivera',
            group: 'Direct Settlement',
            category: 'Settlement',
            categoryIcon: Icons.check_circle_outline,
            categoryColor: primary,
            date: 'Yesterday, 9:20 PM',
            totalAmount: 70.00,
            userShare: 70.00,
            isUserPayer: false,
            isSettlement: true,
            payerName: 'Alex Rivera',
            participantsCount: 2,
            tag: '#settle',
            participants: const [
              'Alex Rivera (Paid ₹70.00)',
              'You (Received ₹70.00)',
            ],
          ),
          _ActivityItem(
            title: 'Uber to Bangalore Airport',
            group: 'Road Trip & Gas',
            category: 'Travel',
            categoryIcon: Icons.directions_car_outlined,
            categoryColor: const Color(0xFF5A7B8C),
            date: 'Yesterday, 11:15 AM',
            totalAmount: 480.00,
            userShare: -120.00,
            isUserPayer: false,
            payerName: 'Elena Rostova',
            participantsCount: 4,
            tag: '#uber',
            participants: const [
              'Elena Rostova (Paid ₹480.00)',
              'You (Share ₹120.00)',
              'Sam Chen (Share ₹120.00)',
              'David Kim (Share ₹120.00)',
            ],
          ),
        ],
      ),
      _ActivitySection(
        period: 'Earlier this month',
        activities: [
          _ActivityItem(
            title: 'Bullet Train Tickets',
            group: 'Weekend Kyoto Trip',
            category: 'Travel',
            categoryIcon: Icons.flight_takeoff_outlined,
            categoryColor: const Color(0xFF879B8C),
            date: 'Sep 08, 10:30 AM',
            totalAmount: 680.00,
            userShare: 453.33,
            isUserPayer: true,
            payerName: 'You',
            participantsCount: 3,
            tag: '#kyoto',
            participants: const [
              'You (Paid ₹680.00)',
              'Maya Lin (Share ₹226.67)',
              'Alex Rivera (Share ₹226.67)',
            ],
          ),
          _ActivityItem(
            title: 'Monthly High-Speed WiFi',
            group: 'Flatmates 402',
            category: 'Home',
            categoryIcon: Icons.wifi_outlined,
            categoryColor: const Color(0xFF9E829C),
            date: 'Sep 03, 4:00 PM',
            totalAmount: 320.00,
            userShare: -80.00,
            isUserPayer: false,
            payerName: 'Sam Chen',
            participantsCount: 4,
            tag: '#wifi',
            participants: const [
              'Sam Chen (Paid ₹320.00)',
              'You (Share ₹80.00)',
              'Alex Rivera (Share ₹80.00)',
              'Jordan Blake (Share ₹80.00)',
            ],
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Filter Logic
  // ------------------------------------------------------------
  List<_ActivitySection> get _filteredSections {
    final List<_ActivitySection> results = [];

    for (final section in _sections) {
      final matchingActivities = section.activities.where((act) {
        // Search text filter
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          final matchTitle = act.title.toLowerCase().contains(q);
          final matchGroup = act.group.toLowerCase().contains(q);
          final matchPayer = act.payerName.toLowerCase().contains(q);
          final matchTag = act.tag.toLowerCase().contains(q);
          if (!matchTitle && !matchGroup && !matchPayer && !matchTag) {
            return false;
          }
        }

        // Selected pill filter
        switch (_selectedFilter) {
          case 1: // You paid
            return act.isUserPayer && !act.isSettlement;
          case 2: // You were added
            return !act.isUserPayer && !act.isSettlement;
          case 3: // Settlements
            return act.isSettlement;
          case 4: // Movies
            return act.category == 'Movies';
          case 5: // Food
            return act.category == 'Food';
          case 6: // Travel
            return act.category == 'Travel';
          default:
            return true;
        }
      }).toList();

      if (matchingActivities.isNotEmpty) {
        results.add(
          _ActivitySection(
            period: section.period,
            activities: matchingActivities,
          ),
        );
      }
    }

    return results;
  }

  // ------------------------------------------------------------
  // Transaction Details Modal
  // ------------------------------------------------------------
  void _showActivityDetails(_ActivityItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: outline.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.categoryIcon,
                        color: primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.group} • ${item.date}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL EXPENSE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${item.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'YOUR SHARE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.isSettlement
                                ? '✓ Settled'
                                : item.userShare >= 0
                                    ? '+ ₹${item.userShare.toStringAsFixed(2)}'
                                    : '- ₹${item.userShare.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: item.isSettlement || item.userShare >= 0
                                  ? primary
                                  : error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (item.tag.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.tag,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Paid by ${item.payerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Participants & Shares',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...item.participants.map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          p,
                          style: const TextStyle(
                            fontSize: 13,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt viewer will open next.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_outlined, size: 18),
                        label: const Text('View Receipt'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI Builder
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
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
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Activity',
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
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity ledger export ready.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
            iconSize: 24,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showSearch) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Search activity by name, group, or tag...',
                    hintStyle: TextStyle(fontSize: 13, color: outline),
                    prefixIcon: Icon(Icons.search, size: 20, color: primary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // Activity Metric Overview Card
            _buildActivityOverviewCard(),

            const SizedBox(height: 18),

            // Filter Tabs
            _buildFilterPills(),

            const SizedBox(height: 14),

            // Activity Grouped Sections
            if (_filteredSections.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.history_outlined,
                      size: 40,
                      color: outline,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No activities found in this filter',
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._filteredSections.map(
                (section) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        top: 10,
                        bottom: 8,
                      ),
                      child: Text(
                        section.period,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: outline,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    ...section.activities.map(
                      (act) => _buildActivityCard(act),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OVERVIEW CARD
  // ------------------------------------------------------------
  Widget _buildActivityOverviewCard() {
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
                'MONTHLY LEDGER',
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
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Sep 2026',
                  style: TextStyle(
                    fontSize: 10,
                    color: onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Month Volume',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '₹2,700.00',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: primary,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'across 6 transactions',
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You paid / fronted',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '₹980.00',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Your actual net share',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '₹412.50',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER PILLS
  // ------------------------------------------------------------
  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? primary : surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTIVITY CARD
  // ------------------------------------------------------------
  Widget _buildActivityCard(_ActivityItem act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActivityDetails(act),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    act.categoryIcon,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Description, group, tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        act.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              act.group,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: outline,
                              ),
                            ),
                          ),
                          if (act.tag.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: secondaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                act.tag,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        act.date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: outline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Share breakdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${act.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act.isSettlement
                          ? '✓ Settled'
                          : act.isUserPayer
                              ? '+ ₹${act.userShare.toStringAsFixed(2)} back'
                              : '- ₹${act.userShare.abs().toStringAsFixed(2)} share',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: act.isSettlement || act.isUserPayer
                            ? primary
                            : error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivitySection {
  final String period;
  final List<_ActivityItem> activities;

  _ActivitySection({
    required this.period,
    required this.activities,
  });
}

class _ActivityItem {
  final String title;
  final String group;
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final String date;
  final double totalAmount;
  final double userShare;
  final bool isUserPayer;
  final bool isSettlement;
  final String payerName;
  final int participantsCount;
  final String tag;
  final List<String> participants;

  _ActivityItem({
    required this.title,
    required this.group,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
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