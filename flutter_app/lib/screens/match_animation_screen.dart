import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'chat.dart';

class MatchAnimationScreen extends StatefulWidget {
  final String currentUserImageUrl;
  final String user2ImageUrl;
  final Map<String, dynamic> matchedUser;
  final String? currentUserId;

  const MatchAnimationScreen({
    super.key,
    required this.currentUserImageUrl,
    required this.user2ImageUrl,
    required this.matchedUser,
    required this.currentUserId,
  });

  @override
  MatchAnimationScreenState createState() => MatchAnimationScreenState();
}

class MatchAnimationScreenState extends State<MatchAnimationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A80), Color(0xFFFF4081)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, Object? value, child) {
                      final scale = value as double;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.currentUserImageUrl),
                          radius: 50,
                        ),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.user2ImageUrl),
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, Object? value, child) {
                      final opacity = value as double;
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: const Text(
                      "It's a Match!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(204)),
                        onPressed: () {
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Keep Swiping',
                            style: TextStyle(color: Colors.pink)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not identify current user.')));
                            return;
                          }
                          if (!mounted) return;
                          // Pop this screen, then push the chat screen with all required arguments
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChatScreen(),
                                  settings: RouteSettings(arguments: {
                                    'userId': widget.currentUserId,
                                    'match': widget.matchedUser
                                  })));
                        },
                        child: const Text('Send a Message'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
                createParticlePath: (size) {
                  final path = Path();
                  path.addOval(Rect.fromCircle(
                      center: Offset.zero, radius: size.width / 2));
                  return path;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
