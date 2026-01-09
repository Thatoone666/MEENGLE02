import 'package:flutter/material.dart';

class SuspiciousAccountWarningDialog extends StatelessWidget {
  final String score;
  final List<String> flags;
  final VoidCallback onContinue;
  final VoidCallback? onDelete;

  const SuspiciousAccountWarningDialog({
    required this.score,
    required this.flags,
    required this.onContinue,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
      title: const Text('Account Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account has been flagged for review based on:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...flags.map((flag) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(flag)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'This is temporary. Our team will review and respond within 24 hours.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        if (onDelete != null)
          TextButton(
            onPressed: onDelete,
            child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
