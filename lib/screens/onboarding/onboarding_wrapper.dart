import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskhub/screens/onboarding/onboard1.dart';
import 'package:taskhub/screens/onboarding/onboard2.dart';
import 'package:taskhub/screens/onboarding/onboard3.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/services/preferences_service.dart';
import 'package:taskhub/theme/const_value.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await PreferencesService.markOnboardingCompleted();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const StarterPage(),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0); // Slide in from right
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: i == _currentPage ? primaryColor : onboardSlider,
              borderRadius: BorderRadius.circular(5),
            ),
          )
          .animate(target: i == _currentPage ? 1 : 0)
          .scaleX(
            begin: i == _currentPage ? 0.5 : 1.0,
            end: i == _currentPage ? 1.0 : 0.5,
            duration: 300.ms,
            curve: Curves.easeOut,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sliding content area
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                OnboardContent1(),
                OnboardContent2(),
                OnboardContent3(),
              ],
            ),
          ),
          
          // Fixed bottom section
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator (fixed)
                    _buildPageIndicator()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 1200.ms)
                      .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0), duration: 500.ms, curve: Curves.easeOutBack, delay: 1200.ms),
                    
                    SizedBox(height: 40),
                    
                    // Button or navigation for last page
                    if (_currentPage == 2) ...[
                      PrimaryButton(
                        label: "Get Started",
                        onPressed: _completeOnboarding,
                      )
                      .animate(key: ValueKey('button-onboard3'))
                      .fadeIn(duration: 400.ms, delay: 600.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                        delay: 600.ms,
                      ),
                      SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14,
                            color: Color.fromARGB(183, 0, 0, 0),
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _completeOnboarding,
                            ),
                          ],
                        ),
                      )
                      .animate(key: ValueKey('login-text-onboard3'))
                      .fadeIn(duration: 400.ms, delay: 800.ms),
                    ] else ...[
                      // Skip button for first two pages
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 50),
                          TextButton(
                            onPressed: _skipToEnd,
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                            .animate(key: ValueKey('skip-$_currentPage'))
                            .fadeIn(duration: 300.ms, delay: 100.ms),
                            style: TextButton.styleFrom(  
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 