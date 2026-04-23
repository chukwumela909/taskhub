import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/forgot_password.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/screens/tasker/home.dart';
import 'package:taskhub/screens/tasker/category_selection.dart';
import 'package:taskhub/screens/user/home.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/custom_loader.dart';

class StarterPageSignin extends StatefulWidget {
  const StarterPageSignin({Key? key}) : super(key: key);

  @override
  _StarterPageSigninState createState() => _StarterPageSigninState();
}

class _StarterPageSigninState extends State<StarterPageSignin> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Start with fade-in animation
    _fadeController.forward();
    
    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fadeController.reset();
        _fadeController.forward();
        // Clear any error messages when switching tabs
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -- Logo / Header Section --
                const SizedBox(height: 60),
                _buildLogo(),
                const SizedBox(height: 32),

                // -- Title: "Welcome Back" --
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: 'Welcome ',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Back!',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 30,
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
                Text(
                  "Sign in to manage your tasks and projects.",
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    // fontWeight: FontWeight.w600,
                    color: Color(0xff606060),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Tab Bar --
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xfff6f3fb),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: primaryColor,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    tabs: [
                      Tab(text: 'User'),
                      Tab(text: 'Tasker'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // -- Tab Content --
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // User Login Tab
                        _buildLoginForm(authProvider, isTasker: false),
                        
                        // Tasker Login Tab
                        _buildLoginForm(authProvider, isTasker: true),
                      ],
                    ),
                  ),
                ),

          

                // -- Bottom "Don't have an account? Sign up" --
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 18,
                          color: black.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            _createSlideRoute(StarterPage()),
                          );
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 18,
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

  Widget _buildLoginForm(AuthProvider authProvider, {required bool isTasker}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                style: GoogleFonts.bricolageGrotesque(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Email field
          Text(
            "Email Address",
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              color: black.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: authProvider.emailController,
            hintText: "you@example.domain",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
              return 'Please enter your email address';
              }
              final email = value.trim();
              if (email.contains(' ')) {
              return 'Email address must not contain spaces';
              }
              final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
              if (!emailRegex.hasMatch(email)) {
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
          
          // Password field
          Text(
            "Password",
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              color: black.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
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
          const SizedBox(height: 16),
          
          // -- "Forgot Password?" --
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen(userType: isTasker ? "tasker" : "user")),
                );
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ),

          const SizedBox(height: 24),
          
          // -- "Login" Button --
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
                  final success = isTasker 
                    ? await authProvider.taskerLogin()
                    : await authProvider.userLogin();
                  
                  // Hide the loader
                  Navigator.of(context).pop(); // Close the loader
                  
                  if (success && authProvider.status == AuthStatus.authenticated && authProvider.token != null) {
                    setState(() {
                      _isLoggingIn = false;
                    });
                    
                    if (isTasker) {
                      if (!mounted) return;
                      // Decide whether to show category selection first
                      final user = authProvider.userData != null ? authProvider.userData!['user'] : null;
                      final List<dynamic> categories = (user != null ? (user['categories'] as List?) : null) ?? const [];
                          if (categories.isEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategorySelectionScreen(
                              isFromAuth: true,
                              token: authProvider.token,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TaskerHomeScreen()),
                        );
                      }
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
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
                    _errorMessage = "Something went wrong";
                  });
                }
              }
            }
          ),

          const SizedBox(height: 24),
          
          // -- "OR" Divider --
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Color(0xffd9d9d9),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "OR",
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14,
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
          
          const SizedBox(height: 24),
          
          // -- Google Sign In Button --
          // GestureDetector(
          //   onTap: () {
          //     // TODO: Implement Google Sign In
          //     // This would connect to your AuthProvider's Google sign-in method
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(vertical: 16.0),
          //     decoration: BoxDecoration(
          //       color: Color(0xfff7f7f7),
          //       borderRadius: BorderRadius.circular(12.0),
          //       border: Border.all(color: Color(0xffe0e0e0)),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         SvgPicture.asset(
          //           'assets/icons/google.svg',
          //           height: 24,
          //           width: 24,
          //         ),
          //         SizedBox(width: 12),
          //         Text(
          //           "Continue with Google",
          //           style: GoogleFonts.bricolageGrotesque(
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.black87,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset('assets/icons/taskhub-dark.png', width: 80);
  }
  
  // Custom slide transition route
  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

// Using CustomTextFormField from const_value.dart

// Using PrimaryButton from const_value.dart
