import 'package:flutter/material.dart';
import '../utils/animations.dart';
import '../config/chat_styles.dart';

class TypingIndicator extends StatefulWidget {
  final String username;
  final Color dotColor;
  final Color textColor;

  const TypingIndicator({
    super.key,
    required this.username,
    this.dotColor = Colors.white54,
    this.textColor = Colors.white70,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _dotAnimations = List.generate(
      3,
      (index) => TypingIndicatorAnimations.dotScale(_controller, index),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > ChatStyles.narrowScreenWidth;
    final dotSize = ChatStyles.getTypingIndicatorSize(isWideScreen);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.username} is typing',
          style: TextStyle(
            color: widget.textColor,
            fontSize: isWideScreen ? 14 : 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: _dotAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _dotAnimations[index].value,
                  child: child,
                );
              },
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: widget.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}