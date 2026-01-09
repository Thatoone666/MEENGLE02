import 'package:flutter/material.dart';
import '../services/spotlight_service.dart';
import '../models/meengle_spotlight.dart';

class SpotlightPurchaseScreen extends StatefulWidget {
  const SpotlightPurchaseScreen({super.key});

  @override
  State<SpotlightPurchaseScreen> createState() =>
      _SpotlightPurchaseScreenState();
}

class _SpotlightPurchaseScreenState extends State<SpotlightPurchaseScreen> {
  late SpotlightService _spotlightService;
  MeengleSpotlight? _activeSpotlight;
  bool _isLoading = true;

  final Map<SpotlightTier, Map<String, dynamic>> _tierDetails = {
    SpotlightTier.bronze: {
      'price': '\$4.99',
      'hours': 1,
      'views': '100+',
      'features': [
        '1 hour boost',
        'Priority in feed',
        'View counter',
      ]
    },
    SpotlightTier.silver: {
      'price': '\$9.99',
      'hours': 6,
      'views': '500+',
      'features': [
        '6 hour boost',
        'Prime placement',
        'View analytics',
        'Like notifications',
      ]
    },
    SpotlightTier.gold: {
      'price': '\$19.99',
      'hours': 24,
      'views': '2000+',
      'features': [
        '24 hour boost',
        'Top of feed',
        'Detailed analytics',
        'Instant notifications',
        'Priority support',
      ]
    },
    SpotlightTier.platinum: {
      'price': '\$49.99',
      'hours': 72,
      'views': '5000+',
      'features': [
        '72 hour boost',
        'Top of all feeds',
        'Premium analytics',
        'VIP badge',
        'Dedicated support',
        'Bonus features',
      ]
    },
  };

  @override
  void initState() {
    super.initState();
    _spotlightService = SpotlightService();
    _loadActiveSpotlight();
  }

  Future<void> _loadActiveSpotlight() async {
    try {
      setState(() => _isLoading = true);
      // Note: In a real app, get the actual userId from auth provider
      final spotlight = await _spotlightService.getUserActiveSpotlight('current_user_id');
      setState(() {
        _activeSpotlight = spotlight;
      });
    } catch (e) {
      debugPrint('Error loading spotlight: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseSpotlight(SpotlightTier tier) async {
    try {
      setState(() => _isLoading = true);

      // Show payment processing dialog
      if (!mounted) return;
      _showPaymentProcessingDialog();

      // In a real implementation, you would:
      // 1. Create a Stripe payment intent
      // 2. Handle Stripe payment flow
      // 3. Confirm payment on backend
      // 4. Emit Socket.io event for real-time status

      // For now, simulate the purchase
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context); // Close processing dialog

      // Show success
      _showSuccessDialog(tier);

      // Reload spotlight data
      await _loadActiveSpotlight();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close processing dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPaymentProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.amber.shade700),
            const SizedBox(height: 16),
            const Text(
              'Processing payment...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(SpotlightTier tier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        icon: Icon(Icons.check_circle, color: Colors.green.shade400, size: 64),
        title: const Text(
          'Spotlight Activated!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Your ${tier.toString().split('.').last} Spotlight is now active.',
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(color: Colors.amber.shade700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Spotlight',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Active Spotlight Banner
                  if (_activeSpotlight != null)
                    _buildActiveSpotlightBanner(),

                  // Info Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get More Visibility',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Boost your profile to the top and get seen by more matches',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tier Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: SpotlightTier.values
                          .map((tier) => _buildTierCard(tier))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FAQ Section
                  _buildFAQSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveSpotlightBanner() {
    final tier = _activeSpotlight!.tier;
    final remaining = _activeSpotlight!.expiresAt.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade700.withValues(alpha: 0.3),
            Colors.amber.shade900.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Active: ${tier.toString().split('.').last.toUpperCase()}',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Time remaining: ${hours}h ${minutes}m',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Impressions: ${_activeSpotlight!.impressionCount}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(SpotlightTier tier) {
    final details = _tierDetails[tier]!;
    final isActive = _activeSpotlight?.tier == tier;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.amber.shade700.withValues(alpha: 0.15) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.amber.shade700 : Colors.amber.shade700.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: isActive ? Colors.amber.shade700 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${details['hours']}h boost',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      details['price'],
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${details['views']} views',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            ...(details['features'] as List<String>)
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActive || _isLoading
                    ? null
                    : () => _purchaseSpotlight(tier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.grey[700] : Colors.amber.shade700,
                  disabledBackgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isActive ? 'Currently Active' : 'Upgrade Now',
                  style: TextStyle(
                    color: isActive ? Colors.white54 : Colors.white,
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

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFAQItem(
            'Increased Visibility',
            'Your profile appears at the top of discovery feeds.',
          ),
          _buildFAQItem(
            'Real-time Analytics',
            'Track views and interactions as they happen.',
          ),
          _buildFAQItem(
            'Priority Matching',
            'Appear first in match recommendations.',
          ),
          _buildFAQItem(
            'Auto-Expiration',
            'Boost automatically deactivates after time expires.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
