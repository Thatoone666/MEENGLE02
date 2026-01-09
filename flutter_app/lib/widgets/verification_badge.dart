import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final String? verificationType; // 'phone', 'email', 'social', 'all'
  final DateTime? verifiedAt;
  final double size;

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.verificationType,
    this.verifiedAt,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Tooltip(
      message: _getVerificationMessage(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          _getVerificationIcon(),
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  IconData _getVerificationIcon() {
    switch (verificationType) {
      case 'phone':
        return Icons.verified_user;
      case 'email':
        return Icons.mail;
      case 'social':
        return Icons.verified_user;
      case 'all':
        return Icons.verified;
      default:
        return Icons.check_circle;
    }
  }

  String _getVerificationMessage() {
    final type = verificationType ?? 'identity';
    return 'Verified $type';
  }
}

/// Display multiple verification badges horizontally
class VerificationBadgesRow extends StatelessWidget {
  final Map<String, bool> verifications; // {'phone': true, 'email': true}
  final double spacing;
  final double size;

  const VerificationBadgesRow({
    super.key,
    required this.verifications,
    this.spacing = 4,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final verified = verifications.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (verified.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      children: verified
          .map((type) => VerificationBadge(
            isVerified: true,
            verificationType: type,
            size: size,
          ))
          .toList(),
    );
  }
}

/// Profile completion indicator with verification
class VerificationProgress extends StatelessWidget {
  final int verifiedCount;
  final int totalVerifications;

  const VerificationProgress({
    super.key,
    required this.verifiedCount,
    required this.totalVerifications,
  });

  @override
  Widget build(BuildContext context) {
    final progress = verifiedCount / totalVerifications;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Verification',
              style: theme.textTheme.labelMedium,
            ),
            Text(
              '$verifiedCount/$totalVerifications',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(
              Colors.blue.withValues(alpha: 0.7),
            ),
          ),
        ),
        if (progress < 1.0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Complete verification to boost visibility',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber,
              ),
            ),
          ),
      ],
    );
  }
}
