import 'package:flutter/material.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(SmoothPageRoute(page: const LoginScreen()));
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).push(SmoothPageRoute(page: const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Background 3D Illustration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: Image.asset(
              'assets/images/bg_welcome_page.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 2. Subtle Dark Gradient Overlay behind text for maximum readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Top Header Bar (Brand Badge + Skip Button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Logo & Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 18,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Blue Panda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Hero Text positioned right above the bottom sheet
          Positioned(
            left: 24,
            right: 24,
            bottom: size.height * 0.52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to Blue Panda',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    shadows: [
                      Shadow(
                        color: Color(0x99000000),
                        offset: Offset(0, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to keep orders, wishlist items and saved delivery addresses with you.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        color: Color(0x88000000),
                        offset: Offset(0, 1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. White Bottom Card with Action Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Apple Button with Bouncing Tap Animation
                    BouncingButton(
                      onTap: () => _navigateToLogin(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apple, size: 24, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Continue with Apple',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Google Button with Bouncing Tap Animation
                    BouncingButton(
                      onTap: () => _navigateToLogin(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGoogleIcon(),
                            const SizedBox(width: 10),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider "or"
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Continue with Email Button with Bouncing Tap Animation
                    BouncingButton(
                      onTap: () => _navigateToLogin(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Continue with email',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D652D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Privacy Policy Footer
                    Text(
                      'By continuing you agree to our Terms & Conditions and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Don't have an account? Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _navigateToSignUp(context),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pure Flutter 4-color Google 'G' icon
  static Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Google Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.4,
      false,
      paint,
    );

    // Google Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.9,
      1.3,
      false,
      paint,
    );

    // Google Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2,
      1.1,
      false,
      paint,
    );

    // Google Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.3,
      1.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
