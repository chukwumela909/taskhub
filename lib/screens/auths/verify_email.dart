import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/auths/starterPageSignin.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/services/auth_service.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String userType; // "user" or "tasker"
  
  const VerifyEmailScreen({
    Key? key,
    required this.email,
    this.userType = "user", // Default to user
  }) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isResending = false;
  bool _canResend = true;
  bool _isVerifying = false;
  int _resendCountdown = 60;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -- Logo / Header Section --
                const SizedBox(height: 30),
                // _buildLogo(),
                // const SizedBox(height: 40),

                // -- Email Icon --
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/email-icon.svg',
                      width: 32,
                      height: 32,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Title: "Verify Your Email" --
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Verify Your ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Email',
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
                  "We've sent a 6-digit verification code to your email address. Please enter the code below to verify your account.",
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
                              "Code sent to:",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Geist',
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.email,
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

                // -- Verification Code Input --
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _codeController,
                  hintText: "Enter  code",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Verification code must contain only numbers';
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
                const SizedBox(height: 32),

                // -- Verify Button --
                PrimaryButton(
                  label: _isVerifying ? "Verifying..." : "Verify Code",
                  onPressed: _isVerifying ? null : _verifyCode,
                ),
                const SizedBox(height: 32),

                // -- Instructions Box --
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
                              "Check your spam folder",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                                fontSize: 14,
                                fontFamily: 'Geist',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "If you don't see the email in your inbox, please check your spam or junk folder.",
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
                const SizedBox(height: 32),

                // -- Resend Email Section --
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

                // -- Resend Button --
                if (_canResend)
                  GestureDetector(
                    onTap: _isResending ? null : _resendEmail,
                    child: Text(
                      _isResending ? "Sending..." : "Resend verification code",
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

                const SizedBox(height: 40),

              
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

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim();
      
      // Call the actual API
      final response = await _authService.verifyEmail(
        code: code,
        emailAddress: widget.email,
        type: widget.userType,
      );
      
      // Success
      setState(() {
        _isVerifying = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email verified successfully!',
            style: TextStyle(fontFamily: 'Geist'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      // Navigate to appropriate screen based on user type
      await Future.delayed(Duration(milliseconds: 500)); // Brief delay to show success message
      
      // After verification, send all to appropriate sign-in screen
      if (widget.userType == "tasker") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StarterPageSignin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StarterPageSignin()),
        );
      }
        
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  void _resendEmail() async {
    if (_isResending || !_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      // Call the actual API
      final response = await _authService.resendEmailVerification(
        emailAddress: widget.email,
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
            'Verification code sent successfully!',
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