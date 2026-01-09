class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji or icon path
  final int points;
  final String category; // 'engagement', 'safety', 'social', 'milestone'
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String? progressText; // "3/5 completed"
  final double progressPercent; // 0.0 - 1.0

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progressText,
    this.progressPercent = 0.0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      points: json['points'] ?? 0,
      category: json['category'] ?? 'engagement',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      progressText: json['progressText'],
      progressPercent: (json['progressPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progressText': progressText,
      'progressPercent': progressPercent,
    };
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final String rewardType; // 'premium_feature', 'badge', 'boost'
  final String? rewardValue; // Details of what's rewarded
  final bool isRedeemed;
  final DateTime? redeemedAt;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.rewardType,
    this.rewardValue,
    this.isRedeemed = false,
    this.redeemedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pointsRequired: json['pointsRequired'] ?? 0,
      rewardType: json['rewardType'] ?? 'badge',
      rewardValue: json['rewardValue'],
      isRedeemed: json['isRedeemed'] ?? false,
      redeemedAt: json['redeemedAt'] != null ? DateTime.parse(json['redeemedAt']) : null,
    );
  }
}

class UserAchievements {
  final String userId;
  final int totalPoints;
  final int level; // 1-10
  final List<Achievement> achievements;
  final List<Reward> availableRewards;
  final int pointsToNextLevel;

  UserAchievements({
    required this.userId,
    required this.totalPoints,
    required this.level,
    required this.achievements,
    required this.availableRewards,
    required this.pointsToNextLevel,
  });

  factory UserAchievements.fromJson(Map<String, dynamic> json) {
    return UserAchievements(
      userId: json['userId'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      achievements: (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      availableRewards: (json['availableRewards'] as List?)
              ?.map((r) => Reward.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      pointsToNextLevel: json['pointsToNextLevel'] ?? 100,
    );
  }

  int get unlockedAchievementCount => achievements.where((a) => a.isUnlocked).length;
  double get levelProgress => 1.0 - (pointsToNextLevel / 100.0);
}

// Pre-defined achievements
class AchievementDefinitions {
  static final allAchievements = [
    Achievement(
      id: 'first_match',
      title: 'First Connection',
      description: 'Make your first match',
      icon: '💚',
      points: 10,
      category: 'milestone',
    ),
    Achievement(
      id: 'first_message',
      title: 'Conversation Starter',
      description: 'Send your first message',
      icon: '💬',
      points: 5,
      category: 'engagement',
    ),
    Achievement(
      id: 'verified_profile',
      title: 'Verified Member',
      description: 'Complete full profile verification',
      icon: '✅',
      points: 25,
      category: 'safety',
    ),
    Achievement(
      id: 'video_intro',
      title: 'Video Star',
      description: 'Add a video intro to your profile',
      icon: '🎬',
      points: 15,
      category: 'engagement',
    ),
    Achievement(
      id: '10_conversations',
      title: 'Social Butterfly',
      description: 'Start 10 conversations',
      icon: '🦋',
      points: 30,
      category: 'engagement',
    ),
    Achievement(
      id: 'first_date',
      title: 'Real World Connection',
      description: 'Schedule your first date',
      icon: '🎉',
      points: 50,
      category: 'milestone',
    ),
    Achievement(
      id: 'perfect_response_rate',
      title: 'Always There',
      description: 'Achieve 95%+ response rate for a week',
      icon: '⚡',
      points: 20,
      category: 'engagement',
    ),
    Achievement(
      id: 'referral_bonus',
      title: 'Cupid',
      description: 'Refer 3 friends who join',
      icon: '💘',
      points: 40,
      category: 'social',
    ),
    Achievement(
      id: 'safety_first',
      title: 'Safety Champion',
      description: 'Complete safety course',
      icon: '🛡️',
      points: 20,
      category: 'safety',
    ),
    Achievement(
      id: 'week_streak',
      title: 'Committed',
      description: 'Use app every day for a week',
      icon: '🔥',
      points: 15,
      category: 'engagement',
    ),
  ];

  static Achievement getAchievement(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return Achievement(
        id: id,
        title: 'Unknown',
        description: 'Achievement not found',
        icon: '❓',
        points: 0,
        category: 'milestone',
      );
    }
  }
}
