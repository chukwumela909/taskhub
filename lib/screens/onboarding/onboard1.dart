import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskhub/screens/onboarding/onboard2.dart';
import 'package:taskhub/theme/const_value.dart';



// Content widget for use in PageView
class OnboardContent1 extends StatelessWidget {
  final VoidCallback onProceed;
  final Widget pageIndicator;

  const OnboardContent1({
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            SvgPicture.asset(
              'assets/images/onboard2.svg',
              width: 280,
              height: 280,
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms, curve: Curves.easeInOut),
            SizedBox(height: 40),
            RichText(
              text: TextSpan(
                text: 'Run errands ',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 24,
                  color: Color.fromARGB(183, 0, 0, 0),
                  fontWeight: FontWeight.w700,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'quickly',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 600.ms)
            .slideY(begin: 20, end: 0, duration: 600.ms, curve: Curves.easeOut, delay: 600.ms),
            SizedBox(height: 10),
            Text(
              "Fast delivery with ready-to-go runners. ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                color: Color.fromARGB(138, 0, 0, 0),
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 900.ms)
            .slideY(begin: 15, end: 0, duration: 500.ms, curve: Curves.easeOut, delay: 900.ms),
            SizedBox(height: 40),
            pageIndicator
              .animate()
              .fadeIn(duration: 400.ms, delay: 1200.ms)
              .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0), duration: 500.ms, curve: Curves.easeOutBack, delay: 1200.ms),
            SizedBox(height: 70),
          
         
          ],
        ),
      ),
    );
  }
}
