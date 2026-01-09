import 'package:flutter/material.dart';
import '../../../models/meengle_verify.dart';
import '../../animations/premium_animations.dart';

class VerificationBadgeDisplay extends StatefulWidget {
  final UserVerificationBadge badge;
  final int trustScore;

  const VerificationBadgeDisplay({
    required this.badge,
    required this.trustScore,
    Key? key,
  }) : super(key: key);

  @override
  State<VerificationBadgeDisplay> createState() =>
      _VerificationBadgeDisplayState();
}

class _VerificationBadgeDisplayState extends State<VerificationBadgeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Color _getTrustColor() {
    if (widget.trustScore >= 80) return Colors.green.shade400;
    if (widget.trustScore >= 60) return Colors.amber.shade400;
    return Colors.orange.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trust Score Card
        AnimatedBuilder(
          animation: _scoreController,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade700,
                  width: 1.5,
                ),
                boxShadow: PremiumAnimations.premiumGlow(
                  color: Colors.amber.shade700,
                  intensity: 0.4 + (_scoreController.value * 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trust Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: PremiumAnimations.premiumGlow(
                            color: _getTrustColor(),
                            intensity: 0.6 + (_scoreController.value * 0.2),
                          ),
                        ),
                        child: Text(
                          '${widget.trustScore}%',

                          style: TextStyle(
                            color: _getTrustColor(),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTrustColor().withAlpha(51),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: LinearProgressIndicator(
                                  value: widget.trustScore / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getTrustColor(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.trustScore >= 80
                                  ? 'Highly Trusted'
                                  : widget.trustScore >= 60
                                      ? 'Trusted'
                                      : 'Building Trust',
                              style: TextStyle(
                                color: _getTrustColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Verified Badges
        Text(
          'Verified As',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var type in widget.badge.verifiedTypes)
              GlowingBadge(
                label: type.label,
                color: Colors.green.shade400,
                icon: Icons.check_circle,
              ),
            if (widget.badge.verifiedTypes.isEmpty)
              Text(
                'No verifications yet',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),

        // Pending Verifications
        if (widget.badge.pendingTypes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Pending Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var type in widget.badge.pendingTypes)
                GlowingBadge(
                  label: type.label,
                  color: Colors.orange.shade400,
                  icon: Icons.schedule,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withAlpha(77),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withAlpha((50 * _glowController.value).toInt()),
                blurRadius: 8 + (_glowController.value * 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 14),
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
