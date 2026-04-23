// Colors

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color primaryColor = Color(0xff673AB7);
Color taskerPrimaryColor = Color.fromARGB(255, 142, 79, 249);
Color iconBgColor = Color(0xffF6FCFA);
Color onboardSlider = Color(0xffE8F7F2);
Color black = Color(0xff000000);
Color white = Color(0xffffffff);

Color attentionWarning = Color(0xffad8505);
Color greyColor1 = Color(0xffd1d1d1);
Color textformfill = Color(0xffaeaeae).withOpacity(0.1);
Color greyColor2 = Color(0xff505050);
Color greyColor3 = Color(0xffEDEEF0);

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
     required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: textformfill,
        hintText: hintText,
        hintStyle: TextStyle(
            color: black.withOpacity(0.3), fontSize: 16, fontFamily: 'Geist'),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: suffixIcon,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xff673AB7),
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final String? value;
  final Widget? prefixIcon;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.hintText,
    this.onChanged,
    this.value,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: textformfill,
        hintText: hintText,
        hintStyle: TextStyle(
            color: black.withOpacity(0.3), fontSize: 16, fontFamily: 'Geist'),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
         prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: prefixIcon,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontFamily: 'Geist')),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true, // Makes the dropdown take the full width
    );
  }
}

