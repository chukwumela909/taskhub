import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final double radius;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;

  const ProfilePictureWidget({
    Key? key,
    this.profilePictureUrl,
    this.radius = 30,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
            ? Image.network(
                profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/profile-picture.png',
                    fit: BoxFit.cover,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : Image.asset(
                'assets/images/profile-picture.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
} 