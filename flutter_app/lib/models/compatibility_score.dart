class CompatibilityScore {
  final String matchId;
  final double totalScore; // 0-100
  final double interestAlignment; // How many interests match
  final double locationProximity; // Based on distance
  final double communicationStyle; // Message frequency compatibility
  final double valueAlignment; // Long-term goals, lifestyle
  final List<String> topMatchReasons;
  final DateTime calculatedAt;
  final bool isFresh; // Recalculated recently

  CompatibilityScore({
    required this.matchId,
    required this.totalScore,
    required this.interestAlignment,
    required this.locationProximity,
    required this.communicationStyle,
    required this.valueAlignment,
    required this.topMatchReasons,
    required this.calculatedAt,
    this.isFresh = true,
  });

  factory CompatibilityScore.fromJson(Map<String, dynamic> json) {
    return CompatibilityScore(
      matchId: json['matchId'] ?? '',
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      interestAlignment: (json['interestAlignment'] ?? 0).toDouble(),
      locationProximity: (json['locationProximity'] ?? 0).toDouble(),
      communicationStyle: (json['communicationStyle'] ?? 0).toDouble(),
      valueAlignment: (json['valueAlignment'] ?? 0).toDouble(),
      topMatchReasons: List<String>.from(json['topMatchReasons'] ?? []),
      calculatedAt: DateTime.parse(json['calculatedAt'] ?? DateTime.now().toString()),
      isFresh: json['isFresh'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'totalScore': totalScore,
      'interestAlignment': interestAlignment,
      'locationProximity': locationProximity,
      'communicationStyle': communicationStyle,
      'valueAlignment': valueAlignment,
      'topMatchReasons': topMatchReasons,
      'calculatedAt': calculatedAt.toIso8601String(),
      'isFresh': isFresh,
    };
  }

  String getScoreCategory() {
    if (totalScore >= 80) return 'Excellent Match';
    if (totalScore >= 60) return 'Great Match';
    if (totalScore >= 40) return 'Good Match';
    return 'Interesting Match';
  }

  String getScoreEmoji() {
    if (totalScore >= 80) return '🔥';
    if (totalScore >= 60) return '💚';
    if (totalScore >= 40) return '👍';
    return '👀';
  }
}
