import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/animations.dart';
import '../config/chat_styles.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final bool isMine;
  final String? replyText;
  final VoidCallback? onReplyTap;
  final String time;
  final Map<String, String>? reactions;
  final bool isSeen;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    this.replyText,
    this.onReplyTap,
    required this.time,
    this.reactions,
    this.isSeen = false,
    this.onLongPress,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _reactionController;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final isWideScreen = MediaQuery.of(context).size.width > ChatStyles.narrowScreenWidth;
    
    return Padding(
      padding: ChatStyles.getMessagePadding(isWideScreen),
      child: Column(
        crossAxisAlignment:
            widget.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: widget.onLongPress,
            child: Align(
              alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: ChatStyles.getMessageWidth(context),
                    ),
                    padding: EdgeInsets.all(isWideScreen ? 16 : 12),
                    decoration: BoxDecoration(
                      color: widget.isMine
                          ? theme.colorScheme.primary.withAlpha(77)
                          : theme.colorScheme.surface.withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                    ),
                    child: Column(
                      crossAxisAlignment: widget.isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.replyText != null)
                          GestureDetector(
                            onTap: widget.onReplyTap,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: widget.isMine
                                    ? Colors.white.withAlpha(51)
                                    : Colors.black.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.replyText!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isMine
                                      ? Colors.white.withAlpha(179)
                                      : Colors.white.withAlpha(204),
                                ),
                              ),
                            ),
                          ),
                        Text(
                          widget.text,
                          style: ChatStyles.getMessageTextStyle(isWideScreen).copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.reactions?.isNotEmpty ?? false)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                right: widget.isMine ? 16 : 0,
                left: widget.isMine ? 0 : 16,
              ),
              child: Wrap(
                spacing: 4,
                children: widget.reactions!.entries.map((entry) {
                  return _buildReactionBubble(entry.value);
                }).toList(),
              ),
            ),
          if (widget.isSeen)
            const Padding(
              padding: EdgeInsets.only(right: 16.0, top: 4.0),
              child: Text(
                'Seen',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReactionBubble(String reaction) {
    return ScaleTransition(
      scale: ReactionAnimations.popScale(_reactionController),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          reaction,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}