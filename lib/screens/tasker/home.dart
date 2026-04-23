import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/tasker/dashboard.dart';
import 'package:taskhub/screens/tasker/feed.dart';
import 'package:taskhub/screens/tasker/profile.dart';
import 'package:taskhub/screens/tasker/messages.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/tasker/category_selection.dart';

class TaskerHomeScreen extends StatefulWidget {
  const TaskerHomeScreen({super.key});

  @override
  State<TaskerHomeScreen> createState() => _TaskerHomeScreenState();
}

class _TaskerHomeScreenState extends State<TaskerHomeScreen> {
  int _currentIndex = 0;
  bool _categoriesPromptShown = false;

  final List<Widget> _screens = [
    const TaskerDashboardScreen(),
    const TaskerFeedScreen(),
    const TaskerMessagesScreen(),
    const TaskerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Defer prompt until after first frame to ensure context and providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptForCategories());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // In case auth data arrives after build, try prompting once per session
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptForCategories());
  }

  void _maybePromptForCategories() {
    if (!mounted || _categoriesPromptShown) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final data = auth.userData;
    final user = data != null ? data['user'] as Map<String, dynamic>? : null;
    final categories = (user != null ? user['categories'] : null) as List?;

    if (categories == null || categories.isEmpty) {
      _categoriesPromptShown = true; // ensure we only show once per session
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            "Set your service categories to get matched with tasks.",
            style: TextStyle(fontFamily: 'Geist'),
          ),
          action: SnackBarAction(
            label: 'Select',
            onPressed: () async {
              // Open category selection; ensure token is available from provider/storage
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        await Navigator.push(
                context,
                MaterialPageRoute(
          builder: (context) => CategorySelectionScreen(isFromAuth: false, token: token),
                ),
              );
              // On return, optionally show a quick confirmation if categories now exist
              if (!mounted) return;
              final updated = Provider.of<AuthProvider>(context, listen: false).userData;
              final updatedUser = updated != null ? updated['user'] as Map<String, dynamic>? : null;
              final updatedCats = updatedUser != null ? updatedUser['categories'] as List? : null;
              if (updatedCats != null && updatedCats.isNotEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Categories updated. Your feed will improve shortly.',
                      style: TextStyle(fontFamily: 'Geist'),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            _buildNavIconWidget(label, isActive, icon, activeIcon),
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

  Widget _buildNavIconWidget(String label, bool isActive, String icon, String activeIcon) {
    // Replace Home and Messages with outlined Material icons
    if (label == 'Home') {
      return Icon(
        Icons.home_outlined,
        size: 24,
        color: isActive ? primaryColor : Colors.grey.shade400,
      );
    }
    if (label == 'Messages') {
      return Icon(
        Icons.chat_outlined,
        size: 24,
        color: isActive ? primaryColor : Colors.grey.shade400,
      );
    }
    if (label == 'Feed') {
      // Replace Feed with a Material outlined icon and use primary color when active
      return Icon(
        Icons.dynamic_feed_outlined,
        size: 24,
        color: isActive ? primaryColor : Colors.grey.shade400,
      );
    }
    // Fallback to existing SVGs for other tabs
    return SvgPicture.asset(
      isActive ? activeIcon : icon,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive ? primaryColor : Colors.grey.shade400,
        BlendMode.srcIn,
      ),
    );
  }
}
