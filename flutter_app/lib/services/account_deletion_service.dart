// flutter_app/lib/services/account_deletion_service.dart

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'analytics_service.dart';

/// Service to handle account deletion with retention trial offer
class AccountDeletionService {
  /// Check if user qualifies for retention offer
  static Future<bool> userQualifiesForRetentionOffer() async {
    try {
      final response = await ApiService.get('/api/user/profile');
      if (response == null) return false;

      final createdAt = DateTime.parse(response['createdAt'] as String);
      final daysActive = DateTime.now().difference(createdAt).inDays;

      // Only 7+ day users qualify
      return daysActive >= 7;
    } catch (e) {
      print('Error checking qualification: $e');
      return false;
    }
  }

  /// Show account deletion dialog with retention offer
  static Future<bool?> showDeletionDialog(BuildContext context) async {
    final qualifies = await userQualifiesForRetentionOffer();

    if (!qualifies) {
      // User doesn't qualify - just confirm deletion
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            '?? Delete Account?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    // User qualifies - show retention offer
    return _showRetentionOfferDialog(context);
  }

  /// Show special retention offer with 24-hour Flame trial
  static Future<bool?> _showRetentionOfferDialog(
    BuildContext context,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                '?? Wait! We have something special',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Offer box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((255 * 0.1).toInt()),
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      '? Flame Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '24 Hours FREE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Experience these features:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('?? Video Profiles'),
                    _buildFeatureItem('?? Unlimited Super Likes'),
                    _buildFeatureItem('?? Rewind Swipes'),
                    _buildFeatureItem('? 5x Spotlight Visibility'),
                    _buildFeatureItem('?? Passport Mode'),
                    _buildFeatureItem('? Verified Badge'),
                    const SizedBox(height: 12),
                    const Text(
                      'Expires in 24 hours automatically',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await _startFlame24HourTrial(context);
                    if (success && context.mounted) {
                      Navigator.pop(context, false); // Don't delete
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '? Your 24-hour Flame trial is active!',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Try Free for 24 Hours',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true), // Delete
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false), // Cancel
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'No credit card required. Cancel trial anytime.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build feature item in offer box
  static Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            feature,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Start 24-hour Flame trial
  static Future<bool> _startFlame24HourTrial(BuildContext context) async {
    try {
      final response = await ApiService.post(
        '/api/tiers/trial/flame-24hour',
        {},
      );

      if (response != null && response['success'] == true) {
        // Log analytics
        AnalyticsService.logEvent('flame_24h_trial_started', {
          'trigger': 'account_deletion_prevention',
          'timestamp': DateTime.now().toIso8601String(),
        });

        return true;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error starting trial. Please try again.')),
        );
      }
      return false;
    } catch (e) {
      print('Error starting trial: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error starting trial')),
        );
      }
      return false;
    }
  }
}
