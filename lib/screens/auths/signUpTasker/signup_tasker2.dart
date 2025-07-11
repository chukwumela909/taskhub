import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/signUpTasker/signup_tasker3.dart';
import 'package:taskhub/screens/auths/sign_in_tasker.dart';
import 'package:taskhub/theme/const_value.dart';

class SignupTasker2 extends StatefulWidget {
  const SignupTasker2({ Key? key }) : super(key: key);

  @override
  _SignupTasker2State createState() => _SignupTasker2State();
}

class _SignupTasker2State extends State<SignupTasker2> {
  String? _selectedResidentState;
  String? _selectedOriginState;
  final List<String> _dropdownItems = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara'
  ];
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Spacing at the top --
              const SizedBox(height: 16),

              // -- Row for "Join us Today!" and the top-right circle --
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "Join us Today!"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Earn with ',
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Us !',
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // -- Subtitle --
                      Text(
                        "Be part of our platform today,\nsee what's possible",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Geist',
                          color: black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  // Circle on the top-right (placeholder for a progress indicator or avatar)
                  SvgPicture.asset('assets/icons/signup-indicator2.svg'),
                ],
              ),

              const SizedBox(height: 24),

           
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/shield-icon.svg',
                        height: 24, width: 24),
                    const SizedBox(width: 8),
                    Text(
                      "Nationality & Residence",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "2/3",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Geist',
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

        
              Text(
                "Country",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: authProvider.countryController,
                readOnly: true,
                hintText: "Nigeria",
                prefixIcon: Image.asset(
                  'assets/icons/nigeria-flag.png',
                  height: 2,
                  width: 2,
                ),
              ),
               const SizedBox(height: 16),


              Text(
                "State of Residence",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomDropdown(
                items: _dropdownItems,
                hintText: 'Select a state',
                value: _selectedResidentState,
        
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedResidentState = newValue;
                    authProvider.residentStateController.text = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                "State of Origin",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomDropdown(
                items: _dropdownItems,
                hintText: 'Select a state',
                value: _selectedOriginState,
        
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOriginState = newValue;
                    authProvider.originStateController.text = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              
          
              Text(
                "Address",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Geist',
                    color: black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: authProvider.addressController,
                hintText: "e.g  123, Main Street",
                prefixIcon: SvgPicture.asset(
                  'assets/icons/email-icon.svg',
                  height: 2,
                  width: 2,
                ),
              ),
              const SizedBox(height: 16),

             

              const SizedBox(height: 32),

              // -- "Proceed" Button with a lock icon --
              PrimaryButton(label: "Proceed", onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupTasker3()),
                );
              }),

              const SizedBox(height: 32),

              // -- Bottom "Have an account? Login" --
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInTasker()),
                       );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
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
}