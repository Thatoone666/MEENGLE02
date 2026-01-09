import 'package:flutter/material.dart';
import 'package:meengle_flutter/models/meengle_verify.dart';

/// Widget to display a single verification badge
class VerificationBadge extends StatelessWidget {
  final UserVerification verification;
  final bool isActive;

  const VerificationBadge({
    super.key,
    required this.verification,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(verification.type);
    final icon = _getIconForType(verification.type);

    return Tooltip(
      message: _getLabel(verification.type),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              _getLabel(verification.type),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.close,
                  color: Colors.red.shade400,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(VerificationType type) {
    switch (type) {
      case VerificationType.phone:
        return Colors.blue.shade400;
      case VerificationType.email:
        return Colors.purple.shade400;
      case VerificationType.face:
        return Colors.green.shade400;
      case VerificationType.idDocument:
        return Colors.amber.shade600;
      case VerificationType.video:
        return Colors.cyan.shade400;
      case VerificationType.social:
        return Colors.pink.shade400;
      case VerificationType.background:
        return Colors.red.shade600;
    }
  }

  IconData _getIconForType(VerificationType type) {
    switch (type) {
      case VerificationType.phone:
        return Icons.phone;
      case VerificationType.email:
        return Icons.email;
      case VerificationType.face:
        return Icons.face;
      case VerificationType.idDocument:
        return Icons.badge;
      case VerificationType.video:
        return Icons.videocam;
      case VerificationType.social:
        return Icons.share;
      case VerificationType.background:
        return Icons.security;
    }
  }

  String _getLabel(VerificationType type) {
    switch (type) {
      case VerificationType.phone:
        return 'Phone';
      case VerificationType.email:
        return 'Email';
      case VerificationType.face:
        return 'Face';
      case VerificationType.idDocument:
        return 'ID';
      case VerificationType.video:
        return 'Video';
      case VerificationType.social:
        return 'Social';
      case VerificationType.background:
        return 'Background';
    }
  }
}

/// Widget to display all verification badges for a user
class VerificationBadgeDisplay extends StatelessWidget {
  final UserVerificationBadge badges;
  final int trustScore;
  final VoidCallback? onSeeMore;

  const VerificationBadgeDisplay({
    super.key,
    required this.badges,
    this.trustScore = 0,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final verifications = badges.verifications
        .where((v) => v.isActive)
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.shade700,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trust score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust Score',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badges.trustScore}/100',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade400,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.shade600,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${badges.trustScore}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade400,
                        ),
                      ),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Verification badges
          if (verifications.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified With',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: verifications
                      .map((v) => VerificationBadge(
                            verification: v,
                            isActive: true,
                          ))
                      .toList(),
                ),
              ],
            )
          else
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No verifications yet',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Next steps
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.shade700,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amber.shade400,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Boost Your Trust',
                      style: TextStyle(
                        color: Colors.amber.shade400,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify your face or ID to increase your trust score and get more matches!',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
