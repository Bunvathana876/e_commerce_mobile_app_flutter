import 'package:flutter/material.dart';

// App brand logo icon with rounded corners and drop shadow.
class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final String imagePath;

  const AppLogo({
    super.key,
    this.size = 48,
    this.borderRadius = 14,
    this.imagePath = 'assets/images/logo_panda_blue.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
