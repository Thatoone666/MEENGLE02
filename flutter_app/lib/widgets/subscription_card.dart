import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final double price;
  final List<String> features;
  final VoidCallback onSubscribe;
  final bool highlighted;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.onSubscribe,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: highlighted ? 8 : 2,
      color: highlighted ? theme.colorScheme.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: highlighted ? theme.colorScheme.onPrimary : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R ${price.toStringAsFixed(2)} / month',
              style: theme.textTheme.titleLarge?.copyWith(
                color: highlighted ? theme.colorScheme.onPrimary : null,
              ),
            ),
            const Divider(height: 32),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: highlighted 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: highlighted ? theme.colorScheme.onPrimary : null,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlighted 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                  foregroundColor: highlighted 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Subscribe Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}