import 'package:flutter/material.dart';
import '../../../models/meengle_note.dart';
import '../../animations/premium_animations.dart';

class NoteCard extends StatefulWidget {
  final MeengleNote note;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const NoteCard({
    required this.note,
    required this.onLike,
    required this.onReply,
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: PremiumAnimations.macroDuration,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: PremiumAnimations.medioDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onLike() {
    _likeController.forward().then((_) {
      _likeController.reverse();
    });
    widget.onLike();
  }

  void _onReply() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onReply();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 0.98).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade700, width: 1),
          boxShadow: PremiumAnimations.premiumGlow(
            color: Colors.amber.shade700,
            intensity: 0.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.isAnonymous ? 'Anonymous' : 'User ${note.fromUserId.substring(0, 8)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          note.type.label,
                          style: TextStyle(
                            color: Colors.amber.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(
                        Icons.close,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: const TextStyle(
                color: Colors.white,
                height: 1.6,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.2).animate(
                    CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
                  ),
                  child: GestureDetector(
                    onTap: _onLike,
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.likes}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _onReply,
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${note.replies.length}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
