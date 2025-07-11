import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/services/image_service.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TaskerProfileDetailsScreen extends StatefulWidget {
  const TaskerProfileDetailsScreen({super.key});

  @override
  State<TaskerProfileDetailsScreen> createState() => _TaskerProfileDetailsScreenState();
}

class _TaskerProfileDetailsScreenState extends State<TaskerProfileDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();
  bool _isUpdatingProfilePicture = false;

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

  Future<void> _updateProfilePicture() async {
    if (!mounted) return;
    
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Select Image Source',
              style: TextStyle(
                fontFamily: 'Geist', 
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    'Camera', 
                    style: TextStyle(fontFamily: 'Geist', color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text(
                    'Gallery', 
                    style: TextStyle(fontFamily: 'Geist', color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null || !mounted) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        _isUpdatingProfilePicture = true;
      });

      try {
        final file = File(image.path);
        final imageUrls = await _imageService.uploadImages([file]);
        
        if (imageUrls.isNotEmpty && mounted) {
          final profilePictureUrl = imageUrls.first;
          
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final success = await authProvider.updateProfilePicture(profilePictureUrl);
          
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile picture updated successfully!',
                    style: TextStyle(fontFamily: 'Geist'),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    authProvider.errorMessage ?? 'Failed to update profile picture',
                    style: const TextStyle(fontFamily: 'Geist'),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error uploading image: ${e.toString()}',
                style: const TextStyle(fontFamily: 'Geist'),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      
        if (mounted) {
          setState(() {
            _isUpdatingProfilePicture = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingProfilePicture = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting image: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Geist'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final user = userData != null ? userData['user'] : null;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Geist',
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(9),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back-arrow.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1A1A1A),
          statusBarIconBrightness: Brightness.light,
        ),
        scrolledUnderElevation: 0,
      ),
      body: authProvider.status == AuthStatus.loading && userData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 32),
                    _buildProfileInfoCard(user),
                    const SizedBox(height: 24),
                    _buildTaskerStatsCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
    final profilePictureUrl = user?['profilePicture'] as String?;
    
    String displayName = 'Loading...';
    if (user != null) {
      if (user['firstName'] != null && user['lastName'] != null) {
        displayName = '${user['firstName']} ${user['lastName']}';
      } else if (user['fullName'] != null) {
        displayName = user['fullName'];
      }
    }
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _isUpdatingProfilePicture
                    ? Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      )
                    : profilePictureUrl != null && profilePictureUrl.isNotEmpty
                        ? Image.network(
                            profilePictureUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/profile-picture.png',
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/profile-picture.png',
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: taskerPrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: _isUpdatingProfilePicture
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                  onPressed: _isUpdatingProfilePicture ? null : _updateProfilePicture,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Geist',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: taskerPrimaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Taskhub Tasker',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: taskerPrimaryColor,
              fontFamily: 'Geist',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(Map<String, dynamic>? user) {
    // Handle tasker name display (firstName + lastName instead of fullName)
    String displayName = 'Loading...';
    String emailAddress = 'Loading...';
    
    if (user != null) {
      if (user['firstName'] != null && user['lastName'] != null) {
        // Tasker data structure
        displayName = '${user['firstName']} ${user['lastName']}';
        emailAddress = user['emailAddress'] ?? 'Loading...';
      } else if (user['fullName'] != null) {
        // Regular user data structure
        displayName = user['fullName'];
        emailAddress = user['email'] ?? 'Loading...';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'assets/icons/name-icon.svg',
            'Full Name',
            displayName,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/email-icon.svg',
            'Email Address',
            emailAddress,
            isCopiable: true,
            onCopy: () {
              if (emailAddress != 'Loading...') {
                Clipboard.setData(ClipboardData(text: emailAddress));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email copied to clipboard'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/phone-icon.svg',
            'Phone Number',
            user != null ? user['phoneNumber'] : 'Loading...',
            isCopiable: true,
            onCopy: () {
              if (user != null) {
                Clipboard.setData(ClipboardData(text: user['phoneNumber']));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number copied to clipboard'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/flag-icon.svg',
            'Country',
            user != null ? user['country'] : 'Loading...',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/language.svg',
            'Resident State',
            user != null ? user['residentState'] : 'Loading...',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/language.svg',
            'Origin State',
            user != null ? user['originState'] : 'Loading...',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/arrange-square.svg',
            'Address',
            user != null ? user['address'] : 'Loading...',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'assets/icons/cred-icon.svg',
            'Wallet Balance',
            user != null ? '₦${user['wallet'] ?? 0}' : 'Loading...',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskerStatsCard() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final user = userData != null ? userData['user'] : null;
    final walletBalance = user != null ? user['wallet'] ?? 0 : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasker Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Tasks Completed', '12', Icons.task_alt),
              ),
              Expanded(
                child: _buildStatItem('Rating', '4.8', Icons.star),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Wallet Balance', '₦$walletBalance', Icons.account_balance_wallet),
              ),
              Expanded(
                child: _buildStatItem('Success Rate', '95%', Icons.trending_up),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: taskerPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: taskerPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: taskerPrimaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: taskerPrimaryColor,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
              fontFamily: 'Geist',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String iconPath,
    String title,
    String value, {
    bool isCopiable = false,
    VoidCallback? onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: taskerPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: taskerPrimaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(taskerPrimaryColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Geist',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade300,
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            ),
          ),
          if (isCopiable && onCopy != null)
            InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }
} 