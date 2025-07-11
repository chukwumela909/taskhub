import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/forgot_password.dart';

import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/screens/tasker/home.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/custom_loader.dart';

class SignInTasker extends StatefulWidget {
  const SignInTasker({Key? key}) : super(key: key);

  @override
  _SignInTaskerState createState() => _SignInTaskerState();
}

class _SignInTaskerState extends State<SignInTasker> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Logo / Header Section --
                const SizedBox(height: 30),
                Center(child: _buildLogo()),
                const SizedBox(height: 32),

                // -- Title: "Welcome Back" --
                Align(
                  alignment: Alignment.topLeft,
                  child: RichText(
                    text: TextSpan(
                      text: 'Welcome ',
                      style: const TextStyle(
                        fontSize: 27,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Back',
                          style: TextStyle(
                            fontSize: 27,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // -- Subtitle --
                const Text(
                  "Login to continue where you left off.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: Colors.black54,
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
                  controller: authProvider.emailController,
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
                const SizedBox(height: 12),
                
                // Password field
                Text(
                  "Password",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Geist',
                      color: black.withOpacity(0.5),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: authProvider.passwordController,
                  hintText: "Enter your password",
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
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
                const SizedBox(height: 32),
                
                // -- "Forgot Password?" --
                Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen(userType: "tasker")),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Geist',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),

                const SizedBox(height: 20),
                
                // -- "Proceed" Button --
                PrimaryButton(
                  label: "Login", 
                  onPressed: _isLoggingIn ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoggingIn = true;
                        _errorMessage = null;
                      });
                      
                      // Show the loader
                      CustomLoaderWithAnimation.show(
                        context,
                        text: 'Logging in...',
                      );
                      
                      try {
                        final success = await authProvider.taskerLogin();
                        
                        // Hide the loader
                        Navigator.of(context).pop(); // Close the loader
                        
                        if (success) {
                          setState(() {
                            _isLoggingIn = false;
                          });
                          
                          // Navigate to tasker home screen with bottom navigation
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => TaskerHomeScreen()),
                          );
                        } else {
                          setState(() {
                            _isLoggingIn = false;
                            _errorMessage = authProvider.errorMessage ?? 'Login failed. Please try again.';
                          });
                        }
                      } catch (e) {
                        // Hide the loader
                        Navigator.of(context).pop(); // Close the loader
                        
                        setState(() {
                          _isLoggingIn = false;
                          _errorMessage = e.toString();
                        });
                      }
                    }
                  }
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xffd9d9d9),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "SIGN IN WITH",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Geist',
                          color: black.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xffd9d9d9),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        decoration: BoxDecoration(
                          color: Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/google.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        decoration: BoxDecoration(
                          color: Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/apple.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        decoration: BoxDecoration(
                          color: Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/facebook.svg',
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                // -- Bottom "Don't have an account? Create" --
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Geist',
                            color: black.withOpacity(0.7),
                            fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                          onTap: () {
                          // Navigate to the Sign Up page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StarterPage()),
                          );
                        },
                        child: Text(
                          "Create",
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
    return Image.asset('assets/icons/taskhub-dark.png', width: 80);
  }
}
