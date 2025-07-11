import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/services/image_service.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();
  bool _isUpdatingProfilePicture = false;

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

  Future<void> _updateProfilePicture() async {
    if (!mounted) return;
    
    try {
      // Show image source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Select Image Source',
              style: TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera', style: TextStyle(fontFamily: 'Geist')),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery', style: TextStyle(fontFamily: 'Geist')),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null || !mounted) return;

      // Pick image from selected source
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
        // Convert XFile to File and upload to Cloudinary
        final file = File(image.path);
        final imageUrls = await _imageService.uploadImages([file]);
        
        if (imageUrls.isNotEmpty && mounted) {
          final profilePictureUrl = imageUrls.first;
          
          // Update profile picture via API
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
      } finally {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF606060),
            fontFamily: 'Geist',
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(9),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back-arrow.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Color(0xFF606060), BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        scrolledUnderElevation: 0, // Prevents color change when scrolling
      ),
      body: authProvider.status == AuthStatus.loading && userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image and name
                    _buildProfileHeader(user),
                    
                    const SizedBox(height: 30),
                    
                    // Basic Information section
                    _buildSectionTitle('Basic Information'),
                    
                    const SizedBox(height: 10),
                    
                    // Email section
                    _buildInfoCard(
                      'Email',
                      user != null ? user['emailAddress'] : 'Loading...',
                      'assets/icons/email-icon.svg',
                      isCopiable: true,
                      onCopy: () {
                        if (user != null) {
                          Clipboard.setData(ClipboardData(text: user['emailAddress']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email copied to clipboard')),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Phone section
                    _buildInfoCard(
                      'Phone',
                      user != null ? user['phoneNumber'] : 'Loading...',
                      'assets/icons/phone-icon.svg',
                      isCopiable: true,
                      onCopy: () {
                        if (user != null) {
                          Clipboard.setData(ClipboardData(text: user['phoneNumber']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number copied to clipboard')),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Date of Birth section
                    _buildInfoCard(
                      'Date of Birth',
                      user != null ? user['dateOfBirth'] : 'Loading...',
                      'assets/icons/calendar-icon.svg',
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Nationality section
                    _buildSectionTitle('Nationality'),
                    
                    const SizedBox(height: 8),
                    
                    // Nigeria section with flag
                    _buildNationalityCard(user != null ? user['country'] : 'Loading...'),
                    
                    const SizedBox(height: 10),
                    
                    // State of Origin section
                    _buildInfoCard(
                      'State of Origin',
                      user != null ? user['residentState'] : 'Loading...',
                      'assets/icons/flag-icon.svg',
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Residence section
                    _buildSectionTitle('Residence'),
                    
                    const SizedBox(height: 8),
                    
                    // State section
                    _buildInfoCard(
                      'State',
                      user != null ? user['residentState'] : 'Loading...',
                      'assets/icons/flag-icon.svg',
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Area section
                    // _buildInfoCard(
                    //   'Area',
                    //   user != null ? (user['area'] ?? 'Not specified') : 'Loading...',
                    //   'assets/icons/flag-icon.svg',
                    // ),
                    
                    // const SizedBox(height: 10),
                    
                    // Address section
                    _buildInfoCard(
                      'Address',
                      user != null ? user['address'] : 'Loading...',
                      'assets/icons/flag-icon.svg',
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Delete Account button
                    _buildDeleteAccountButton(context),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
    final profilePictureUrl = user?['profilePicture'] as String?;
    
    return Column(
      children: [
        // Profile image
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
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
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
                  color: primaryColor,
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
        // Name
        Text(
          user != null ? user['fullName'] : 'Loading...',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF606060),
            fontFamily: 'Geist',
          ),
        ),
        const SizedBox(height: 8),
        // Role container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(200),
          ),
          child: const Text(
            'Taskhub User',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF673AB7),
              fontFamily: 'Geist',
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF606060),
            fontFamily: 'Geist',
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String iconPath, {
    bool isCopiable = false,
    VoidCallback? onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF606060),
                    fontFamily: 'Geist',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xB3000000), // 70% opacity black
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            ),
          ),
          // Copy icon if copiable
          if (isCopiable && onCopy != null)
            InkWell(
              onTap: onCopy,
              child: SvgPicture.asset(
                'assets/icons/copy_icon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF606060), BlendMode.srcIn),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNationalityCard(String country) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Nigeria flag
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF20B37D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Center(
                  child: Container(
                    width: 8,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Country name
          Text(
            country,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xB3000000), // 70% opacity black
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Show deletion confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Handle account deletion
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x33FFB8B8), // Light red with opacity
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/trash_icon.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFFE07575), BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEC3939),
                fontFamily: 'Geist',
              ),
            ),
          ],
        ),
      ),
    );
  }
} 