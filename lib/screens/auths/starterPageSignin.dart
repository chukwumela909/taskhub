import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/auths/signUpTasker/signup_tasker.dart';
import 'package:taskhub/screens/auths/signUpUser/signup_user.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/screens/auths/starterPage.dart';
import 'package:taskhub/theme/const_value.dart';

class StarterPageSignin extends StatefulWidget {
  const StarterPageSignin({Key? key}) : super(key: key);

  @override
  _StarterPageSigninState createState() => _StarterPageSigninState();
}

class _StarterPageSigninState extends State<StarterPageSignin> {
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
              const SizedBox(height: 30),
              _buildLogo(),
              const SizedBox(height: 32),

              // -- Title: "Join us Today!" --
              Align(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    text: 'Welcome ',
                    style: const TextStyle(
                      fontSize: 30,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Back!',
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Geist',
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
                "Sign in to manage your tasks and projects.",
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
                child: const Text(
                  "Sign up as",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
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
                        MaterialPageRoute(builder: (context) => SignInUser()),
                      );
                    } else {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInTasker()),
                      );
                    }
                  }),
              const SizedBox(height: 32),

              // -- Bottom "Have an account? Login" --
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Geist',
                          color: black.withOpacity(0.7),
                          fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement navigation to login
                        debugPrint("Login tapped");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StarterPage()),
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Geist',
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
    return Image.asset('assets/icons/taskhub-dark.png', width: 120);
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
        border: Border.all(
          color: Color.fromARGB(55, 126, 100, 16),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/warning-icon.svg'),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attention",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: attentionWarning,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "International students and visa holders must ensure they are "
                  "eligible for self-employment or freelance work before offering services.",
                  style: TextStyle(
                      fontSize: 14,
                      color: attentionWarning.withOpacity(0.6),
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
