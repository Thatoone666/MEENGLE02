import 'package:equatable/equatable.dart';

/// Spotlight boost tier
enum SpotlightTier {
  bronze, // Free boost (1x per month)
  silver, // 2x more visibility
  gold, // 5x more visibility
  platinum, // 10x more visibility + priority messaging
}

extension SpotlightTierExtension on SpotlightTier {
  String get label {
    switch (this) {
      case SpotlightTier.bronze:
        return 'Bronze';
      case SpotlightTier.silver:
        return 'Silver';
      case SpotlightTier.gold:
        return 'Gold';
      case SpotlightTier.platinum:
        return 'Platinum';
    }
  }

  String get emoji {
    switch (this) {
      case SpotlightTier.bronze:
        return '🥉';
      case SpotlightTier.silver:
        return '🥈';
      case SpotlightTier.gold:
        return '🥇';
      case SpotlightTier.platinum:
        return '💎';
    }
  }

  int get visibilityMultiplier {
    switch (this) {
      case SpotlightTier.bronze:
        return 1;
      case SpotlightTier.silver:
        return 2;
      case SpotlightTier.gold:
        return 5;
      case SpotlightTier.platinum:
        return 10;
    }
  }

  int get costInTokens {
    switch (this) {
      case SpotlightTier.bronze:
        return 0; // Free
      case SpotlightTier.silver:
        return 99;
      case SpotlightTier.gold:
        return 299;
      case SpotlightTier.platinum:
        return 799;
    }
  }

  int get durationHours {
    switch (this) {
      case SpotlightTier.bronze:
        return 24;
      case SpotlightTier.silver:
        return 24;
      case SpotlightTier.gold:
        return 72;
      case SpotlightTier.platinum:
        return 168; // 7 days
    }
  }
}

/// Represents a Meengle Spotlight - merit-based visibility boost
class MeengleSpotlight extends Equatable {
  final String id;
  final String userId;
  final SpotlightTier tier;
  final DateTime startedAt;
  final DateTime expiresAt;
  final int impressionCount; // How many profiles viewed this user
  final int likeCount; // How many likes received during spotlight
  final int superLikeCount; // How many super likes received
  final bool isActive;

  const MeengleSpotlight({
    required this.id,
    required this.userId,
    required this.tier,
    required this.startedAt,
    required this.expiresAt,
    this.impressionCount = 0,
    this.likeCount = 0,
    this.superLikeCount = 0,
    required this.isActive,
  });

  /// Time remaining in seconds
  int get secondsRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Time remaining formatted
  String get timeRemainingFormatted {
    final remaining = secondsRemaining;
    if (remaining == 0) return 'Expired';
    
    final hours = remaining ~/ 3600;
    final days = hours ~/ 24;
    final hoursLeft = hours % 24;
    
    if (days > 0) {
      return '${days}d ${hoursLeft}h';
    }
    return '${hoursLeft}h';
  }

  /// Engagement rate during spotlight
  double get engagementRate {
    if (impressionCount == 0) return 0;
    return ((likeCount + superLikeCount) / impressionCount) * 100;
  }

  MeengleSpotlight copyWith({
    String? id,
    String? userId,
    SpotlightTier? tier,
    DateTime? startedAt,
    DateTime? expiresAt,
    int? impressionCount,
    int? likeCount,
    int? superLikeCount,
    bool? isActive,
  }) {
    return MeengleSpotlight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      impressionCount: impressionCount ?? this.impressionCount,
      likeCount: likeCount ?? this.likeCount,
      superLikeCount: superLikeCount ?? this.superLikeCount,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.toString().split('.').last,
      'startedAt': startedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'impressionCount': impressionCount,
      'likeCount': likeCount,
      'superLikeCount': superLikeCount,
      'isActive': isActive,
    };
  }

  factory MeengleSpotlight.fromJson(Map<String, dynamic> json) {
    return MeengleSpotlight(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: SpotlightTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      impressionCount: json['impressionCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      superLikeCount: json['superLikeCount'] as int? ?? 0,
      isActive: json['isActive'] as bool,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tier,
        startedAt,
        expiresAt,
        impressionCount,
        likeCount,
        superLikeCount,
        isActive,
      ];
}

/// Spotlight purchase history
class SpotlightPurchase extends Equatable {
  final String id;
  final String userId;
  final SpotlightTier tier;
  final int costInTokens;
  final DateTime purchasedAt;
  final String? paymentMethodId;

  const SpotlightPurchase({
    required this.id,
    required this.userId,
    required this.tier,
    required this.costInTokens,
    required this.purchasedAt,
    this.paymentMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.toString().split('.').last,
      'costInTokens': costInTokens,
      'purchasedAt': purchasedAt.toIso8601String(),
      'paymentMethodId': paymentMethodId,
    };
  }

  factory SpotlightPurchase.fromJson(Map<String, dynamic> json) {
    return SpotlightPurchase(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: SpotlightTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
      ),
      costInTokens: json['costInTokens'] as int,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      paymentMethodId: json['paymentMethodId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tier,
        costInTokens,
        purchasedAt,
        paymentMethodId,
      ];
}
