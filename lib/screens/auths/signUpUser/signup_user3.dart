import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/verify_email.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/custom_loader.dart';

class SignupUser3 extends StatefulWidget {
  const SignupUser3({ Key? key }) : super(key: key);

  @override
  _SignupUser3State createState() => _SignupUser3State();
}

class _SignupUser3State extends State<SignupUser3> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Spacing at the top --
                const SizedBox(height: 16),

                // -- Row for "Join us Today!" and the top-right circle --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "Join us Today!"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Join us ',
                            style: const TextStyle(
                              fontSize: 28,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Today !',
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
                        SizedBox(height: 8),
                        // -- Subtitle --
                        Text(
                          "Be part of our platform today,\nsee what's possible",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Geist',
                            color: black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    // Circle on the top-right (placeholder for a progress indicator or avatar)
                    SvgPicture.asset('assets/icons/signup-done.svg'),
                  ],
                ),

                const SizedBox(height: 24),

               // Section indicator
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/shield-icon.svg',
                        height: 24, width: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Security",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "3/3",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Geist',
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                prefixIcon: SvgPicture.asset(
                  'assets/icons/lock-icon.svg',
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

              // Confirm password field
              Text(
                "Confirm password",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: authProvider.confirmPasswordController,
                hintText: "Confirm your password",
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != authProvider.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                prefixIcon: SvgPicture.asset(
                  'assets/icons/lock-icon.svg',
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
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // -- "Register" Button
              PrimaryButton(
                label: "Register", 
                onPressed: _isRegistering ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isRegistering = true;
                      _errorMessage = null;
                    });
                    
                    // Show the loader
                    CustomLoaderWithAnimation.show(
                      context,
                      text: 'Creating your account...',
                    );
                    
                    try {
                      final success = await authProvider.userRegister();
                      
                      // Hide the loader
                      Navigator.of(context).pop(); // Close the loader
                      
                      if (success) {
                        setState(() {
                          _isRegistering = false;
                        });
                        
                        // Navigate to verify email screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyEmailScreen(
                              email: authProvider.emailController.text.trim(),
                              userType: "user",
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          _isRegistering = false;
                          _errorMessage = authProvider.errorMessage ?? 'Registration failed. Please try again.';
                        });
                      }
                    } catch (e) {
                      // Hide the loader
                      Navigator.of(context).pop(); // Close the loader
                      
                      setState(() {
                        _isRegistering = false;
                        _errorMessage = e.toString();
                      });
                    }
                  }
                }
              ),

              const SizedBox(height: 32),

              // -- Bottom "Have an account? Login" --
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignInUser()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    )
  );
  }
}