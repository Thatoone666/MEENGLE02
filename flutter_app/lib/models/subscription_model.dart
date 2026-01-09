
enum SubscriptionTier {
  free,
  premium,
  vip;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.vip:
        return 'VIP';
    }
  }

  double get priceInRand {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.premium:
        return 99.99;
      case SubscriptionTier.vip:
        return 199.99;
    }
  }

  Map<String, dynamic> get features {
    switch (this) {
      case SubscriptionTier.free:
        return {
          'swipes_per_day': 10,
          'super_likes': 1,
          'rewinds': false,
          'hide_ads': false,
          'see_likes': false,
        };
      case SubscriptionTier.premium:
        return {
          'swipes_per_day': 100,
          'super_likes': 5,
          'rewinds': true,
          'hide_ads': true,
          'see_likes': true,
        };
      case SubscriptionTier.vip:
        return {
          'swipes_per_day': double.infinity,
          'super_likes': 10,
          'rewinds': true,
          'hide_ads': true,
          'see_likes': true,
          'priority_matches': true,
          'exclusive_events': true,
        };
    }
  }
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentMethod;
  final double amount;
  final Map<String, dynamic> metadata;

  Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentMethod,
    required this.amount,
    this.metadata = const {},
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
      paymentMethod: json['paymentMethod'],
      amount: (json['amount'] as num).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'tier': tier.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isActive': isActive,
        'paymentMethod': paymentMethod,
        'amount': amount,
        'metadata': metadata,
      };

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isExpiringSoon => endDate.difference(DateTime.now()).inDays <= 7;
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
}
