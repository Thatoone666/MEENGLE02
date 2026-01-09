import 'package:flutter/material.dart';
import 'boost_offer_card.dart';
import '../services/analytics_service.dart';

/// Persistent boost offer banner to show at key moments
class BoostBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final List<BoostOffer> offers;
  final Function(BoostOffer) onBoostSelected;
  final VoidCallback onDismiss;
  final Color? backgroundColor;

  const BoostBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.offers,
    required this.onBoostSelected,
    required this.onDismiss,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (backgroundColor ?? const Color(0xFFD4AF37)).withAlpha(40),
            (backgroundColor ?? const Color(0xFFD4AF37)).withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(
            color: backgroundColor ?? const Color(0xFFD4AF37),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
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
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  AnalyticsService.logEvent('boost_banner_dismissed', {
                    'title': title,
                  });
                  onDismiss();
                },
                icon: const Icon(Icons.close, color: Colors.white60),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Horizontal scroll of boost offers
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < offers.length - 1 ? 12 : 0,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: GestureDetector(
                      onTap: () {
                        AnalyticsService.logEvent(
                          'boost_banner_offer_tapped',
                          {
                            'boost_id': offer.id,
                            'banner_title': title,
                            'price': offer.price,
                          },
                        );
                        onBoostSelected(offer);
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
                            /// Icon and title
                            Row(
                              children: [
                                Text(
                                  offer.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    offer.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            /// Price
                            Text(
                              '\$${offer.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),

                            /// Get button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  'Get Now',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

/// Builder for common boost banner scenarios
class BoostBannerBuilder {
  /// Banner for when user gets 3+ matches
  static BoostBanner matchesBoost({
    required Function(BoostOffer) onBoostSelected,
    required VoidCallback onDismiss,
  }) {
    return BoostBanner(
      title: '?? Your Profile is Hot!',
      subtitle: 'You\'ve got matches! Boost to get even more.',
      icon: '??',
      offers: BoostOffers.postMatchBoosts,
      onBoostSelected: onBoostSelected,
      onDismiss: onDismiss,
      backgroundColor: const Color(0xFFFF6B6B),
    );
  }

  /// Banner for when user runs out of super likes
  static BoostBanner noSuperLikesBoost({
    required Function(BoostOffer) onBoostSelected,
    required VoidCallback onDismiss,
  }) {
    return BoostBanner(
      title: '? Out of Super Likes!',
      subtitle: 'Get more super likes to stand out.',
      icon: '?',
      offers: BoostOffers.noSuperLikesBoosts,
      onBoostSelected: onBoostSelected,
      onDismiss: onDismiss,
      backgroundColor: const Color(0xFFFFD700),
    );
  }

  /// Banner for when user completes profile
  static BoostBanner profileCompletionBoost({
    required Function(BoostOffer) onBoostSelected,
    required VoidCallback onDismiss,
  }) {
    return BoostBanner(
      title: '? Profile Complete!',
      subtitle: 'Boost your visibility to attract more matches.',
      icon: '??',
      offers: BoostOffers.defaultOffers,
      onBoostSelected: onBoostSelected,
      onDismiss: onDismiss,
      backgroundColor: const Color(0xFF4CAF50),
    );
  }

  /// Banner for special promotional offers
  static BoostBanner promotionalBoost({
    required String title,
    required String subtitle,
    required String icon,
    required List<BoostOffer> offers,
    required Function(BoostOffer) onBoostSelected,
    required VoidCallback onDismiss,
    Color? backgroundColor,
  }) {
    return BoostBanner(
      title: title,
      subtitle: subtitle,
      icon: icon,
      offers: offers,
      onBoostSelected: onBoostSelected,
      onDismiss: onDismiss,
      backgroundColor: backgroundColor,
    );
  }
}

/// Controller to manage boost banner display
class BoostBannerController {
  static final BoostBannerController _instance =
      BoostBannerController._internal();

  factory BoostBannerController() {
    return _instance;
  }

  BoostBannerController._internal();

  final List<_BannerState> _bannerStates = [];

  /// Show banner based on trigger
  void showBannerForTrigger({
    required String trigger,
    required Function(BoostOffer) onBoostSelected,
    required VoidCallback onDismiss,
  }) {
    AnalyticsService.logEvent('boost_banner_shown', {
      'trigger': trigger,
    });

    // Implementation would show appropriate banner based on trigger
    // Triggers: 'matches', 'no_super_likes', 'profile_complete', 'promo'
  }

  /// Check if banner should be shown for trigger
  bool shouldShowBannerFor(String trigger) {
    // Check if user has already dismissed this banner recently
    final existing = _bannerStates.firstWhere(
      (b) => b.trigger == trigger,
      orElse: () => _BannerState(trigger, DateTime.now()),
    );

    // Don't show if dismissed in last 24 hours
    final hoursSinceDismiss =
        DateTime.now().difference(existing.dismissedAt).inHours;
    return hoursSinceDismiss >= 24;
  }

  /// Record banner dismissal
  void recordDismissal(String trigger) {
    final index = _bannerStates.indexWhere((b) => b.trigger == trigger);
    if (index >= 0) {
      _bannerStates[index] = _BannerState(trigger, DateTime.now());
    } else {
      _bannerStates.add(_BannerState(trigger, DateTime.now()));
    }
  }
}

/// Internal state for banner dismissals
class _BannerState {
  final String trigger;
  final DateTime dismissedAt;

  _BannerState(this.trigger, this.dismissedAt);
}
