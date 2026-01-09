import 'package:flutter/material.dart';
import '../../../models/meengle_story.dart';
import '../../animations/premium_animations.dart';

class StoryCard extends StatefulWidget {
  final MeengleStory story;
  final VoidCallback onTap;
  final VoidCallback onReact;

  const StoryCard({
    required this.story,
    required this.onTap,
    required this.onReact,
    Key? key,
  }) : super(key: key);

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: PremiumAnimations.medioDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onTap();
  }

  void _onReact() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onReact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Column(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.95).animate(
              CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
            ),
            child: Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.story.isViewed
                      ? Colors.grey.shade700
                      : Colors.amber.shade700,
                  width: 2,
                ),
                color: const Color(0xFF1A1A1A),
                boxShadow: PremiumAnimations.premiumGlow(
                  color: widget.story.isViewed
                      ? Colors.grey.shade700
                      : Colors.amber.shade700,
                  intensity: widget.story.isViewed ? 0.3 : 0.6,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.story.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      'Story',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Viewed Indicator
                  if (widget.story.isViewed)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onReact,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 0.85).animate(
                    CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Icon(
                    Icons.favorite_outline,
                    color: Colors.amber.shade400,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.story.likeCount.toString(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
