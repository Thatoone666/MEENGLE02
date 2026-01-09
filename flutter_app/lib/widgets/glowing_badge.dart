import 'package:flutter/material.dart';
import '../animations/premium_animations.dart';

/// Premium glowing badge widget for displaying time/status with animated glow
class GlowingBadge extends StatefulWidget {
  final String label;
  final Color color;
  final double? fontSize;
  final double? glowIntensity;
  final Duration? animationDuration;
  final EdgeInsets? padding;

  const GlowingBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 13,
    this.glowIntensity = 0.6,
    this.animationDuration,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  State<GlowingBadge> createState() => _GlowingBadgeState();
}

class _GlowingBadgeState extends State<GlowingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: widget.animationDuration ?? const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color.withAlpha((255 * 0.9).toInt()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha((255 * 0.5).toInt()),
              width: 1.5,
            ),
            boxShadow: PremiumAnimations.premiumGlow(
              color: widget.color,
              intensity: widget.glowIntensity! * _glowAnimation.value,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Premium glowing button with animated glow effect
class GlowingButton extends StatefulWidget {
  final Color glowColor;
  final VoidCallback onPressed;
  final Widget child;
  final double? fontSize;
  final double? borderRadius;
  final double? elevation;
  final double? glowIntensity;
  final Duration? animationDuration;
  final EdgeInsets? padding;

  const GlowingButton({
    super.key,
    required this.glowColor,
    required this.onPressed,
    required this.child,
    this.fontSize,
    this.borderRadius = 12,
    this.elevation = 6,
    this.glowIntensity = 0.5,
    this.animationDuration,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: widget.animationDuration ?? const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(widget.borderRadius ?? 12),
              boxShadow: PremiumAnimations.premiumGlow(
                color: widget.glowColor,
                intensity: widget.glowIntensity! *
                    _glowAnimation.value *
                    (_isPressed ? 0.6 : 1.0),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.glowColor,
                      widget.glowColor.withAlpha((255 * 0.8).toInt()),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  border: Border.all(
                    color: Colors.white.withAlpha((255 * 0.3).toInt()),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  child: Container(
                    padding: widget.padding,
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
