import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/location_provider.dart';
import 'package:taskhub/screens/onboarding/onboarding_wrapper.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/screens/user/home.dart';
import 'package:taskhub/screens/tasker/home.dart';
import 'package:taskhub/services/preferences_service.dart';
import 'package:taskhub/widgets/location_services_dialog.dart';

class Splash extends StatefulWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    // Add a delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check location services first
    await _checkLocationServices();
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Explicitly check authentication status and wait for completion
    await authProvider.checkAuthenticationStatus();
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      // User is authenticated, navigate to appropriate home screen
      if (authProvider.isTasker) {
        // Navigate to tasker home
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const TaskerHomeScreen()));
      } else {
        // Navigate to regular user home
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      // User is not authenticated, check if onboarding completed
      final isOnboardingCompleted = await PreferencesService.isOnboardingCompleted();
      
      if (!mounted) return;
      
      if (isOnboardingCompleted) {
        // User has seen onboarding but is not authenticated, go to login flow
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const StarterPage()));
      } else {
        // First time user, show onboarding with fade transition
        Navigator.pushReplacement(
          context,
          _createFadeRoute(const OnboardingWrapper()),
        );
      }
    }
  }
  
  // Create a custom fade route for smooth transitions
  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;

        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  // Check if location services are enabled and show dialog if they're not
  Future<void> _checkLocationServices() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Initialize location to check status
    await locationProvider.initLocation();
    
    // If location services are disabled, show dialog
    if (locationProvider.isLocationServiceDisabled && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationServicesDialog(
          onLocationEnabled: () {
            // This will be called after the user returns from location settings
            // The LocationServicesDialog already handles re-checking location
          },
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/icons/taskhub-dark.png", width: 150, height: 150)
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 800.ms,
            curve: Curves.easeOutBack,
          )
          .animate(onComplete: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 1.seconds,
            curve: Curves.easeInOut,
          ),
      ),
    );
  }
}