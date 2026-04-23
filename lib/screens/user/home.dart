import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/location_provider.dart';
import 'package:taskhub/screens/user/dashboard.dart';
import 'package:taskhub/screens/user/history.dart';
import 'package:taskhub/screens/user/messages.dart';
import 'package:taskhub/screens/user/profile.dart';
import 'package:taskhub/screens/user/post_task.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/widgets/location_services_dialog.dart';
// Removed old walkthrough imports (preferences_service, google_fonts, ui) since walkthrough now lives in DashboardScreen.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check location when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationServices();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app is resumed from background, check location services again
    if (state == AppLifecycleState.resumed) {
      _checkLocationServices();
    }
  }

  // Check location services and show dialog if needed
  Future<void> _checkLocationServices() async {
    if (!mounted) return;
    
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.initLocation();
    
    // If location is disabled, show the dialog
    if (locationProvider.isLocationServiceDisabled && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationServicesDialog(
          onLocationEnabled: () {
            // Callback when dialog is closed
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostTaskScreen()),
          );
        },
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.12),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'home-nav', 'Home'),
            _buildNavItem(1, 'history-nav', 'History'),
            _buildNavItem(2, 'messages-nav', 'Messages'),
            _buildNavItem(3, 'account-nav', 'Profile'),
          ],
        ),
      ),
    );
  }
  
  // Removed old walkthrough logic; new walkthrough implemented inside DashboardScreen only.
  
  Widget _buildNavItem(int index, String iconName, String label) {
    final bool isSelected = _selectedIndex == index;
    final String iconPath = isSelected 
        ? 'assets/icons/$iconName-active.svg'
        : 'assets/icons/$iconName.svg';
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : const Color(0xFFB4B5B7),
                fontSize: 13,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
