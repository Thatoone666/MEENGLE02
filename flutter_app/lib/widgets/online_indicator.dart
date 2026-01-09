import 'package:flutter/material.dart';

class OnlineIndicator extends StatefulWidget {
  final bool isOnline;
  final double size;
  final bool showText;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
    this.showText = true,
  });

  @override
  OnlineIndicatorState createState() => OnlineIndicatorState();
}

class OnlineIndicatorState extends State<OnlineIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.isOnline ? 1.0 : 0.5,
      child: Row(
        children: [
          Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.isOnline ? Colors.greenAccent[400] : Colors.grey)),
          if (widget.showText) ...[
            SizedBox(width: widget.size / 2),
            Text(
              widget.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: widget.size * 1.5,
                color: widget.isOnline ? Colors.greenAccent[400] : Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
