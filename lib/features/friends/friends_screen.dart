import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
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
    'You are owed',
    'You owe',
    'Settled',
  ];

  // Friend sample model data
  late List<_FriendItem> _friends;

  @override
  void initState() {
    super.initState();
    _friends = [
      _FriendItem(
        name: 'Alex Rivera',
        avatar: 'A',
        avatarColor: const Color(0xFFBFA77D),
        email: 'alex.rivera@email.com',
        phone: '+91 98765 43210',
        sharedGroups: const ['Flatmates 402', 'Movie Night & Snacks'],
        balance: 70.00,
        isOwed: true,
        recentActivity: 'Owes you for Movie: Dune IMAX 3D',
      ),
      _FriendItem(
        name: 'Maya Lin',
        avatar: 'M',
        avatarColor: const Color(0xFF879B8C),
        email: 'maya.lin@email.com',
        phone: '+91 98123 45678',
        sharedGroups: const ['Weekend Kyoto Trip', 'Movie Night & Snacks'],
        balance: 50.00,
        isOwed: true,
        recentActivity: 'Owes you for Kyoto bullet train pass',
      ),
      _FriendItem(
        name: 'Jordan Blake',
        avatar: 'J',
        avatarColor: const Color(0xFF5A7B8C),
        email: 'jordan.b@email.com',
        phone: '+91 98234 56789',
        sharedGroups: const ['Flatmates 402'],
        balance: 45.00,
        isOwed: false,
        recentActivity: 'You owe for WiFi & Utility bill',
      ),
      _FriendItem(
        name: 'Sam Chen',
        avatar: 'S',
        avatarColor: const Color(0xFF69716E),
        email: 'sam.chen@email.com',
        phone: '+91 98345 67890',
        sharedGroups: const ['Flatmates 402', 'Road Trip & Gas'],
        balance: 0.00,
        isOwed: true,
        isSettled: true,
        recentActivity: 'Settled up 2 days ago',
      ),
      _FriendItem(
        name: 'Elena Rostova',
        avatar: 'E',
        avatarColor: const Color(0xFF9E829C),
        email: 'elena.r@email.com',
        phone: '+91 98456 78901',
        sharedGroups: const ['Road Trip & Gas'],
        balance: 50.00,
        isOwed: true,
        recentActivity: 'Owes you for Highway toll & fuel',
      ),
      _FriendItem(
        name: 'David Kim',
        avatar: 'D',
        avatarColor: const Color(0xFF7A8B7B),
        email: 'david.k@email.com',
        phone: '+91 98567 89012',
        sharedGroups: const ['Movie Night & Snacks'],
        balance: 0.00,
        isOwed: true,
        isSettled: true,
        recentActivity: 'Settled up last week',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Calculations
  // ------------------------------------------------------------
  double get _totalYouAreOwed {
    return _friends
        .where((f) => f.isOwed && !f.isSettled)
        .fold(0.0, (sum, f) => sum + f.balance);
  }

  double get _totalYouOwe {
    return _friends
        .where((f) => !f.isOwed && !f.isSettled)
        .fold(0.0, (sum, f) => sum + f.balance);
  }

  double get _netBalance => _totalYouAreOwed - _totalYouOwe;

  List<_FriendItem> get _filteredFriends {
    return _friends.where((f) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = f.name.toLowerCase().contains(q);
        final matchEmail = f.email.toLowerCase().contains(q);
        final matchGroup =
            f.sharedGroups.any((g) => g.toLowerCase().contains(q));
        if (!matchName && !matchEmail && !matchGroup) return false;
      }

      // Tab filter
      switch (_selectedFilter) {
        case 1: // You are owed
          return f.isOwed && !f.isSettled && f.balance > 0;
        case 2: // You owe
          return !f.isOwed && !f.isSettled && f.balance > 0;
        case 3: // Settled
          return f.isSettled || f.balance == 0;
        default:
          return true;
      }
    }).toList();
  }

  // ------------------------------------------------------------
  // Modals & Sheets
  // ------------------------------------------------------------
  void _showAddFriendDialog() {
    final nameController = TextEditingController();
    final emailPhoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Add a Friend',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(fontSize: 15, color: onSurface),
                decoration: InputDecoration(
                  labelText: 'Friend\'s Full Name',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  filled: true,
                  fillColor: surfaceLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailPhoneController,
                style: const TextStyle(fontSize: 15, color: onSurface),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  prefixIcon: const Icon(Icons.alternate_email, size: 20),
                  filled: true,
                  fillColor: surfaceLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _friends.insert(
                          0,
                          _FriendItem(
                            name: name,
                            avatar: name[0].toUpperCase(),
                            avatarColor: const Color(0xFF6B8E8E),
                            email: emailPhoneController.text.trim().isEmpty
                                ? '$name@contri.app'
                                : emailPhoneController.text.trim(),
                            phone: '+91 99000 11223',
                            sharedGroups: const ['General'],
                            balance: 0.0,
                            isOwed: true,
                            isSettled: true,
                            recentActivity: 'Just added as friend',
                          ),
                        );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name added to friends!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Friend',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFriendDetails(_FriendItem friend) {
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
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: friend.avatarColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        friend.avatar,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            friend.email,
                            style: const TextStyle(
                              fontSize: 13,
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
                            'NET BALANCE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            friend.isSettled
                                ? 'Settled up'
                                : friend.isOwed
                                    ? 'Owes you ₹${friend.balance.toStringAsFixed(2)}'
                                    : 'You owe ₹${friend.balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: friend.isSettled
                                  ? onSurfaceVariant
                                  : friend.isOwed
                                      ? primary
                                      : error,
                            ),
                          ),
                        ],
                      ),
                      if (!friend.isSettled)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              friend.isSettled = true;
                              friend.balance = 0.0;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Settled with ${friend.name}!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Settle Up'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Shared Groups',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: friend.sharedGroups.map((g) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 15,
                            color: primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            g,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  friend.recentActivity,
                  style: const TextStyle(
                    fontSize: 13,
                    color: onSurfaceVariant,
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
                Icons.people_alt_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Friends',
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
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add_alt_1_outlined),
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
                    hintText: 'Search friends by name, email, or group...',
                    hintStyle: TextStyle(fontSize: 13, color: outline),
                    prefixIcon: Icon(Icons.search, size: 20, color: primary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // Friends Overall Position Card
            _buildFriendsPositionCard(),

            const SizedBox(height: 18),

            // Filter Tabs
            _buildFilterPills(),

            const SizedBox(height: 14),

            // Friends List Header
            Row(
              children: [
                const Text(
                  'All Friends',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${_filteredFriends.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddFriendDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                  ),
                  label: const Text('Add Friend'),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Friends Cards List
            if (_filteredFriends.isEmpty)
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
                      Icons.person_search_outlined,
                      size: 40,
                      color: outline,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No friends found in this filter',
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
              ..._filteredFriends.map((f) => _buildFriendCard(f)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // POSITION CARD
  // ------------------------------------------------------------
  Widget _buildFriendsPositionCard() {
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
                'FRIENDS NET POSITION',
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.people,
                      size: 13,
                      color: onSecondaryContainer,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        color: onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _netBalance >= 0 ? 'Overall you are owed' : 'Overall you owe',
            style: const TextStyle(
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
                '₹${_netBalance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: _netBalance >= 0 ? primary : error,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'across ${_friends.length} friends',
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
                      Row(
                        children: const [
                          Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'You are owed',
                            style: TextStyle(
                              fontSize: 10,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${_totalYouAreOwed.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
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
                      Row(
                        children: const [
                          Icon(
                            Icons.arrow_downward,
                            size: 14,
                            color: error,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'You owe',
                            style: TextStyle(
                              fontSize: 10,
                              color: error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${_totalYouOwe.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
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
  // FRIEND CARD
  // ------------------------------------------------------------
  Widget _buildFriendCard(_FriendItem friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFriendDetails(friend),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: friend.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    friend.avatar,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Shared groups
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        friend.sharedGroups.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: outline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Balance status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      friend.isSettled
                          ? 'Settled'
                          : friend.isOwed
                              ? '+ ₹${friend.balance.toStringAsFixed(2)}'
                              : '- ₹${friend.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: friend.isSettled
                            ? outline
                            : friend.isOwed
                                ? primary
                                : error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friend.isSettled
                          ? 'All clear'
                          : friend.isOwed
                              ? 'owes you'
                              : 'you owe',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: friend.isSettled
                            ? outline
                            : friend.isOwed
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

class _FriendItem {
  final String name;
  final String avatar;
  final Color avatarColor;
  final String email;
  final String phone;
  final List<String> sharedGroups;
  double balance;
  final bool isOwed;
  bool isSettled;
  final String recentActivity;

  _FriendItem({
    required this.name,
    required this.avatar,
    required this.avatarColor,
    required this.email,
    required this.phone,
    required this.sharedGroups,
    required this.balance,
    required this.isOwed,
    this.isSettled = false,
    required this.recentActivity,
  });
}
