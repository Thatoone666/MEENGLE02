import 'package:flutter/material.dart';
import '../config/chat_styles.dart';

class ChatSidePanel extends StatelessWidget {
  final Widget? child;
  final String title;
  final List<Widget> actions;
  final bool isVisible;
  final VoidCallback? onClose;

  const ChatSidePanel({
    super.key,
    this.child,
    required this.title,
    this.actions = const [],
    this.isVisible = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Container(
      width: ChatStyles.sidePanelWidth,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...actions,
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    tooltip: 'Close',
                  ),
              ],
            ),
          ),
          if (child != null)
            Expanded(
              child: child!,
            ),
        ],
      ),
    );
  }
}