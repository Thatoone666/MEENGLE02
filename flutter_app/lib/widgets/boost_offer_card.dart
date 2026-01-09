import 'package:flutter/material.dart';
import '../../models/meengle_tier_system.dart';
import '../../services/analytics_service.dart';

/// Boost offer card widget - displays a single boost offer
class BoostOfferCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double price;
  final String icon;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  const BoostOfferCard({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.isHighlighted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnalyticsService.logEvent('boost_offer_tapped', {
          'boost_id': id,
          'price': price,
        });
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withAlpha(60),
                    const Color(0xFFD4AF37).withAlpha(30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFD4AF37)
                : Colors.grey[700]!,
            width: isHighlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withAlpha(40),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon and Title
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
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
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            /// Price and Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Get',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            /// Highlighted Badge
            if (isHighlighted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Most Popular',
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
    );
  }
}

/// Horizontal boost cards grid
class BoostOffersGrid extends StatelessWidget {
  final List<BoostOffer> boosts;
  final Function(BoostOffer) onBoostSelected;

  const BoostOffersGrid({
    required this.boosts,
    required this.onBoostSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: boosts.length,
      itemBuilder: (context, index) {
        final boost = boosts[index];
        return BoostOfferCard(
          id: boost.id,
          title: boost.title,
          description: boost.description,
          price: boost.price,
          icon: boost.icon,
          subtitle: boost.subtitle,
          isHighlighted: boost.isPopular ?? false,
          onTap: () => onBoostSelected(boost),
        );
      },
    );
  }
}

/// Data model for boost offer
class BoostOffer {
  final String id;
  final String title;
  final String description;
  final String icon;
  final double price;
  final String? subtitle;
  final bool? isPopular;

  BoostOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.price,
    this.subtitle,
    this.isPopular = false,
  });
}

/// Predefined boost offers
class BoostOffers {
  static final List<BoostOffer> defaultOffers = [
    BoostOffer(
      id: 'boost_profile',
      title: '?? Boost Profile',
      description: 'Get 3x visibility boost for 24 hours',
      icon: '??',
      price: 2.99,
      subtitle: '24 hour boost',
    ),
    BoostOffer(
      id: 'super_likes_10',
      title: '? 10 Super Likes',
      description: 'Stand out with 10 super likes this week',
      icon: '?',
      price: 9.99,
      isPopular: true,
      subtitle: 'Most popular',
    ),
    BoostOffer(
      id: 'spotlight_24h',
      title: '? Spotlight 24h',
      description: '5x visibility in your area for 24 hours',
      icon: '?',
      price: 4.99,
      subtitle: '24 hour spotlight',
    ),
    BoostOffer(
      id: 'incognito_week',
      title: '?? Incognito Week',
      description: 'Browse without showing you\'re online',
      icon: '??',
      price: 1.99,
      subtitle: '7 day pass',
    ),
  ];

  static final List<BoostOffer> postMatchBoosts = [
    BoostOffer(
      id: 'super_likes_5',
      title: '? 5 Super Likes',
      description: 'Get 5 super likes to use right now',
      icon: '?',
      price: 4.99,
      isPopular: true,
    ),
    BoostOffer(
      id: 'spotlight_boost',
      title: '? Spotlight Boost',
      description: 'Boost your profile visibility now',
      icon: '?',
      price: 2.99,
    ),
  ];

  static final List<BoostOffer> noSuperLikesBoosts = [
    BoostOffer(
      id: 'super_likes_10',
      title: '? 10 Super Likes',
      description: 'You\'re out! Get 10 more super likes',
      icon: '?',
      price: 9.99,
      isPopular: true,
    ),
    BoostOffer(
      id: 'super_likes_5',
      title: '? 5 Super Likes',
      description: 'Quick option: 5 super likes',
      icon: '?',
      price: 4.99,
    ),
  ];
}
