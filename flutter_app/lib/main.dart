import 'dart:math';
import 'dart:ui' as ui;
import 'theme/color_schemes.dart';
import 'theme/typography.dart';
import 'theme/component_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'repositories/user_repository.dart';
import 'screens/login.dart';
import 'screens/main_screen.dart';
import 'screens/signup.dart';
import 'screens/profile_edit.dart';
import 'screens/matches_list.dart';
import 'screens/match_detail.dart';
import 'screens/chat.dart';
import 'screens/payments.dart';
import 'screens/checkin_screen.dart';
import 'screens/location_checkin_discovery_screen.dart';
import 'screens/prompts_discovery_screen.dart';
import 'screens/moments_discovery_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/circles_discovery_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/dates_screen.dart';
import 'screens/spotlight_screen.dart';
import 'screens/roam_screen.dart';
import 'screens/discovery_screen.dart';
import 'screens/trial_onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/notification_center_screen.dart';
import 'providers/prompt_provider.dart';
import 'providers/moments_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/circles_provider.dart';
import 'providers/stories_provider.dart';
import 'providers/dates_provider.dart';
import 'providers/spotlight_provider.dart';
import 'providers/roam_provider.dart';
import 'providers/discovery_provider.dart';
import 'providers/emergency_contacts_provider.dart';
import 'services/api_service.dart';

