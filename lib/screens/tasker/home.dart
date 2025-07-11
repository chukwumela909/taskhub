import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/tasker/dashboard.dart';
import 'package:taskhub/screens/tasker/feed.dart';
import 'package:taskhub/screens/tasker/profile.dart';
import 'package:taskhub/screens/tasker/messages.dart';
import 'package:taskhub/theme/const_value.dart';

class TaskerHomeScreen extends StatefulWidget {
  const TaskerHomeScreen({super.key});

  @override
  State<TaskerHomeScreen> createState() => _TaskerHomeScreenState();
}

class _TaskerHomeScreenState extends State<TaskerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TaskerDashboardScreen(),
    const TaskerFeedScreen(),
    const TaskerMessagesScreen(),
    const TaskerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: 'assets/icons/home-nav.svg',
                  activeIcon: 'assets/icons/home-nav-active.svg',
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: 'assets/icons/activity-icon.svg',
                  activeIcon: 'assets/icons/activity-icon.svg',
                  label: 'Feed',
                  index: 1,
                ),
                _buildNavItem(
                  icon: 'assets/icons/messages-nav.svg',
                  activeIcon: 'assets/icons/messages-nav-active.svg',
                  label: 'Messages',
                  index: 2,
                ),
                _buildNavItem(
                  icon: 'assets/icons/account-nav.svg',
                  activeIcon: 'assets/icons/account-nav-active.svg',
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive ? activeIcon : icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? primaryColor : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w500,
                color: isActive ? primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
