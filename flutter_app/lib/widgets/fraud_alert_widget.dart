import 'package:flutter/material.dart';
import '../models/fraud_alert.dart';

class FraudAlertBanner extends StatelessWidget {
  final FraudAlert alert;
  final VoidCallback onReportConfirm;
  final VoidCallback onBlockConfirm;
  final VoidCallback? onDismiss;

  const FraudAlertBanner({
    super.key,
    required this.alert,
    required this.onReportConfirm,
    required this.onBlockConfirm,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _getAlertColor();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: backgroundColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.getRiskBadge(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Evidence list
          if (alert.evidence.isNotEmpty) ...[
            ...alert.evidence.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $e',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )),
            const SizedBox(height: 12),
          ],
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (alert.recommendation == 'block')
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBlockConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Block User'),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReportConfirm,
                    child: const Text('Report'),
                  ),
                ),
              const SizedBox(width: 12),
              if (alert.recommendation == 'verify_identity')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show verification dialog
                    },
                    child: const Text('Verify Identity'),
                  ),
                )
              else
                Expanded(
                  child: TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAlertColor() {
    if (alert.riskScore >= 80) return Colors.red;
    if (alert.riskScore >= 60) return Colors.orange;
    return Colors.yellow;
  }
}

/// Safety tip widget to educate users
class SafetyTipCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const SafetyTipCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.blue.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

/// Collection of safety tips
class SafetyTipsSection extends StatelessWidget {
  const SafetyTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Tips',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SafetyTipCard(
          icon: Icons.shield,
          title: 'Never Share Personal Info',
          description:
              'Don\'t share your address, phone, or financial details until you meet in person',
        ),
        const SizedBox(height: 12),
        SafetyTipCard(
          icon: Icons.video_camera_back,
          title: 'Use Video Chat First',
          description: 'Verify identities via video before meeting',
        ),
        const SizedBox(height: 12),
        SafetyTipCard(
          icon: Icons.location_on,
          title: 'Meet in Public',
          description: 'Always meet new matches in public places first',
        ),
        const SizedBox(height: 12),
        SafetyTipCard(
          icon: Icons.people,
          title: 'Tell Someone',
          description: 'Share your date plans and location with a trusted friend',
        ),
      ],
    );
  }
}
