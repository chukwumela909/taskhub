import 'package:flutter/material.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/screens/auths/starterPageSignin.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/user/profile_details.dart';
import 'package:taskhub/screens/user/change_password.dart';
import 'package:taskhub/screens/user/get_help.dart';
import 'package:taskhub/screens/user/faq.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy wallet data
  double _walletBalance = 15750.50; // Dummy balance
  bool _isLoadingWallet = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userData == null) {
        authProvider.fetchUserData();
      }
    });
  }

  // Simulate wallet funding
  Future<void> _fundWallet() async {
    setState(() {
      _isLoadingWallet = true;
    });

    // Show funding dialog
    final result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController amountController = TextEditingController();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Fund Wallet',
            style: TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter amount to add to your wallet',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  color: Color(0xFF606060),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₦ ',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Geist'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.pop(context, amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Fund',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Simulate funding process
    if (result != null) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      setState(() {
        _walletBalance += result;
        _isLoadingWallet = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wallet funded successfully! ₦${result.toStringAsFixed(2)} added.',
            style: const TextStyle(fontFamily: 'Geist'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: authProvider.status == AuthStatus.loading && userData == null
            ? const Center(child: CircularProgressIndicator())
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
                              color: Color(0xFF606060),
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
                          //           ColorFilter.mode(primaryColor, BlendMode.srcIn),
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
                        color: Colors.black.withOpacity(0.12),
                      ),

                      const SizedBox(height: 24),

                      // Header with notification icon and profile
                      _buildHeader(context, userData),

                      const SizedBox(height: 24),

                      // Wallet card
                      _buildWalletCard(),

                      const SizedBox(height: 24),

                      // Become a Tasker card
                      GestureDetector(
                        onTap: () {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final taskProvider =
                              Provider.of<TaskProvider>(context, listen: false);

                          // Handle logout
                          authProvider.logout();
                          // Clear any cached task state
                          taskProvider.clearAll();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StarterPage()),
                          );
                        },
                        child: _buildTaskerCard(),
                      ),

                      const SizedBox(height: 16),

                      // Menu items
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
                        'Change Password',
                        'assets/icons/lock-icon.svg',
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
                      // _buildMenuItem(
                      //   'Language',
                      //   'assets/icons/language.svg',
                      //   onTap: () {
                      //     // Show language selection
                      //   },
                      //   showTrailing: true,
                      //   trailingText: 'English - UK',
                      // ),

                      // _buildMenuItem(
                      //   'Legal',
                      //   'assets/icons/legal.svg',
                      //   onTap: () {
                      //     // Navigate to legal screen
                      //   },
                      // ),

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

                      const SizedBox(height: 16),

                      // Logout button
                      _buildLogoutButton(context),

                      const SizedBox(height: 20),
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

    return GestureDetector(
      onTap: () {
        // Navigate to profile details screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileDetailsScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile image
          Row(
            children: [
              ProfilePictureWidget(
                profilePictureUrl: profilePictureUrl, // ignored
                displayName: userData != null
                    ? (userData['user']['fullName'] ?? '')
                    : null,
                radius: 30,
                showBorder: true,
                borderColor: Colors.white,
                borderWidth: 2,
              ),
              const SizedBox(width: 16),
              // User info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData != null
                        ? userData['user']['fullName']
                        : 'Loading...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Geist',
                      color: Color(0xFF606060),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'User',
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
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          )
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and fund button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Fund wallet button
              GestureDetector(
                onTap: _isLoadingWallet ? null : _fundWallet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoadingWallet)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      const SizedBox(width: 3),
                      Text(
                        _isLoadingWallet ? 'Processing...' : 'Fund',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Balance amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '₦',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                _walletBalance.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Available balance text
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/switch-icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Become a Tasker',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF673AB7),
                    fontFamily: 'Geist',
                  ),
                ),
                const Text(
                  'Create & switch to being a tasker.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF606060),
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_forward,
                color: primaryColor,
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF606060), BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF606060),
                  fontFamily: 'Geist',
                ),
              ),
            ),
            // Trailing
            if (showTrailing && trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0x66606060),
                  fontFamily: 'Geist',
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Arrow icon
            SvgPicture.asset(
              'assets/icons/arrow-right.svg',
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(Color(0xFF606060), BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        // Handle logout
        authProvider.logout();
        // Clear any cached task state
        taskProvider.clearAll();

        // Direct navigation to sign in screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StarterPageSignin()),
          (Route<dynamic> route) => false,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFCF2C2C).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/logout.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCF2C2C),
                fontFamily: 'Geist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
