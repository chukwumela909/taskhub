import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/services/auth_service.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';
import 'package:taskhub/theme/const_value.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token; // Reset token from email link
  final String? email; // Email address for reset
  final String userType; // "user" or "tasker"
  
  const ResetPasswordScreen({
    Key? key,
    this.token,
    this.email,
    this.userType = "user",
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetting = false;
  bool _isResending = false;
  bool _canResend = true;
  int _resendCountdown = 60;
  String? _errorMessage;
  bool _passwordReset = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Logo / Header Section --
                const SizedBox(height: 20),
                // Center(child: _buildLogo()),
                // const SizedBox(height: 40),

                if (!_passwordReset) ...[
                  // -- Shield Icon --
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
                          'assets/icons/shield-icon.svg',
                          width: 32,
                          height: 32,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- Title: "Reset Password" --
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Reset Your ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Password',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // -- Subtitle --
                  Text(
                    "Enter the reset code sent to your email and create a new password for your account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: Colors.black54,
                      height: 1.5,
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

                  // Reset Code field
                  Text(
                    "Reset Code",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Geist',
                        color: black.withOpacity(0.5),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: _codeController,
                    hintText: "Enter 5-digit reset code",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the reset code';
                      }
                      if (value.length != 5) {
                        return 'Reset code must be 5 digits';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Reset code must contain only numbers';
                      }
                      return null;
                    },
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          "#",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
                    controller: _passwordController,
                    hintText: "Enter your new password",
                    obscureText: _obscurePassword,
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
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  Text(
                    "Confirm Password",
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
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
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
                        _buildPasswordRequirement("At least 8 characters long", _passwordController.text.length >= 8),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement("Contains uppercase letter", RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement("Contains lowercase letter", RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                        const SizedBox(height: 4),
                        _buildPasswordRequirement("Contains number", RegExp(r'\d').hasMatch(_passwordController.text)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- "Reset Password" Button --
                  PrimaryButton(
                    label: _isResetting ? "Resetting..." : "Reset Password",
                    onPressed: _isResetting ? null : _resetPassword,
                  ),
                  const SizedBox(height: 32),

                  // -- Resend Code Section --
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Didn't receive the code?",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Geist',
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_canResend)
                          GestureDetector(
                            onTap: _isResending ? null : _resendCode,
                            child: Text(
                              _isResending ? "Sending..." : "Resend reset code",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Geist',
                                color: _isResending ? Colors.grey : primaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        else
                          Text(
                            "Resend in ${_resendCountdown}s",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Geist',
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
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
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Password ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Reset!',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // -- Success Subtitle --
                  Text(
                    "Your password has been successfully reset. You can now sign in with your new password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: Colors.black54,
                      height: 1.5,
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
                                "Secure & Protected",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Geist',
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Your account is now secured with a new password",
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

                  // -- "Continue to Sign In" Button --
                  PrimaryButton(
                    label: "Continue to Sign In",
                    onPressed: () {
                      // Navigate to appropriate sign in screen based on user type
                      if (widget.userType == "tasker") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignInTasker()),
                          (route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignInUser()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset('assets/icons/taskhub-dark.png', width: 100);
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

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isResetting) return;

    setState(() {
      _isResetting = true;
      _errorMessage = null;
    });

    try {
      final resetCode = _codeController.text.trim();
      final newPassword = _passwordController.text.trim();
      final email = widget.email;
      
      if (email == null) {
        setState(() {
          _isResetting = false;
          _errorMessage = 'Email address is required for password reset.';
        });
        return;
      }
      
      // Call the actual API
      final response = await _authService.resetPassword(
        code: resetCode,
        newPassword: newPassword,
        emailAddress: email,
        type: widget.userType,
      );
      
      // If successful, proceed with password reset
      setState(() {
        _isResetting = false;
        _passwordReset = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset successfully!',
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
        _isResetting = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _resendCode() async {
    if (_isResending || !_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final email = widget.email;
      
      if (email == null) {
        setState(() {
          _isResending = false;
          _errorMessage = 'Email address is required to resend code.';
        });
        return;
      }

      // Call the forgot password API to resend the code
      final response = await _authService.forgotPassword(
        emailAddress: email,
        type: widget.userType,
      );

      setState(() {
        _isResending = false;
        _canResend = false;
        _resendCountdown = 60;
      });

      // Start countdown timer
      _startResendCountdown();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset code sent successfully!',
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
        _isResending = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startResendCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }
} 