import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/screens/onboarding/onboard2.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter/gestures.dart';
import 'package:taskhub/services/preferences_service.dart';



// Content widget for use in PageView
class OnboardContent3 extends StatelessWidget {
  final VoidCallback onProceed;
  final Widget pageIndicator;

  const OnboardContent3({
    Key? key,
    required this.onProceed,
    required this.pageIndicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            SvgPicture.asset(
              'assets/images/onboard3.svg',
              width: 280,
              height: 280,
            )
            .animate(key: ValueKey('image-onboard3'))
            .fadeIn(duration: 400.ms)
            .moveY(begin: 20, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            SizedBox(height: 40),
            RichText(
              text: TextSpan(
                text: 'Help ',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 24,
                  color: Color.fromARGB(183, 0, 0, 0),
                  fontWeight: FontWeight.w700,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'deliver ',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'tasks',
                    style: TextStyle(
                      color: Color.fromARGB(183, 0, 0, 0),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
            .animate(key: ValueKey('title-onboard3'))
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOut, delay: 300.ms),
            SizedBox(height: 10),
            Text(
              "Track and manage tasks with ease.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                color: Color.fromARGB(138, 0, 0, 0),
              ),
            )
            .animate(key: ValueKey('subtitle-onboard3'))
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideX(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut, delay: 400.ms),
            SizedBox(height: 30),
            pageIndicator,
            SizedBox(height: 110),
            PrimaryButton(
              label: "Get Started",
              onPressed: onProceed,
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
                      ..onTap = onProceed,
                  ),
                ],
              ),
            )
            .animate(key: ValueKey('login-text-onboard3'))
            .fadeIn(duration: 400.ms, delay: 800.ms),
            SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
