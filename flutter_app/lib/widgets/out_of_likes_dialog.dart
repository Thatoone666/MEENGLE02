import 'package:flutter/material.dart';

class OutOfLikesDialog extends StatefulWidget {
  const OutOfLikesDialog({super.key});

  @override
  OutOfLikesDialogState createState() => OutOfLikesDialogState();
}

class OutOfLikesDialogState extends State<OutOfLikesDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text('Out of Likes!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Upgrade to Premium for unlimited swipes and more!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/premium');
                  },
                  child: const Text('Go Premium')),
            ],
          ),
        ),
      ),
    );
  }
}