// Initialize blocs

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pk =
      const String.fromEnvironment('STRIPE_PUBLISHABLE', defaultValue: '');
  if (pk.isNotEmpty) Stripe.publishableKey = pk;

  final userRepository = UserRepository();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(value: userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(userRepository: userRepository)..add(AppStarted()),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PromptProvider()),
            ChangeNotifierProvider(create: (_) => MomentsProvider()),
            ChangeNotifierProvider(create: (_) => NotesProvider()),
            ChangeNotifierProvider(create: (_) => CirclesProvider()),
            ChangeNotifierProvider(create: (_) => StoriesProvider()),
            ChangeNotifierProvider(create: (_) => DatesProvider()),
            ChangeNotifierProvider(create: (_) => SpotlightProvider()),
            ChangeNotifierProvider(create: (_) => RoamProvider()),
            ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
            ChangeNotifierProvider(create: (_) => EmergencyContactsProvider()),
            Provider<ApiService>(
              create: (_) => ApiService(
                baseUrl: 'http://localhost:3001/api',
              ),
            ),
          ],
          child: MyApp(userRepository: userRepository),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meengle',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: AppColors.darkColorScheme,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: AppTypography.textTheme,
        buttonTheme: ComponentThemes.buttonTheme,
        elevatedButtonTheme: ComponentThemes.elevatedButtonTheme,
        outlinedButtonTheme: ComponentThemes.outlinedButtonTheme,
        textButtonTheme: ComponentThemes.textButtonTheme,
        inputDecorationTheme: ComponentThemes.inputDecorationTheme,
        cardTheme: ComponentThemes.cardTheme,
        appBarTheme: ComponentThemes.appBarTheme,
        bottomNavigationBarTheme: ComponentThemes.bottomNavigationBarTheme,
        listTileTheme: ComponentThemes.listTileTheme,
        snackBarTheme: ComponentThemes.snackBarTheme,
        dialogTheme: ComponentThemes.dialogTheme,
        bottomSheetTheme: ComponentThemes.bottomSheetTheme,
        chipTheme: ComponentThemes.chipTheme,
      ),
      // Show the splash animation first so we can see the startup log and animation
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return MainScreen();
          }
          if (state is AuthUnauthenticated) {
            return LoginScreen();
          }
          if (state is AuthLoading) {
            return LoadingIndicator();
          }
          return SplashScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => MainScreen(),
        '/signup': (context) => SignupScreen(),
        '/profile/edit': (context) => ProfileEditScreen(),
        '/matches': (context) => MatchesListScreen(),
        '/match': (context) => MatchDetailScreen(),
        '/chat': (context) => ChatScreen(),
        '/payments': (context) => PaymentsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/delete-account': (context) => const DeleteAccountScreen(),
        '/notifications': (context) => const NotificationCenterScreen(),
        '/trial': (context) => TrialOnboardingScreen(
              onTrialStarted: (tier) {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/checkin': (context) => const CheckInScreen(locationName: 'Current Location'),
        '/checkin/discovery': (context) => const LocationCheckInDiscoveryScreen(),
        '/prompts': (context) => const PromptsDiscoveryScreen(),
        '/moments': (context) => const MomentsDiscoveryScreen(),
        '/notes': (context) => const NotesScreen(userId: 'current_user'),
        '/circles': (context) => const CirclesDiscoveryScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/dates': (context) => const DatesScreen(),
        '/spotlight': (context) => const SpotlightScreen(),
        '/roam': (context) => const RoamScreen(),
        '/discovery': (context) => const DiscoveryScreen(),
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tailAnim;
  late final Animation<double> _explodeAnim;

  @override
  void initState() {
    super.initState();
    // Console startup log
    // print('Meengle Flutter app started — premium splash');

    // Slightly longer and smoother animation for a premium feel
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1700));
    _tailAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutQuad));
    _explodeAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Vibrant neon gradient background consistent with app theme
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B9A), Color(0xFF7C4DFF)],
              stops: [0.0, 1.0],
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 360,
              height: 260,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _PremiumTailPainter(
                        tailProgress: _tailAnim.value,
                        explode: _explodeAnim.value,
                        time: _controller.value),
                    child: const Center(child: SizedBox.shrink()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumTailPainter extends CustomPainter {
  final double tailProgress;
  final double explode;
  final double time;
  _PremiumTailPainter(
      {required this.tailProgress, required this.explode, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Background glow (soft radial)
    final center = Offset(size.width * 0.5, size.height * 0.55);
    // ignore: deprecated_member_use
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(center, max(size.width, size.height) * 0.8,
          [Colors.white.withAlpha(15), Colors.transparent]);
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Tail path (smoother curve)
    final start = Offset(size.width * 0.08, size.height * 0.62);
    final end = Offset(size.width * 0.92, size.height * 0.62);
    final cp1 = Offset(size.width * 0.32, size.height * 0.20);
    final cp2 = Offset(size.width * 0.68, size.height * 1.05);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    // Glow layer (soft, thicker, low opacity)
    final glow = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.pinkAccent.withAlpha(46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 18);
    canvas.drawPath(path, glow);

    // Gradient stroke for the tail
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight,
        [Color(0xFFFFC0CB), Color(0xFFFF6B9A), Color(0xFFCB7BFF)]);
    final tailPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2);

    // Draw partial path according to tailProgress
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final visible = metric.length * tailProgress;
      final extract = metric.extractPath(0, visible);
      canvas.drawPath(extract, tailPaint);

      // Shimmer: a bright stroke that moves along the visible part
      final shimmerPaint = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.white.withAlpha(217 - (tailProgress * 153).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
      final shimmerPos = min(visible, metric.length);
      final shimmerTangent = metric.getTangentForOffset(shimmerPos);
      if (shimmerTangent != null) {
        final sp = shimmerTangent.position;
        // tiny shimmer arc
        canvas.drawCircle(sp, 6.0 * (1.0 - explode), shimmerPaint);
      }

      // Particles trailing the tail (multi-layered for depth)
      final rnd = (sin(time * pi * 2) + 1) *
          0.5; // deterministic flicker used to vary particle appearance
      for (int layer = 0; layer < 3; layer++) {
        final count = 6 + layer * 4;
        for (int i = 0; i < count; i++) {
          final t = (i / count) * 0.9 * tailProgress; // position along the tail
          final offset = metric.length * t;
          final tangent = metric.getTangentForOffset(offset);
          if (tangent == null) continue;
          final base = tangent.position;
          // use rnd to slightly modulate wobble amplitude for a subtle flicker
          final wobbleAmp = (1.0 - layer * 0.25) * (1.0 + rnd * 0.3);
          final wobble = Offset((sin(time * 6 + i) * 6) * wobbleAmp,
              (cos(time * 5 + i) * 6) * wobbleAmp);
          final dispersion = explode * (20 + layer * 12);
          final pos = base +
              wobble +
              Offset(cos(i + layer) * dispersion, sin(i - layer) * dispersion);
          // apply rnd to particle opacity to create deterministic flicker without exceeding 1.0
          final baseOpacity =
              (0.9 - layer * 0.25 - tailProgress * 0.6).clamp(0.0, 1.0);
          final opacity = (baseOpacity * (0.5 + rnd * 0.5)).clamp(0.0, 1.0);
          // ignore: deprecated_member_use
          final particlePaint = Paint()
            ..color = (layer == 0
                    ? Colors.yellowAccent
                    : (layer == 1 ? Colors.orangeAccent : Colors.pinkAccent))
                .withAlpha((opacity * 255).round());
          final sizeP = (3.5 - layer) * (1.0 - explode * 0.8);
          canvas.drawCircle(pos, max(1.0, sizeP), particlePaint);
        }
      }

      // Tip decoration: a small polished gem + horns
      if (visible > 8) {
        final tipTangent = metric.getTangentForOffset(visible);
        if (tipTangent != null) {
          final pos = tipTangent.position;
          // gem glow
          // ignore: deprecated_member_use
          final gemPaint = Paint()
            ..color = Colors.white.withAlpha(230 - (explode * 153).round());
          canvas.drawCircle(pos, 5.5 * (1.0 - explode * 0.8), gemPaint);
          // colored core
          canvas.drawCircle(pos, 3.0 * (1.0 - explode * 0.8),
              Paint()..color = Color(0xFFFF6B9A));
        }
      }

      // Explosion ring at the tip
      if (explode > 0.01) {
        final exOffset =
            metric.getTangentForOffset(min(visible, metric.length));
        if (exOffset != null) {
          final p = exOffset.position;
          // ignore: deprecated_member_use
          final ringPaint = Paint()
            ..color = Colors.orange.withAlpha((31 * (1.0 - explode)).round());
          final r = 10 + 80 * explode;
          canvas.drawCircle(p, r, ringPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumTailPainter old) {
    return old.tailProgress != tailProgress ||
        old.explode != explode ||
        old.time != time;
  }
}

// Removed unused _DevilTailPainter to avoid analyzer/compile warnings; re-add an implementation here if you need
// a devil-style tail painter in the future.
