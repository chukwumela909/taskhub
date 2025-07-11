import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/auths/signUpUser/signup_user3.dart';
import 'package:taskhub/screens/auths/sign_in_user.dart';
import 'package:taskhub/theme/const_value.dart';

class SignupUser2 extends StatefulWidget {
  const SignupUser2({Key? key}) : super(key: key);

  @override
  _SignupUser2State createState() => _SignupUser2State();
}

class _SignupUser2State extends State<SignupUser2> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                            text: 'Join us ',
                            style: const TextStyle(
                              fontSize: 28,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Today !',
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
                    // Circle on the top-right
                    SvgPicture.asset('assets/icons/signup-indicator2.svg'),
                  ],
                ),

                const SizedBox(height: 24),

              // Section title box
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

              // Country field
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
                validator: (value) {
                  // Since it's readonly with default value, we'll always have a value
                  return null;
                },
                prefixIcon: Image.asset(
                  'assets/icons/nigeria-flag.png',
                  height: 2,
                  width: 2,
                ),
              ),
              const SizedBox(height: 16),

              // State field
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
                value: _selectedItem,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedItem = newValue;
                    if (newValue != null) {
                      authProvider.stateController.text = newValue;
                    }
                  });
                },
              ),
              if (_selectedItem == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    'Please select a state',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Address field
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                prefixIcon: SvgPicture.asset(
                  'assets/icons/email-icon.svg',
                  height: 2,
                  width: 2,
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // -- "Proceed" Button
              PrimaryButton(
                label: "Proceed", 
                onPressed: () {
                  // Validate state is selected
                  if (_selectedItem == null) {
                    setState(() {}); // Trigger a rebuild to show error
                    return;
                  }
                  
                  if (_formKey.currentState!.validate()) {
                    authProvider.stateController.text = _selectedItem!;
                    // Set country if empty
                    if (authProvider.countryController.text.isEmpty) {
                      authProvider.countryController.text = "Nigeria";
                    }
                    
                    // Navigate to next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupUser3()),
                    );
                  }
                }
              ),

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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInUser()));
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
    )
  );
  }
}
