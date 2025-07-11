import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/theme/const_value.dart';

/// A custom loader widget that displays a loading indicator with text.
/// 
/// Shows a purple background loader with a story icon, custom text, and optional
/// cancel button. When shown, it adds a semi-transparent overlay to the screen.


/// A more practical implementation of the loader with animation
class CustomLoaderWithAnimation extends StatefulWidget {
  final String text;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const CustomLoaderWithAnimation({
    Key? key,
    this.text = 'Please wait...',
    this.showCancelButton = false,
    this.onCancel,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String text = 'Please wait...',
    bool showCancelButton = false,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // Semi-transparent overlay
      builder: (context) => CustomLoaderWithAnimation(
        text: text,
        showCancelButton: showCancelButton,
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  State<CustomLoaderWithAnimation> createState() => _CustomLoaderWithAnimationState();
}

class _CustomLoaderWithAnimationState extends State<CustomLoaderWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 254, 254),
        child: Container(
          width: 352,
          height: 60,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            // borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              // Loader icon with rotation animation
              Positioned(
                left: 20,
                top: 18,
                child: RotationTransition(
                  turns: _controller,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: _buildLoaderIcon(),
                  ),
                ),
              ),
              
              // Text
              Positioned(
                left: 61,
                top: 19,
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Color(0xFF673AB7),
                    fontSize: 18,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Cancel button (optional)
              if (widget.showCancelButton)
                Positioned(
                  right: 5,
                  top: 17,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: widget.onCancel,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: SizedBox(
                            width:  26,
                            height: 26,
                            child: _buildCloseIcon(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the loader icon using SVG files.
  Widget _buildLoaderIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/loading-alt-purple.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
        SvgPicture.asset(
          'assets/icons/loading-alt-purple.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
        SvgPicture.asset(
          'assets/icons/loading-alt-purple.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
        SvgPicture.asset(
          'assets/icons/loading-alt-purple.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
      ],
    );
  }

  /// Builds the close icon using SVG files.
  Widget _buildCloseIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/close_circle.svg',
          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
      ],
    );
  }
} 