import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskhub/screens/auths/signUpTasker/signup_tasker.dart';
import 'package:taskhub/screens/auths/signUpUser/signup_user.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/starterPageSignin.dart';
import 'package:taskhub/theme/const_value.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({Key? key}) : super(key: key);

  @override
  _StarterPageState createState() => _StarterPageState();
}

// Custom slide transition route
Route _createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut; // Changed for a more dynamic feel

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500), // Slightly longer
  );
}

class _StarterPageState extends State<StarterPage> {
  String _selectedRole = 'User';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- Logo / Header Section --
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 15),

              // -- Title: "Join us Today!" --
              Align(
                alignment: Alignment.center, 
                child: RichText(
                  text: TextSpan(
                    text: 'Join us ',
                    style:  GoogleFonts.bricolageGrotesque(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Today!',
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
              const Text(
                "Be part of our platform today, see what's taskable",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Geist',
                  color: Colors.black54,
                  
                ),
              ),
              const SizedBox(height: 32),

              // -- "Sign up as" --
               Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Sign up as",
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff606060),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // -- Toggle Buttons: "User" and "Taskers" --
              _buildRoleButton(
                label: 'User',
                isSelected: _selectedRole == 'User',
                onTap: () => setState(() => _selectedRole = 'User'),
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                label: 'Taskers',
                isSelected: _selectedRole == 'Taskers',
                onTap: () => setState(() => _selectedRole = 'Taskers'),
                color: primaryColor,
              ),
              const SizedBox(height: 24),

              // -- "Proceed" Button --
              PrimaryButton(
                  label: "Proceed",
                  onPressed: () {
                    if (_selectedRole == 'User') {
                      Navigator.push(
                        context,
                        _createSlideRoute(SignUpUser()),
                      );
                    } else {
                       Navigator.push(
                        context,
                        _createSlideRoute(SignUpTasker()),
                      );
                    }
                  }),
              const SizedBox(height: 32),

              // -- Attention Box --
              const AttentionBox(),
              const SizedBox(height: 32),

              // -- Bottom "Have an account? Login" --
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                          style: GoogleFonts.bricolageGrotesque(
                              fontSize: 18,
                              color: black.withOpacity(0.7),
                            fontWeight: FontWeight.w400),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement navigation to login
                        debugPrint("Login tapped");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StarterPageSignin()),
                        );
                      },
                      child: Text(
                        "Login",
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
    );
  }

  /// Logo widget at the top of the screen.
  /// Replace the placeholder with your actual asset or network image.
  Widget _buildLogo() {
    return Image.asset('assets/icons/taskhub-dark.png', width: 80);
  }

  /// Builds the "User" / "Taskers" role selection buttons.
  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xfff6f3fb),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Color(0xfff6f3fb),
              width: 1,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? color : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttentionBox extends StatelessWidget {
  const AttentionBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color boxColor = Color(0xFFFFF9E6);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        border: Border(
          left: BorderSide(
            color: Color.fromARGB(55, 126, 100, 16),
            width: 3,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start  ,
        children: [
          Icon(Icons.warning_rounded, color: attentionWarning, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Attention",
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: attentionWarning,
                        ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                    "For Taskers: Make sure you register with data that matches your official documents.",
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 14,
                      color: attentionWarning.withOpacity(0.6),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
