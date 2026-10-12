import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const AppLogo({super.key, this.size = 48, this.borderRadius = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C75D8).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/icons/Icon_logo_mobileApp.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
