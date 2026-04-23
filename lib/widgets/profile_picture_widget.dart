import 'package:flutter/material.dart';

/// Profile avatar widget that shows the user's uploaded profile picture when
/// available, falling back to a generated initials avatar (or icon) otherwise.
class ProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl; // Remote image URL
  final String? displayName;       // Used to derive initials / color
  final double radius;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final BoxFit fit;

  const ProfilePictureWidget({
    Key? key,
    this.profilePictureUrl,
    this.displayName,
    this.radius = 30,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  String _initials() {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Color _backgroundColorFromName() {
    final name = displayName ?? '';
    if (name.isEmpty) return const Color(0xFF673AB7); // primary fallback
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
  }

  Widget _buildInitialsFallback() {
    final initials = _initials();
    return Container(
      color: _backgroundColorFromName(),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: radius * 0.9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  fontFamily: 'Geist',
                ),
              )
            : Icon(
                Icons.person,
                size: radius * 1.2,
                color: Colors.white.withOpacity(0.85),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = profilePictureUrl != null && profilePictureUrl!.isNotEmpty;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: hasUrl
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildInitialsFallback(), // Base layer (visible while loading)
                  Image.network(
                    profilePictureUrl!,
                    fit: fit,
                    errorBuilder: (context, error, stack) => _buildInitialsFallback(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildInitialsFallback(),
                          Center(
                            child: SizedBox(
                              width: radius * 0.9,
                              height: radius * 0.9,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
                                value: progress.expectedTotalBytes != null
                                    ? (progress.cumulativeBytesLoaded / (progress.expectedTotalBytes!))
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
            : _buildInitialsFallback(),
      ),
    );
  }
}