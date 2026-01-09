import 'package:flutter/material.dart';
import '../widgets/boost_banner.dart';
import '../widgets/boost_offer_card.dart';
import './payment_service.dart';
import './analytics_service.dart';

/// Service to manage boost offer triggers and display logic
class BoostOfferTriggerService {
  static final BoostOfferTriggerService _instance =
      BoostOfferTriggerService._internal();

  factory BoostOfferTriggerService() {
    return _instance;
  }

  BoostOfferTriggerService._internal();

  final BoostBannerController _bannerController = BoostBannerController();
  final Map<String, DateTime> _triggerHistory = {};

  /// Check and potentially show boost for user matches
  Future<bool> checkMatchesBoost({
    required int currentMatchCount,
    required BuildContext? context,
    required Function(BoostOffer)? onBoostSelected,
  }) async {
    // Show boost offer when user gets 3+ matches
    if (currentMatchCount >= 3 &&
        _bannerController.shouldShowBannerFor('matches')) {
      if (context != null) {
        _showBoostBanner(
          context,
          BoostBannerBuilder.matchesBoost(
            onBoostSelected: (offer) {
              AnalyticsService.logEvent('boost_offer_accepted', {
                'trigger': 'matches',
                'boost_id': offer.id,
                'match_count': currentMatchCount,
              });
              onBoostSelected?.call(offer);
            },
            onDismiss: () {
              _bannerController.recordDismissal('matches');
            },
          ),
        );
        return true;
      }
    }
    return false;
  }

  /// Check and potentially show boost when super likes run out
  Future<bool> checkNoSuperLikesBoost({
    required int remainingSuperLikes,
    required BuildContext? context,
    required Function(BoostOffer)? onBoostSelected,
  }) async {
    // Show boost when user has 0 super likes left
    if (remainingSuperLikes == 0 &&
        _bannerController.shouldShowBannerFor('no_super_likes')) {
      if (context != null) {
        _showBoostBanner(
          context,
          BoostBannerBuilder.noSuperLikesBoost(
            onBoostSelected: (offer) {
              AnalyticsService.logEvent('boost_offer_accepted', {
                'trigger': 'no_super_likes',
                'boost_id': offer.id,
              });
              onBoostSelected?.call(offer);
            },
            onDismiss: () {
              _bannerController.recordDismissal('no_super_likes');
            },
          ),
        );
        return true;
      }
    }
    return false;
  }

  /// Check and potentially show boost for profile completion
  Future<bool> checkProfileCompletionBoost({
    required double profileCompletion,
    required BuildContext? context,
    required Function(BoostOffer)? onBoostSelected,
  }) async {
    // Show boost when profile is 100% complete
    if (profileCompletion >= 1.0 &&
        _bannerController.shouldShowBannerFor('profile_complete')) {
      if (context != null) {
        _showBoostBanner(
          context,
          BoostBannerBuilder.profileCompletionBoost(
            onBoostSelected: (offer) {
              AnalyticsService.logEvent('boost_offer_accepted', {
                'trigger': 'profile_complete',
                'boost_id': offer.id,
              });
              onBoostSelected?.call(offer);
            },
            onDismiss: () {
              _bannerController.recordDismissal('profile_complete');
            },
          ),
        );
        return true;
      }
    }
    return false;
  }

  /// Show promotional boost offer
  void showPromotionalBoost({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required List<BoostOffer> offers,
    required Function(BoostOffer) onBoostSelected,
    Color? backgroundColor,
  }) {
    AnalyticsService.logEvent('promotional_boost_shown', {
      'title': title,
      'offer_count': offers.length,
    });

    _showBoostBanner(
      context,
      BoostBannerBuilder.promotionalBoost(
        title: title,
        subtitle: subtitle,
        icon: icon,
        offers: offers,
        onBoostSelected: (offer) {
          AnalyticsService.logEvent('promotional_boost_accepted', {
            'title': title,
            'boost_id': offer.id,
          });
          onBoostSelected(offer);
        },
        onDismiss: () {
          // Record promotional dismissal
          AnalyticsService.logEvent('promotional_boost_dismissed', {
            'title': title,
          });
        },
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show boost offer dialog (alternative to banner)
  Future<BoostOffer?> showBoostDialog({
    required BuildContext context,
    required String title,
    required String message,
    required List<BoostOffer> offers,
  }) async {
    AnalyticsService.logEvent('boost_dialog_shown', {
      'title': title,
      'offer_count': offers.length,
    });

    return showModalBottomSheet<BoostOffer>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),

              /// Boost options grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return GestureDetector(
                    onTap: () {
                      AnalyticsService.logEvent('boost_dialog_offer_selected', {
                        'boost_id': offer.id,
                        'price': offer.price,
                      });
                      Navigator.pop(context, offer);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.all(
                          color: offer.isPopular ?? false
                              ? const Color(0xFFD4AF37)
                              : Colors.grey[700]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${offer.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Process boost purchase
  Future<bool> purchaseBoost({
    required BoostOffer offer,
    required Function()? onSuccess,
  }) async {
    try {
      AnalyticsService.logEvent('boost_purchase_started', {
        'boost_id': offer.id,
        'price': offer.price,
      });

      // Call payment service to process purchase
      final result = await PaymentService.purchaseBoost(
        boostId: offer.id,
        price: offer.price,
      );

      if (result != null && result['success'] == true) {
        AnalyticsService.logEvent('boost_purchase_completed', {
          'boost_id': offer.id,
          'price': offer.price,
          'transaction_id': result['transaction_id'],
        });

        onSuccess?.call();
        return true;
      } else {
        AnalyticsService.logEvent('boost_purchase_failed', {
          'boost_id': offer.id,
          'error': result?['error'] ?? 'Unknown error',
        });
        return false;
      }
    } catch (e) {
      AnalyticsService.logEvent('boost_purchase_error', {
        'boost_id': offer.id,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Show boost banner overlay
  void _showBoostBanner(BuildContext context, BoostBanner banner) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: banner,
        actions: [],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
