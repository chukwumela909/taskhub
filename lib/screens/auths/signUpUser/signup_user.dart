import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/signUpUser/signup_user2.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/custom_loader.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpUser extends StatefulWidget {
  const SignUpUser({Key? key}) : super(key: key);

  @override
  _SignUpUserState createState() => _SignUpUserState();
}

class _SignUpUserState extends State<SignUpUser> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set status bar to transparent with white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // Clear any previous form data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearFormFields();
    });
  }

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
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Today !',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 28,
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
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 16,
                            color: black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    // Circle on the top-right (placeholder for a progress indicator or avatar)
                    SvgPicture.asset( 'assets/icons/signup-indicator1.svg'),
                  ],
                ),

                const SizedBox(height: 24),

                // -- "Basic Credentials" row with progress indicator (1/3) --
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset( 'assets/icons/shield-icon.svg', height: 24, width: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Basic Credentials",
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "1/3",
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // -- Full Name field --
                Text(
                  "Full Name",
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: black.withOpacity(0.5)),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: authProvider.fullNameController,
                  hintText: "e.g shola davies",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/name-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // -- Email Address field --
                Text(
                  "Email Address",
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: black.withOpacity(0.5)),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: authProvider.emailController,
                  hintText: "shola@example.domain",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    final trimmed = value.trim();
                    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(trimmed)) {
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
                const SizedBox(height: 16),

                // -- Phone Number field --
                Text(
                  "Phone Number",
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: black.withOpacity(0.5)),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: authProvider.phoneController,
                  hintText: "09034565807",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/phone-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // -- Date of Birth field --
                Text(
                  "Date of Birth",
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: black.withOpacity(0.5)),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: authProvider.dobController,
                  hintText: "YYYY-MM-DD",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    // Validate date format (YYYY-MM-DD)
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Please use format YYYY-MM-DD';
                    }
                    return null;
                  },
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        // Format date as YYYY-MM-DD for API
                        authProvider.dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/calendar-icon.svg',
                    height: 2,
                    width: 2,
                  ),
                ),
                const SizedBox(height: 16),

               
                const SizedBox(height: 32),

                // -- "Proceed" Button with a lock icon --
                PrimaryButton(
                  label: "Proceed", 
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If all validations pass, proceed to next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupUser2()),
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
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInUser()));
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.bricolageGrotesque(
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
      ),
    );
  }
}
