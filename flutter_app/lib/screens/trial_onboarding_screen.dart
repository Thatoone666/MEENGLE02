import 'package:flutter/material.dart';
import '../models/meengle_tier_system.dart';
import '../services/payment_service.dart';
import '../services/analytics_service.dart';

/// 4-page trial onboarding screen for new users
/// Shows features and offers 7-day free trial
class TrialOnboardingScreen extends StatefulWidget {
  final Function(MeengleTier) onTrialStarted;
  final bool isNewUser;

  const TrialOnboardingScreen({
    required this.onTrialStarted,
    this.isNewUser = true,
    Key? key,
  }) : super(key: key);

  @override
  State<TrialOnboardingScreen> createState() => _TrialOnboardingState();
}

class _TrialOnboardingState extends State<TrialOnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  String? _selectedGoal;
  bool _isLoadingTrial = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        children: [
          _buildPage1_Welcome(),
          _buildPage2_Goal(),
          _buildPage3_Features(),
          _buildPage4_TrialOffer(),
        ],
      ),
    );
  }

  /// Page 1: Welcome Screen
  Widget _buildPage1_Welcome() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '?? Welcome to Meengle',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Find genuine connections.\nNo nonsense.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                AnalyticsService.logEvent('trial_onboarding_page1_next', {});
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page 2: Goal Selection
  Widget _buildPage2_Goal() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What\'s your goal?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGoalButton('?? Serious Relationship', 'serious'),
            const SizedBox(height: 12),
            _buildGoalButton('?? Casual Dating', 'casual'),
            const SizedBox(height: 12),
            _buildGoalButton('?? Just Exploring', 'exploring'),
            const SizedBox(height: 32),
            if (_selectedGoal != null)
              ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  AnalyticsService.logEvent(
                    'trial_onboarding_goal_selected',
                    {'goal': _selectedGoal},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build goal selection button
  Widget _buildGoalButton(String label, String value) {
    final selected = _selectedGoal == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedGoal = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37).withAlpha(50) : Colors.grey[900],
          border: Border.all(
            color: selected ? const Color(0xFFD4AF37) : Colors.grey[700]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFD4AF37) : Colors.white,
          ),
        ),
      ),
    );
  }

  /// Page 3: Feature Showcase
  Widget _buildPage3_Features() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock Premium Features',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 24),
            _buildFeatureItem(
              '??',
              'Video Profiles',
              'See real people with authentic videos',
            ),
            _buildFeatureItem(
              '?',
              'Super Likes',
              'Stand out with super likes to match faster',
            ),
            _buildFeatureItem(
              '??',
              'Rewind',
              'Undo your last swipe (5 per day)',
            ),
            _buildFeatureItem(
              '?',
              'Spotlight',
              '5x visibility boost in local feed',
            ),
            _buildFeatureItem(
              '??',
              'Passport',
              'Match with people while traveling',
            ),
            _buildFeatureItem(
              '?',
              'Verified Badge',
              'Show others you\'re verified & trusted',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  AnalyticsService.logEvent(
                    'trial_onboarding_features_viewed',
                    {'goal': _selectedGoal},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'See Trial Offer ?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build feature item with icon and description
  Widget _buildFeatureItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Page 4: Trial Offer
  Widget _buildPage4_TrialOffer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              '?? Claim Your\n7-Day Free Trial',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            /// Trial Offer Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withAlpha(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '?? Flame Premium',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$0 for 7 days',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Then \$9.99/month',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildOfferBenefit('? Cancel anytime - no commitment'),
                  _buildOfferBenefit('? Full access to all Flame features'),
                  _buildOfferBenefit(
                    '? No credit card charge until trial ends',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// Start Trial Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingTrial ? null : _startFreeTrial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  disabledBackgroundColor: Colors.grey[600],
                ),
                child: _isLoadingTrial
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text(
                        'Start Free Trial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            /// Skip Button
            TextButton(
              onPressed: () {
                AnalyticsService.logEvent(
                  'trial_onboarding_skipped',
                  {'goal': _selectedGoal},
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build offer benefit item
  Widget _buildOfferBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    );
  }

  /// Start 7-day free trial
  Future<void> _startFreeTrial() async {
    setState(() => _isLoadingTrial = true);

    try {
      // Call backend to create 7-day trial
      final response = await PaymentService.createFreeTrial(
        tier: MeengleTier.flame,
        durationDays: 7,
      );

      if (mounted) {
        if (response != null && response['success'] == true) {
          // Log analytics
          AnalyticsService.logEvent('trial_started', {
            'goal': _selectedGoal,
            'tier': 'flame',
            'duration': 7,
            'duration_unit': 'days',
            'timestamp': DateTime.now().toIso8601String(),
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('?? Welcome to Flame Premium! Enjoy 7 days free.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Notify parent and close
          widget.onTrialStarted(MeengleTier.flame);
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to start trial');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting trial: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        AnalyticsService.logEvent('trial_start_error', {
          'error': e.toString(),
          'goal': _selectedGoal,
        });

        setState(() => _isLoadingTrial = false);
      }
    }
  }
}
