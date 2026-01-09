import 'package:flutter/material.dart';
import 'package:meengle_flutter/widgets/meengle_logo.dart';

/// Splash Screen with Meengle Logo
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.95),
              const Color(0xFF06B6D4).withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1).animate(
                  CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                ),
                child: const MeengleLogoBranding(
                  size: 180,
                  animated: false,
                ),
              ),
              const SizedBox(height: 48),
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Check In Your Vibe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 3,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo preview/demo screen
class LogoPreviewScreen extends StatelessWidget {
  const LogoPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meengle Logo Showcase'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            // Logo sizes
            _LogoSection(
              title: 'Full Logo with Text',
              child: const MeengleLogo(size: 150, showText: true),
            ),
            const SizedBox(height: 48),
            _LogoSection(
              title: 'Logo Mark Only',
              child: const MeengleLogo(size: 120, showText: false),
            ),
            const SizedBox(height: 48),
            _LogoSection(
              title: 'Compact Logo (App Bar)',
              child: const MeengleLogoCompact(size: 48),
            ),
            const SizedBox(height: 48),
            _LogoSection(
              title: 'App Icon',
              child: const MeengleAppIcon(size: 100),
            ),
            const SizedBox(height: 48),
            _LogoSection(
              title: 'Branding (Animated)',
              child: const MeengleLogoBranding(size: 150, animated: true),
            ),
            const SizedBox(height: 48),
            // Color variations
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Color Variations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeengleLogo(
                        size: 80,
                        primaryColor: const Color(0xFF6366F1),
                        accentColor: const Color(0xFF06B6D4),
                      ),
                      MeengleLogo(
                        size: 80,
                        primaryColor: const Color(0xFFEC4899),
                        accentColor: const Color(0xFFF59E0B),
                      ),
                      MeengleLogo(
                        size: 80,
                        primaryColor: const Color(0xFF10B981),
                        accentColor: const Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _LogoSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Center(child: child),
        ],
      ),
    );
  }
}
