import 'package:flutter/material.dart';

class PremiumAnimations {
  // Premium Glow Effect
  static List<BoxShadow> premiumGlow({
    Color color = const Color(0xFFFF6B9A),
    double intensity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withAlpha((60 * intensity).toInt()),
        blurRadius: 15 * intensity,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: color.withAlpha((30 * intensity).toInt()),
        blurRadius: 30 * intensity,
        spreadRadius: 4,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // Parallax Effect
  static Offset parallaxOffset(double scrollOffset, double intensity) {
    return Offset(0, scrollOffset * intensity);
  }

  // Bounce Curve
  static const bounceCurve = Curves.elasticOut;

  // Premium Easing
  static const premiumEasing = Curves.easeOutCubic;

  // Micro-interaction Duration
  static const microDuration = Duration(milliseconds: 200);
  static const medioDuration = Duration(milliseconds: 400);
  static const macroDuration = Duration(milliseconds: 600);
}

/// Premium Glowing Button with haptic feedback and advanced animations
class GlowingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color glowColor;
  final bool enableHaptics;

  const GlowingButton({
    required this.onPressed,
    required this.child,
    this.glowColor = const Color(0xFFFF6B9A),
    this.enableHaptics = true,
    Key? key,
  }) : super(key: key);

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: PremiumAnimations.macroDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (widget.enableHaptics) {
      _triggerHaptic();
    }

    _glowController.forward().then((_) {
      _glowController.reverse();
    });
    widget.onPressed();
  }

  Future<void> _triggerHaptic() async {
    try {
      await Future.delayed(const Duration(milliseconds: 10));
      // Haptic feedback will be added when platform channels are available
    } catch (e) {
      // Ignore haptic errors on unsupported platforms
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: PremiumAnimations.premiumGlow(
            color: widget.glowColor,
            intensity: 0.5 + (_glowController.value * 0.5),
          ),
        ),
        child: ElevatedButton(
          onPressed: _onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated Loading Indicator with premium styling
class PremiumLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PremiumLoadingIndicator({
    this.color = const Color(0xFFFF6B9A),
    this.size = 50,
    Key? key,
  }) : super(key: key);

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: RotationTransition(
        turns: _rotationController,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: PremiumAnimations.premiumGlow(
              color: widget.color,
              intensity: 0.7 + (_pulseController.value * 0.3),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withAlpha(100),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withAlpha(51),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glowing Badge with animation
class GlowingBadge extends StatefulWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const GlowingBadge({
    required this.label,
    required this.color,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<GlowingBadge> createState() => _GlowingBadgeState();
}

class _GlowingBadgeState extends State<GlowingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withAlpha(77),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha((50 * _glowController.value).toInt()),
                blurRadius: 8 + (_glowController.value * 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
