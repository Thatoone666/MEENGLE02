class FraudAlert {
  final String alertId;
  final String userId;
  final String flaggedUserId;
  final String alertType; // 'suspicious_messaging', 'fake_profile', 'location_spoofing', 'payment_fraud'
  final int riskScore; // 0-100
  final String description;
  final List<String> evidence;
  final String recommendation; // 'warn_user', 'verify_identity', 'block'
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  FraudAlert({
    required this.alertId,
    required this.userId,
    required this.flaggedUserId,
    required this.alertType,
    required this.riskScore,
    required this.description,
    required this.evidence,
    required this.recommendation,
    this.isResolved = false,
    required this.createdAt,
    this.resolvedAt,
  });

  factory FraudAlert.fromJson(Map<String, dynamic> json) {
    return FraudAlert(
      alertId: json['alertId'] ?? '',
      userId: json['userId'] ?? '',
      flaggedUserId: json['flaggedUserId'] ?? '',
      alertType: json['alertType'] ?? 'suspicious_messaging',
      riskScore: json['riskScore'] ?? 0,
      description: json['description'] ?? '',
      evidence: List<String>.from(json['evidence'] ?? []),
      recommendation: json['recommendation'] ?? 'warn_user',
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'userId': userId,
      'flaggedUserId': flaggedUserId,
      'alertType': alertType,
      'riskScore': riskScore,
      'description': description,
      'evidence': evidence,
      'recommendation': recommendation,
      'isResolved': isResolved,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  String getRiskBadge() {
    if (riskScore >= 80) return '🚨 Critical';
    if (riskScore >= 60) return '⚠️ High';
    if (riskScore >= 40) return '⚡ Medium';
    return '✓ Low';
  }

  String getAlertIcon() {
    switch (alertType) {
      case 'fake_profile':
        return '👤';
      case 'location_spoofing':
        return '📍';
      case 'payment_fraud':
        return '💳';
      case 'suspicious_messaging':
      default:
        return '💬';
    }
  }
}

class BehaviorPattern {
  final String userId;
  final int messagesPerDay;
  final double averageResponseTime; // minutes
  final bool frequentLocationChanges;
  final int requestsForMoney;
  final int suspiciousLinkShares;
  final bool photoConsistency; // Changes frequently
  final DateTime analyzedAt;

  BehaviorPattern({
    required this.userId,
    required this.messagesPerDay,
    required this.averageResponseTime,
    required this.frequentLocationChanges,
    required this.requestsForMoney,
    required this.suspiciousLinkShares,
    required this.photoConsistency,
    required this.analyzedAt,
  });
}
