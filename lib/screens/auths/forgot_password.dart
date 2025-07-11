import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/auths/verify_email.dart';
import 'package:taskhub/screens/auths/reset_password.dart';
import 'package:taskhub/services/auth_service.dart';
import 'package:taskhub/theme/const_value.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String userType; // "user" or "tasker"
  
  const ForgotPasswordScreen({
    Key? key, 
    this.userType = "user", // Default to user
  }) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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

                if (!_emailSent) ...[
                  // -- Lock Icon --
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

                  // -- Title: "Forgot Password" --
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Forgot Your ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Password?',
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
                    "Don't worry! Enter your email address and we'll send you a 5-digit code to reset your password.",
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

                  // Email field
                  Text(
                    "Email Address",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Geist',
                        color: black.withOpacity(0.5),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: _emailController,
                    hintText: "you@example.domain",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    prefixIcon: SvgPicture.asset(
                      'assets/icons/email-icon.svg',
                      height: 2,
                      width: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- "Send Reset Code" Button --
                  PrimaryButton(
                    label: _isLoading ? "Sending..." : "Send Reset Code",
                    onPressed: _isLoading ? null : _sendResetLink,
                  ),
                  const SizedBox(height: 32),

                  // -- Help Text --
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Need help?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0284C7),
                                  fontSize: 14,
                                  fontFamily: 'Geist',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "If you don't receive an email within a few minutes, check your spam folder or contact support.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0284C7).withOpacity(0.8),
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
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Email ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sent!',
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
                    "We've sent a 5-digit reset code to ${_emailController.text}. Please check your email and enter the code to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- Email Display Box --
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xfff6f3fb),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/email-icon.svg',
                              width: 20,
                              height: 20,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reset code sent to:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Geist',
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _emailController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Geist',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // -- Continue to Reset Password Button --
                  PrimaryButton(
                    label: "Continue to Reset Password",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(
                            email: _emailController.text.trim(),
                            userType: widget.userType,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // -- Resend Link --
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _emailSent = false;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        "Didn't receive the email? Send again",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Geist',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // -- Back to Login Link (for initial state) --
                if (!_emailSent)
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Remember your password? ",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Geist',
                              color: black.withOpacity(0.7),
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Geist',
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  void _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      
      // Call the actual API
      final response = await _authService.forgotPassword(
        emailAddress: email,
        type: widget.userType,
      );
      
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset code sent successfully!',
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
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
} 