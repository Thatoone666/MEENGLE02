import 'package:flutter/material.dart';
import '../models/user_insight.dart';

class UserInsightsDashboard extends StatelessWidget {
  final UserInsight insight;
  final List<String> recommendations;
  final VoidCallback onViewPhotos;
  final VoidCallback onUpdateProfile;

  const UserInsightsDashboard({
    super.key,
    required this.insight,
    required this.recommendations,
    required this.onViewPhotos,
    required this.onUpdateProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Weekly Insights',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Last 7 days performance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Key metrics grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetricCard(
                context,
                'Matches',
                insight.matchesReceived.toString(),
                Icons.favorite,
                Colors.red,
              ),
              _buildMetricCard(
                context,
                'Conversations',
                insight.conversationsStarted.toString(),
                Icons.chat,
                Colors.blue,
              ),
              _buildMetricCard(
                context,
                'Response Rate',
                '${insight.responseRate.toStringAsFixed(0)}%',
                Icons.reply,
                Colors.green,
              ),
              _buildMetricCard(
                context,
                'Dates Scheduled',
                insight.datesScheduled.toString(),
                Icons.date_range,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Engagement level
          _buildEngagementSection(context),
          const SizedBox(height: 24),

          // Top interests
          _buildTopInterestsSection(context),
          const SizedBox(height: 24),

          // Conversion metrics
          _buildConversionSection(context),
          const SizedBox(height: 24),

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            Text(
              'Smart Recommendations',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._buildRecommendations(context),
            const SizedBox(height: 24),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewPhotos,
                  icon: const Icon(Icons.image),
                  label: const Text('Photo Performance'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onUpdateProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Engagement Level',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insight.engagementLevel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${insight.messagesSent} messages sent',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopInterestsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Interest Matches',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: insight.topInterestMatches
              .map(
                (interest) => Chip(
                  label: Text(interest),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  labelStyle: theme.textTheme.labelMedium,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildConversionSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion Metrics',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildConversionMetric(
                context,
                'Match to Conversation',
                '${insight.conversionRate.toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 16),
              _buildConversionMetric(
                context,
                'Avg Compatibility',
                '${insight.estimatedCompatibility.toStringAsFixed(1)}/100',
              ),
              const SizedBox(height: 16),
              _buildConversionMetric(
                context,
                'Messages per Conversation',
                (insight.messagesSent / (insight.conversationsStarted > 0 ? insight.conversationsStarted : 1)).toStringAsFixed(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversionMetric(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecommendations(BuildContext context) {
    final theme = Theme.of(context);
    return recommendations
        .map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
