import 'package:flutter/material.dart';

class PaymentErrorDialog extends StatelessWidget {
  final String error;

  const PaymentErrorDialog({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          const Text('Payment Error'),
        ],
      ),
      content: Text(error),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}