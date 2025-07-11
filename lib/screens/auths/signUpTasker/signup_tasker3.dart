import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';

import 'package:taskhub/screens/auths/verify_email.dart';
import 'package:taskhub/theme/const_value.dart';

class SignupTasker3 extends StatefulWidget {
  const SignupTasker3({Key? key}) : super(key: key);

  @override
  _SignupTasker3State createState() => _SignupTasker3State();
}

class _SignupTasker3State extends State<SignupTasker3> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
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
                          text: 'Earn with ',
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Us !',
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
                obscureText: true,
                prefixIcon: SvgPicture.asset(
                  'assets/icons/lock-icon.svg',
                  height: 2,
                  width: 2,
                ),
              ),
              const SizedBox(height: 16),

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
                obscureText: true,
                prefixIcon: SvgPicture.asset(
                  'assets/icons/lock-icon.svg',
                  height: 2,
                  width: 2,
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // -- "Register" Button --
              PrimaryButton(
                label: authProvider.status == AuthStatus.loading ? "Registering..." : "Register", 
                onPressed: authProvider.status == AuthStatus.loading ? null : () async {
                  // Validate passwords match
                  if (authProvider.passwordController.text != authProvider.confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Passwords do not match'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate required fields
                  if (authProvider.firstNameController.text.trim().isEmpty ||
                      authProvider.lastNameController.text.trim().isEmpty ||
                      authProvider.emailController.text.trim().isEmpty ||
                      authProvider.phoneController.text.trim().isEmpty ||
                      authProvider.dobController.text.trim().isEmpty ||
                      authProvider.residentStateController.text.trim().isEmpty ||
                      authProvider.originStateController.text.trim().isEmpty ||
                      authProvider.addressController.text.trim().isEmpty ||
                      authProvider.passwordController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Set default country if not set
                  if (authProvider.countryController.text.trim().isEmpty) {
                    authProvider.countryController.text = "Nigeria";
                  }

                  // Attempt registration
                  bool success = await authProvider.taskerRegister();
                  
                  if (success) {
                    // Navigate to verify email screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyEmailScreen(
                          email: authProvider.emailController.text.trim(),
                          userType: "tasker",
                        ),
                      ),
                    );
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.errorMessage ?? 'Registration failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
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
                         Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInTasker()),
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
    );
  }
}
