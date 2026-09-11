import 'package:flutter/material.dart';

import '../../features/activity/activity_screen.dart';
import '../../features/home/home_screen.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    _PlaceholderScreen(
      title: 'Friends',
      icon: Icons.person_outline,
    ),
    ActivityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating navigation + profile button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    SizedBox(
                    width: 280,
                    child: _buildFloatingNavigation(),
                    ),

                    const SizedBox(width: 8),

                    _buildProfileButton(),
                ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigation() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF151B1C),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavigationItem(
              index: 0,
              icon: Icons.groups_outlined,
              selectedIcon: Icons.groups,
              label: 'Groups',
            ),
          ),
          Expanded(
            child: _buildNavigationItem(
              index: 1,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Friends',
            ),
          ),
          Expanded(
            child: _buildNavigationItem(
              index: 2,
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long,
              label: 'Activity',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF40575A)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: Colors.white,
              size: 21,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {
        // Account screen will be added later.
      },
      child: Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF151B1C),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFCAE5E0),
              child: Text(
                'AR',
                style: TextStyle(
                  color: Color(0xFF005048),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),

            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF21B59A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF151B1C),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Icon(
          icon,
          size: 64,
        ),
      ),
    );
  }
}