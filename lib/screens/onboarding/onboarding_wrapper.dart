import 'package:flutter/material.dart';
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
  bool _isAnimating = false;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isAnimating = true;
    });
    
    // Reset animation flag after the main animations complete
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
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
      backgroundColor: Colors.white, // Explicitly set background color
      body: Column(
        children: [
          // PageView content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                OnboardContent1(
                  onProceed: _nextPage,
                  pageIndicator: _buildPageIndicator(),
                ),
                OnboardContent2(
                  onProceed: _nextPage,
                  pageIndicator: _buildPageIndicator(),
                ),
                OnboardContent3(
                  onProceed: _completeOnboarding,
                  pageIndicator: _buildPageIndicator(),
                ),
              ],
            ),
          ),
          
          // Bottom navigation bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                 SizedBox(width: 50),
                  
                  // Skip button (only on first two pages)
                  _currentPage < 2
                    ? TextButton(
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
                      )
                    : SizedBox(width: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 