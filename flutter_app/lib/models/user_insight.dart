class UserInsight {
  final String userId;
  final DateTime period; // Week or month
  final int matchesReceived;
  final int matchesSwiped;
  final int conversationsStarted;
  final int messagesReceived;
  final int messagesSent;
  final double responseRate; // % of messages they replied to
  final int datesScheduled;
  final List<String> topInterestMatches;
  final String mostEngagedProfile; // profile bio/interest type
  final List<String> photoPerformance; // Which photos got most likes
  final double estimatedCompatibility; // Average compatibility with matches
  final DateTime generatedAt;

  UserInsight({
    required this.userId,
    required this.period,
    required this.matchesReceived,
    required this.matchesSwiped,
    required this.conversationsStarted,
    required this.messagesReceived,
    required this.messagesSent,
    required this.responseRate,
    required this.datesScheduled,
    required this.topInterestMatches,
    required this.mostEngagedProfile,
    required this.photoPerformance,
    required this.estimatedCompatibility,
    required this.generatedAt,
  });

  factory UserInsight.fromJson(Map<String, dynamic> json) {
    return UserInsight(
      userId: json['userId'] ?? '',
      period: DateTime.parse(json['period'] ?? DateTime.now().toString()),
      matchesReceived: json['matchesReceived'] ?? 0,
      matchesSwiped: json['matchesSwiped'] ?? 0,
      conversationsStarted: json['conversationsStarted'] ?? 0,
      messagesReceived: json['messagesReceived'] ?? 0,
      messagesSent: json['messagesSent'] ?? 0,
      responseRate: (json['responseRate'] ?? 0).toDouble(),
      datesScheduled: json['datesScheduled'] ?? 0,
      topInterestMatches: List<String>.from(json['topInterestMatches'] ?? []),
      mostEngagedProfile: json['mostEngagedProfile'] ?? '',
      photoPerformance: List<String>.from(json['photoPerformance'] ?? []),
      estimatedCompatibility: (json['estimatedCompatibility'] ?? 0).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'period': period.toIso8601String(),
      'matchesReceived': matchesReceived,
      'matchesSwiped': matchesSwiped,
      'conversationsStarted': conversationsStarted,
      'messagesReceived': messagesReceived,
      'messagesSent': messagesSent,
      'responseRate': responseRate,
      'datesScheduled': datesScheduled,
      'topInterestMatches': topInterestMatches,
      'mostEngagedProfile': mostEngagedProfile,
      'photoPerformance': photoPerformance,
      'estimatedCompatibility': estimatedCompatibility,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  double get conversionRate =>
      matchesReceived > 0 ? (conversationsStarted / matchesReceived) * 100 : 0;

  String get engagementLevel {
    final avgMessagesPerConv =
        conversationsStarted > 0 ? messagesSent / conversationsStarted : 0;
    if (avgMessagesPerConv > 10) return '🔥 Very High';
    if (avgMessagesPerConv > 5) return '💚 High';
    if (avgMessagesPerConv > 2) return '👍 Moderate';
    return '📊 Low';
  }
}

class ProfilePerformanceMetric {
  final String metric; // 'photo', 'bio', 'interest_tag'
  final String value;
  final int impressions;
  final int likes;
  final int interactions;
  final double engagementRate; // likes / impressions

  ProfilePerformanceMetric({
    required this.metric,
    required this.value,
    required this.impressions,
    required this.likes,
    required this.interactions,
    required this.engagementRate,
  });
}
