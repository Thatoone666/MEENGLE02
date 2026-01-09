import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meengle_note.dart';
import '../providers/notes_provider.dart';
import '../animations/premium_animations.dart';

class NotesScreen extends StatefulWidget {
  final String userId;

  const NotesScreen({super.key, required this.userId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    Future.microtask(() {
      if (mounted) {
        context.read<NotesProvider>().loadNotes('current_user');
        _listController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'NOTES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade700,
                  width: 1.5,
                ),
                boxShadow: PremiumAnimations.premiumGlow(
                  color: Colors.amber.shade700,
                  intensity: 0.3,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    maxLength: 280,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Leave a note...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      counterStyle: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GlowingButton(
                      glowColor: Colors.amber.shade700,
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          context
                              .read<NotesProvider>()
                              .addNote(widget.userId, _controller.text);
                          _controller.clear();
                        }
                      },
                      child: const Text(
                        'Post Note',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: PremiumLoadingIndicator(
                      color: Color(0xFFD4AF37),
                    ),
                  );
                }

                if (provider.notes.isEmpty) {
                  return FadeTransition(
                    opacity: _listController,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: PremiumAnimations.premiumGlow(
                                color: Colors.amber.shade700,
                                intensity: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.note,
                              size: 64,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No notes yet',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave a note to break the ice',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _listController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _listController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.notes.length,
                      itemBuilder: (context, index) {
                        final note = provider.notes[index];
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1)
                              .animate(
                            CurvedAnimation(
                              parent: _listController,
                              curve: Interval(
                                (index * 0.08).clamp(0.0, 0.8),
                                ((index * 0.08) + 0.4).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _listController,
                                curve: Interval(
                                  (index * 0.08).clamp(0.0, 0.8),
                                  ((index * 0.08) + 0.4).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: _NoteCard(
                              note: note,
                              onLike: () => provider.likeNote(note.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final MeengleNote note;
  final VoidCallback onLike;

  const _NoteCard({required this.note, required this.onLike});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: PremiumAnimations.macroDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _onLike() {
    _likeController.forward().then((_) {
      _likeController.reverse();
    });
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1.5),
        boxShadow: PremiumAnimations.premiumGlow(
          color: Colors.amber.shade700,
          intensity: 0.2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anonymous',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'now',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.note.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
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
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.note.likes}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlowingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color glowColor;

  const GlowingButton({
    required this.onPressed,
    required this.child,
    this.glowColor = const Color(0xFFFF6B9A),
    Key? key,
  }) : super(key: key);

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: PremiumAnimations.macroDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPressed() {
    _glowController.forward().then((_) {
      _glowController.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 0.95).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeIn),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: PremiumAnimations.premiumGlow(
            color: widget.glowColor,
            intensity: 0.5 + (_glowController.value * 0.5),
          ),
        ),
        child: ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.glowColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 8,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class PremiumLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PremiumLoadingIndicator({
    this.color = const Color(0xFFFF6B9A),
    this.size = 50,
    Key? key,
  }) : super(key: key);

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: RotationTransition(
        turns: _rotationController,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: PremiumAnimations.premiumGlow(
              color: widget.color,
              intensity: 0.7 + (_pulseController.value * 0.3),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withAlpha(100),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withAlpha(51),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
