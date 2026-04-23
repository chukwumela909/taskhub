import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskhub/theme/const_value.dart';



// Content widget for use in PageView
class OnboardContent3 extends StatelessWidget {
  const OnboardContent3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
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
            Spacer(),
          ],
        ),
      ),
    );
  }
}
