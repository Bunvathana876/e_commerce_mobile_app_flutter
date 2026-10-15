import 'package:flutter/material.dart';
import '../../../shared/widgets/bouncing_button.dart';

// Social login buttons section with Google, Facebook, X, and Apple options.
class SocialLoginSection extends StatelessWidget {
  final void Function(String provider)? onProviderSelected;

  const SocialLoginSection({super.key, this.onProviderSelected});

  void _handleTap(BuildContext context, String provider) {
    if (onProviderSelected != null) {
      onProviderSelected!(provider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signing in with $provider...'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Divider with centered "or"
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? const Color(0xFF253248)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? const Color(0xFF253248)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Headline
        Text(
          'Join With Your Favourite Social Media Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF334155),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),

        // 4 Social login cards
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google
            _SocialCard(
              onTap: () => _handleTap(context, 'Google'),
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(painter: _GoogleLogoPainter()),
              ),
            ),
            const SizedBox(width: 14),

            // Facebook
            _SocialCard(
              onTap: () => _handleTap(context, 'Facebook'),
              child: const Icon(
                Icons.facebook,
                size: 28,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(width: 14),

            // X / Twitter
            _SocialCard(
              onTap: () => _handleTap(context, 'X'),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: _XLogoPainter(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Apple
            _SocialCard(
              onTap: () => _handleTap(context, 'Apple'),
              child: Icon(
                Icons.apple,
                size: 28,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Rounded square card for social provider buttons
class _SocialCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncingButton(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F30) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF253248) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// Google 4-color G icon painter
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5,
      1.4,
      false,
      paint,
    );

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.9,
      1.3,
      false,
      paint,
    );

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2,
      1.1,
      false,
      paint,
    );

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.3,
      1.2,
      false,
      paint,
    );

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w / 2 - 1, h / 2),
      Offset(w - 1, h / 2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Modern X / Twitter logo painter
class _XLogoPainter extends CustomPainter {
  final Color color;
  const _XLogoPainter({this.color = const Color(0xFF0F172A)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()..fillType = PathFillType.evenOdd;
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Official X outer path
    path.moveTo(18.244, 2.25);
    path.lineTo(21.552, 2.25);
    path.lineTo(14.325, 10.51);
    path.lineTo(22.825, 21.75);
    path.lineTo(16.171, 21.75);
    path.lineTo(10.959, 14.93);
    path.lineTo(4.996, 21.75);
    path.lineTo(1.686, 21.75);
    path.lineTo(9.414, 12.918);
    path.lineTo(1.254, 2.25);
    path.lineTo(8.077, 2.25);
    path.lineTo(12.787, 8.477);
    path.close();

    // Cutout path
    path.moveTo(17.083, 19.77);
    path.lineTo(18.916, 19.77);
    path.lineTo(7.084, 4.126);
    path.lineTo(5.117, 4.126);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

