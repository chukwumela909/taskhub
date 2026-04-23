import 'package:flutter/material.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/screens/auths/starterPageSignin.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/tasker/profile_details.dart';
import 'package:taskhub/screens/tasker/category_selection.dart';
import 'package:taskhub/screens/user/change_password.dart';
import 'package:taskhub/screens/user/get_help.dart';
import 'package:taskhub/screens/user/faq.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class TaskerProfileScreen extends StatefulWidget {
  const TaskerProfileScreen({super.key});

  @override
  State<TaskerProfileScreen> createState() => _TaskerProfileScreenState();
}

class _TaskerProfileScreenState extends State<TaskerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userData == null) {
        authProvider.fetchTaskerData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final user = userData != null ? userData['user'] : null;
    final walletBalance = user != null ? user['wallet'] ?? 0 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: authProvider.status == AuthStatus.loading && userData == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile information section title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Geist',
                              color: Colors.white,
                            ),
                          ),
                          // Container(
                          //   width: 40,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: IconButton(
                          //     icon: SvgPicture.asset(
                          //       'assets/icons/notification.svg',
                          //       width: 24,
                          //       height: 24,
                          //       colorFilter:
                          //           ColorFilter.mode(taskerPrimaryColor, BlendMode.srcIn),
                          //     ),
                          //     onPressed: () {
                          //       // Handle notification
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Divider line
                      Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),

                      const SizedBox(height: 20),

                      // Header with notification icon and profile
                      _buildHeader(context, userData),

                      const SizedBox(height: 20),

                      // Switch to User card
                      _buildUserCard(),

                      const SizedBox(height: 12),

                      // Menu items
                      // _buildMenuItem(
                      //   'Profile Details',
                      //   'assets/icons/account-nav.svg',
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const TaskerProfileDetailsScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // _buildMenuItem(
                      //   'Earnings',
                      //   'assets/icons/cred-icon.svg',
                      //   onTap: () {
                      //     // Navigate to earnings screen
                      //   },
                      //   showTrailing: true,
                      //   trailingText: '₦$walletBalance',
                      // ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/cred-icon.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Earnings',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Geist',
                                ),
                              ),
                            ),
                             Text(
                                '₦$walletBalance',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: taskerPrimaryColor,
                                  fontFamily: 'Geist',
                                ),
                              ),
                              const SizedBox(width: 12),
                           
                         
                          ],
                        ),
                      ),
                      _buildMenuItem(
                        'Service Categories',
                        'assets/icons/arrange-square.svg',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategorySelectionScreen(
                                      isFromAuth: false),
                            ),
                          );

                          // Refresh user data if categories were updated
                          if (result == true) {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            await authProvider.fetchTaskerData();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Categories updated successfully!',
                                  style: TextStyle(fontFamily: 'Geist'),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      // _buildMenuItem(
                      //   'Task History',
                      //   'assets/icons/history-nav.svg',
                      //   onTap: () {
                      //     // Navigate to task history
                      //   },
                      // ),
                      _buildMenuItem(
                        'Change Password',
                        'assets/icons/password-icon.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        'Get Help',
                        'assets/icons/help.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GetHelpScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        'FAQ',
                        'assets/icons/faq.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        'Logout',
                        'assets/icons/logout.svg',
                        onTap: () {
                          _showLogoutDialog();
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic>? userData) {
    final user = userData != null ? userData['user'] : null;
    final profilePictureUrl = user?['profilePicture'] as String?;

    // Handle tasker name display (firstName + lastName instead of fullName)
    String displayName = 'Loading...';
    if (user != null) {
      if (user['firstName'] != null && user['lastName'] != null) {
        // Tasker data structure
        displayName = '${user['firstName']} ${user['lastName']}';
      } else if (user['fullName'] != null) {
        // Regular user data structure
        displayName = user['fullName'];
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TaskerProfileDetailsScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ProfilePictureWidget(
                profilePictureUrl: profilePictureUrl,
                radius: 30,
                showBorder: true,
                borderColor: Colors.white,
                borderWidth: 2,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Geist',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tasker',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF673AB7),
                      fontFamily: 'Geist',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SvgPicture.asset(
            'assets/icons/arrow-right.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(taskerPrimaryColor, BlendMode.srcIn),
          )
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return InkWell(
      onTap: () {
        // Logout and navigate to starter sign-in
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        authProvider.logout();
        taskProvider.clearAll();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StarterPageSignin()),
          (route) => false,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: taskerPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: taskerPrimaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: taskerPrimaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/switch-icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter:
                      ColorFilter.mode(taskerPrimaryColor, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Switch to User',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF673AB7),
                      fontFamily: 'Geist',
                    ),
                  ),
                  Text(
                    'Post tasks and hire taskers.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'Geist',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: taskerPrimaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: taskerPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    String iconPath, {
    required VoidCallback onTap,
    bool showTrailing = false,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: 'Geist',
                ),
              ),
            ),
            if (showTrailing && trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: taskerPrimaryColor,
                  fontFamily: 'Geist',
                ),
              ),
              const SizedBox(width: 12),
            ],
            SvgPicture.asset(
              'assets/icons/arrow-right.svg',
              width: 16,
              height: 16,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontFamily: 'Geist',
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                authProvider.logout();
                taskProvider.clearAll();
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StarterPageSignin()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Geist',
                  color: taskerPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
