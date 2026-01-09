import 'package:flutter/material.dart';
import '../models/compatibility_score.dart';

class CompatibilityScoreCard extends StatelessWidget {
  final CompatibilityScore score;
  final VoidCallback? onTap;

  const CompatibilityScoreCard({
    super.key,
    required this.score,
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
          gradient: LinearGradient(
            colors: _getGradientColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors()[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  score.getScoreCategory(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${score.totalScore.toStringAsFixed(0)}% ${score.getScoreEmoji()}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Score breakdown
            _buildScoreBar(context, 'Interest', score.interestAlignment),
            const SizedBox(height: 8),
            _buildScoreBar(context, 'Location', score.locationProximity),
            const SizedBox(height: 8),
            _buildScoreBar(context, 'Communication', score.communicationStyle),
            const SizedBox(height: 8),
            _buildScoreBar(context, 'Values', score.valueAlignment),
            const SizedBox(height: 16),
            // Top reasons
            if (score.topMatchReasons.isNotEmpty) ...[
              Text(
                'Why you match:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              ...score.topMatchReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(BuildContext context, String label, double score) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                _getColorForScore(score),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            '${score.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors() {
    if (score.totalScore >= 80) {
      return [const Color(0xFFD4AF37), const Color(0xFFE6C547)]; // Golden
    } else if (score.totalScore >= 60) {
      return [const Color(0xFF0066FF), const Color(0xFF00D4FF)]; // Blue
    } else if (score.totalScore >= 40) {
      return [const Color(0xFFFF6B6B), const Color(0xFFFFB347)]; // Orange-red
    } else {
      return [const Color(0xFF6C757D), const Color(0xFF495057)]; // Gray
    }
  }

  Color _getColorForScore(double score) {
    if (score >= 80) return const Color(0xFFD4AF37); // Golden
    if (score >= 60) return Colors.amber;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }
}
