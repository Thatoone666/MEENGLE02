import 'package:flutter/material.dart';
import '../models/conversation_starter.dart';

class IcebreakerWidget extends StatelessWidget {
  final ConversationStarter starter;
  final VoidCallback onSend;
  final VoidCallback? onSkip;
  final String currentTone; // 'playful', 'thoughtful', 'romantic'

  const IcebreakerWidget({
    super.key,
    required this.starter,
    required this.onSend,
    this.onSkip,
    this.currentTone = 'thoughtful',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getToneColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getToneColors()[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Suggestion',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (starter.isGenerated)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Personalized',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            starter.question,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (starter.followUpSuggestion != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tip: ${starter.followUpSuggestion}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (onSkip != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              if (onSkip != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _getToneColors()[0],
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getToneColors() {
    switch (currentTone) {
      case 'romantic':
        return [const Color(0xFFE74C3C), const Color(0xFFE91E63)]; // Red-pink
      case 'playful':
        return [const Color(0xFFFF6B6B), const Color(0xFFFFD93D)]; // Orange-yellow
      case 'thoughtful':
      default:
        return [const Color(0xFF3498DB), const Color(0xFF2E86DE)]; // Blue
    }
  }
}

/// Card showing conversation momentum indicator
class ConversationMomentumIndicator extends StatelessWidget {
  final String momentum; // 'heating_up', 'stable', 'cooling_down'
  final double engagementScore;

  const ConversationMomentumIndicator({
    super.key,
    required this.momentum,
    required this.engagementScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBackgroundColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMomentumIcon(),
            color: _getBackgroundColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getMomentumText(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _getBackgroundColor(),
                ),
              ),
              Text(
                'Engagement: ${engagementScore.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getBackgroundColor().withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMomentumIcon() {
    switch (momentum) {
      case 'heating_up':
        return Icons.trending_up;
      case 'cooling_down':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  String _getMomentumText() {
    switch (momentum) {
      case 'heating_up':
        return 'Conversation heating up! 🔥';
      case 'cooling_down':
        return 'Conversation slowing down';
      case 'stable':
      default:
        return 'Stable conversation';
    }
  }

  Color _getBackgroundColor() {
    switch (momentum) {
      case 'heating_up':
        return Colors.red;
      case 'cooling_down':
        return Colors.orange;
      case 'stable':
      default:
        return Colors.blue;
    }
  }
}
