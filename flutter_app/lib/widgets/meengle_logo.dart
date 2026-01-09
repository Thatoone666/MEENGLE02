import 'package:flutter/material.dart';

/// Meengle App Logo Widget
/// A vibrant, modern logo representing the social vibe-checking platform
class MeengleLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? accentColor;

  const MeengleLogo({
    super.key,
    this.size = 120,
    this.showText = false,
    this.primaryColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF6366F1); // Indigo
    final accent = accentColor ?? const Color(0xFF06B6D4);   // Cyan

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Mark
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background gradient circle
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: 0.1),
                      accent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              // Outer ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                    width: size * 0.04,
                  ),
                ),
              ),
              // Main logo shape - interlocking circles (vibes connecting)
              CustomPaint(
                size: Size(size, size),
                painter: MeengleLogoPainter(
                  primaryColor: primary,
                  accentColor: accent,
                  size: size,
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'meengle',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              background: Paint()
                ..strokeWidth = 0
                ..color = primary,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size * 0.05),
            child: Text(
              'Check In Your Vibe',
              style: TextStyle(
                fontSize: size * 0.1,
                color: accent,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the Meengle logo
class MeengleLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double size;

  MeengleLogoPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    final radius = size * 0.15;

    // Paint for primary circles
    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Paint for accent circles
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Paint for connecting line (gradient-like effect)
    final linePaint = Paint()
      ..strokeWidth = size * 0.06
      ..strokeCap = StrokeCap.round
      ..color = primaryColor.withValues(alpha: 0.6);

    // Three main circles representing vibes connecting
    // Top circle (primary)
    canvas.drawCircle(
      Offset(centerX, centerY - size * 0.15),
      radius,
      primaryPaint,
    );

    // Bottom-left circle (accent)
    canvas.drawCircle(
      Offset(centerX - size * 0.13, centerY + size * 0.12),
      radius,
      accentPaint,
    );

    // Bottom-right circle (primary with opacity)
    canvas.drawCircle(
      Offset(centerX + size * 0.13, centerY + size * 0.12),
      radius,
      primaryPaint..color = primaryColor.withValues(alpha: 0.8),
    );

    // Connecting lines between circles
    // Top to bottom-left
    canvas.drawLine(
      Offset(centerX - radius * 0.5, centerY - size * 0.1),
      Offset(centerX - size * 0.1, centerY + size * 0.08),
      linePaint,
    );

    // Top to bottom-right
    canvas.drawLine(
      Offset(centerX + radius * 0.5, centerY - size * 0.1),
      Offset(centerX + size * 0.1, centerY + size * 0.08),
      linePaint..color = accentColor.withValues(alpha: 0.6),
    );

    // Bottom-left to bottom-right
    canvas.drawLine(
      Offset(centerX - size * 0.1, centerY + size * 0.18),
      Offset(centerX + size * 0.1, centerY + size * 0.18),
      linePaint..color = primaryColor.withValues(alpha: 0.4),
    );

    // Center accent dot (the "spark" of connection)
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 0.5,
      Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(MeengleLogoPainter oldDelegate) => false;
}

/// Compact logo for app bars
class MeengleLogoCompact extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? accentColor;

  const MeengleLogoCompact({
    super.key,
    this.size = 40,
    this.primaryColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return MeengleLogo(
      size: size,
      showText: false,
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
  }
}

/// Full logo with text for splash/intro screens
class MeengleLogoBranding extends StatelessWidget {
  final double size;
  final bool animated;

  const MeengleLogoBranding({
    super.key,
    this.size = 200,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.5 + (0.5 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: MeengleLogo(
          size: size,
          showText: true,
        ),
      );
    }

    return MeengleLogo(
      size: size,
      showText: true,
    );
  }
}

/// Simple circular app icon logo
class MeengleAppIcon extends StatelessWidget {
  final double size;

  const MeengleAppIcon({
    super.key,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFF06B6D4), // Cyan
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: Center(
        child: MeengleLogo(
          size: size * 0.7,
          primaryColor: Colors.white,
          accentColor: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

