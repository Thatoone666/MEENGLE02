import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meengle_app/providers/dates_provider.dart';
import 'package:meengle_app/widgets/cards/date_idea_card.dart';
import '../animations/premium_animations.dart';

class DatesDiscoveryScreen extends StatefulWidget {
  const DatesDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DatesDiscoveryScreen> createState() => _DatesDiscoveryScreenState();
}

class _DatesDiscoveryScreenState extends State<DatesDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatesProvider>().loadDateIdeas();
      _listController.forward();
    });
  }

  @override
  void dispose() {
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
          'Date Ideas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<DatesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: PremiumLoadingIndicator(
                color: Color(0xFFD4AF37),
              ),
            );
          }

          if (provider.dateIdeas.isEmpty) {
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
                          color: Colors.amber.shade400,
                          intensity: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.amber.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No date ideas available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                itemCount: provider.dateIdeas.length,
                itemBuilder: (context, index) {
                  final date = provider.dateIdeas[index];
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
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
                      child: DateIdeaCard(
                        dateIdea: date,
                        onBook: () => provider.bookDate(date.id),
                        onTap: () => _showDateDetails(context, date),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDateDetails(BuildContext context, dynamic date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)?.animation ??
                AlwaysStoppedAnimation(1),
            curve: Curves.easeOut,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date.description,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GlowingButton(
                  glowColor: Colors.amber.shade700,
                  onPressed: () {
                    context.read<DatesProvider>().bookDate(date.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Book This Date'),
                ),
              ),
            ],
          ),
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
            elevation: 8,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
