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
  // Prevent duplicate navigations and handle hot-reload resiliency
  bool _navigated = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // Re-run the navigation check on hot reload to avoid being stuck on splash
  @override
  void reassemble() {
    super.reassemble();
    if (!_navigated && !_checking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_navigated && !_checking) {
          _checkAuthAndNavigate();
        }
      });
    }
  }
  
  Future<void> _checkAuthAndNavigate() async {
    if (_navigated || _checking) return;
    _checking = true;
    try {
      // Minimal splash delay for brand visibility
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted || _navigated) return;

      // Don't block navigation on location dialog; handle later in-app
      // _checkLocationServices(); // intentionally not awaited to avoid splash lockups

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthenticationStatus();

      if (!mounted || _navigated) return;

      if (authProvider.isAuthenticated) {
        // Navigate to appropriate home screen
        if (authProvider.isTasker) {
          _navigateOnce(const TaskerHomeScreen());
        } else {
          _navigateOnce(const HomeScreen());
        }
      } else {
        // Check onboarding status
        final isOnboardingCompleted = await PreferencesService.isOnboardingCompleted();
        if (!mounted || _navigated) return;

        if (isOnboardingCompleted) {
          _navigateOnce(const StarterPage());
        } else {
          _navigateOnceWithFade(const OnboardingWrapper());
        }
      }
    } finally {
      _checking = false;
    }
  }

  void _navigateOnce(Widget page) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateOnceWithFade(Widget page) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(context, _createFadeRoute(page));
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
      // Schedule dialog post-frame so it doesn't compete with navigation
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationServicesDialog(
            onLocationEnabled: () {
              // The LocationServicesDialog handles re-checking status
            },
          ),
        );
      });
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