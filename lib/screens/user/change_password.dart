import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/services/auth_service.dart';
import 'package:taskhub/theme/const_value.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChanging = false;
  String? _errorMessage;
  bool _passwordChanged = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xfff6f3fb),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: primaryColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_passwordChanged) ...[
                // -- Security Icon --
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/lock-icon.svg',
                        width: 32,
                        height: 32,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Title --
                Center(
                  child: Text(
                    'Change Your Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // -- Subtitle --
                Center(
                  child: Text(
                    'Please enter your current password and choose a new secure password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Display error message if any
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Geist',
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Current Password field
                Text(
                  "Current Password",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _currentPasswordController,
                  hintText: "Enter your current password",
                  obscureText: _obscureCurrentPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/password-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                    child: Icon(
                      _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // New Password field
                Text(
                  "New Password",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _newPasswordController,
                  hintText: "Enter your new password",
                  obscureText: _obscureNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Password must contain uppercase, lowercase, and number';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'New password must be different from current password';
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/password-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    child: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                Text(
                  "Confirm New Password",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm your new password",
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/password-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Password Requirements --
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    border: Border.all(
                      color: Color(0xFF0284C7).withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(0xFF0284C7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Password Requirements",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                              fontSize: 14,
                              fontFamily: 'Geist',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordRequirement("At least 8 characters long", _newPasswordController.text.length >= 8),
                      const SizedBox(height: 4),
                      _buildPasswordRequirement("Contains uppercase letter", RegExp(r'[A-Z]').hasMatch(_newPasswordController.text)),
                      const SizedBox(height: 4),
                      _buildPasswordRequirement("Contains lowercase letter", RegExp(r'[a-z]').hasMatch(_newPasswordController.text)),
                      const SizedBox(height: 4),
                      _buildPasswordRequirement("Contains number", RegExp(r'\d').hasMatch(_newPasswordController.text)),
                      const SizedBox(height: 4),
                      _buildPasswordRequirement("Different from current password", _newPasswordController.text.isNotEmpty && _newPasswordController.text != _currentPasswordController.text),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // -- "Change Password" Button --
                PrimaryButton(
                  label: _isChanging ? "Changing..." : "Change Password",
                  onPressed: _isChanging ? null : _changePassword,
                ),
                const SizedBox(height: 20),

                // -- Security Tip --
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF9E6),
                    border: Border.all(
                      color: attentionWarning.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: attentionWarning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.security,
                            size: 16,
                            color: attentionWarning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Security Tip",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: attentionWarning,
                                fontSize: 14,
                                fontFamily: 'Geist',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Use a unique password that you don't use for other accounts. Consider using a password manager.",
                              style: TextStyle(
                                fontSize: 14,
                                color: attentionWarning.withOpacity(0.8),
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // -- Success State --
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Success Title --
                Center(
                  child: Text(
                    'Password Changed Successfully!',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // -- Success Subtitle --
                Center(
                  child: Text(
                    "Your password has been updated successfully. Your account is now more secure.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // -- Success Box --
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.security,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Secured",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Geist',
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Your account is now protected with a new password",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Geist',
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // -- "Done" Button --
                PrimaryButton(
                  label: "Done",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green : Color(0xFF0284C7).withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.green : Color(0xFF0284C7).withOpacity(0.8),
            fontFamily: 'Geist',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isChanging) return;

    setState(() {
      _isChanging = true;
      _errorMessage = null;
    });

    try {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      
      // Call the actual API
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      // If successful, proceed with password change
      setState(() {
        _isChanging = false;
        _passwordChanged = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password changed successfully!',
            style: TextStyle(fontFamily: 'Geist'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
    } catch (e) {
      setState(() {
        _isChanging = false;
        _errorMessage = e.toString();
      });
    }
  }
} 