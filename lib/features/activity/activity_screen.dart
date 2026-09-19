import 'package:flutter/material.dart';
import '../../core/repositories/activity_repository.dart';

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
  // State & Repositories
  // ------------------------------------------------------------
  final ActivityRepository _activityRepository = ActivityRepository();

  int _selectedFilter = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isLoading = true;

  final List<String> _filters = [
    'All',
    'You paid',
    'You were added',
    'Settlements',
    'Food',
    'Movies',
    'Travel',
  ];

  List<ActivitySection> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
    });

    final sections = await _activityRepository.getActivityFeed();

    if (!mounted) return;
    setState(() {
      _sections = sections;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Metrics Calculations
  // ------------------------------------------------------------
  List<ActivityItem> get _allActivities =>
      _sections.expand((s) => s.activities).toList();

  double get _totalVolume =>
      _allActivities.fold(0.0, (sum, a) => sum + a.totalAmount);

  double get _totalFronted => _allActivities
      .where((a) => a.isUserPayer && !a.isSettlement)
      .fold(0.0, (sum, a) => sum + a.totalAmount);

  double get _totalNetShare => _allActivities
      .where((a) => !a.isSettlement)
      .fold(0.0, (sum, a) => sum + (a.isUserPayer ? (a.totalAmount - a.userShare) : a.userShare.abs()));

  // ------------------------------------------------------------
  // Filter Logic
  // ------------------------------------------------------------
  List<ActivitySection> get _filteredSections {
    final List<ActivitySection> results = [];

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
          case 4: // Food
            return act.category.toLowerCase().contains('food') || act.category.toLowerCase().contains('restaurant');
          case 5: // Movies
            return act.category.toLowerCase().contains('movie') || act.category.toLowerCase().contains('cinema');
          case 6: // Travel
            return act.category.toLowerCase().contains('travel') || act.category.toLowerCase().contains('trip');
          default:
            return true;
        }
      }).toList();

      if (matchingActivities.isNotEmpty) {
        results.add(
          ActivitySection(
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
  void _showActivityDetails(ActivityItem item) {
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
                            'YOUR SHARE / NET',
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
            onPressed: _loadActivity,
            icon: const Icon(Icons.refresh),
            iconSize: 22,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActivity,
        color: primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    _buildActivityOverviewCard(),
                    const SizedBox(height: 18),
                    _buildFilterPills(),
                    const SizedBox(height: 14),

                    if (_filteredSections.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: surfaceLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
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
                'LIVE TRANSACTION METRICS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Active Ledger',
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
            'Total Volume Tracked',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_totalVolume.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: primary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'across ${_allActivities.length} transactions',
                  style: const TextStyle(
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
                    children: [
                      const Text(
                        'You fronted / paid',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${_totalFronted.toStringAsFixed(2)}',
                        style: const TextStyle(
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
                    children: [
                      const Text(
                        'Your actual share',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${_totalNetShare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
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
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? primary : surfaceContainerLow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTIVITY CARD
  // ------------------------------------------------------------
  Widget _buildActivityCard(ActivityItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showActivityDetails(item),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.categoryIcon, color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.group} • Paid by ${item.payerName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: outline),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.isSettlement
                      ? '✓ Settled'
                      : item.userShare >= 0
                          ? '+ ₹${item.userShare.toStringAsFixed(2)}'
                          : '- ₹${item.userShare.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: item.isSettlement || item.userShare >= 0
                        ? primary
                        : error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date,
                  style: const TextStyle(fontSize: 10, color: outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}