import 'package:flutter/material.dart';
import 'package:meengle_flutter/models/meengle_prompt.dart';

/// Card component to display a prompt question with suggested answers
class PromptCard extends StatefulWidget {
  final MeenglePrompt prompt;
  final UserPromptAnswer? existingAnswer;
  final Function(MeenglePrompt) onTapAnswer;
  final bool isAnswered;

  const PromptCard({
    super.key,
    required this.prompt,
    this.existingAnswer,
    required this.onTapAnswer,
    this.isAnswered = false,
  });

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTapAnswer(widget.prompt),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.amber.shade700,
            width: 1.5,
          ),
        ),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.grey[850]!,
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.amber.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryLabel(widget.prompt.category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (widget.isAnswered)
                          Text(
                            '✓ Answered',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isAnswered)
                    Icon(Icons.check_circle, color: Colors.green.shade400),
                ],
              ),
              const SizedBox(height: 16),

              // Question
              Text(
                widget.prompt.question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 16),

              // Suggested answers
              if (widget.prompt.suggestedAnswers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested answers:',
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
                      children: widget.prompt.suggestedAnswers
                          .take(3)
                          .map(
                            (answer) => Chip(
                              label: Text(
                                answer,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              backgroundColor: Colors.amber.shade700.withValues(alpha: 0.3),
                              side: BorderSide(
                                color: Colors.amber.shade600,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onTapAnswer(widget.prompt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isAnswered ? 'Edit Answer' : 'Answer Now',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(PromptCategory category) {
    return category.label;
  }
}
