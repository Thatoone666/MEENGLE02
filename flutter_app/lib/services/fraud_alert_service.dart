import '../models/fraud_alert.dart';
import '../utils/logger.dart';

class FraudAlertService {
  static final _logger = Logger();

  /// Analyze user behavior for fraud patterns
  Future<BehaviorPattern> analyzeBehavior(
    String userId,
    List<Map<String, dynamic>> recentMessages,
    Map<String, dynamic> locationHistory,
  ) async {
    try {
      final messagesPerDay = _calculateMessagesPerDay(recentMessages);
      final avgResponseTime = _calculateResponseTime(recentMessages);
      final locChanges = _detectFrequentLocationChanges(locationHistory);
      final moneyRequests = _countMoneyRequests(recentMessages);
      final linkShares = _countSuspiciousLinks(recentMessages);
      final photoConsistent = _checkPhotoConsistency(userId);

      return BehaviorPattern(
        userId: userId,
        messagesPerDay: messagesPerDay,
        averageResponseTime: avgResponseTime,
        frequentLocationChanges: locChanges,
        requestsForMoney: moneyRequests,
        suspiciousLinkShares: linkShares,
        photoConsistency: photoConsistent,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error analyzing behavior', e);
      rethrow;
    }
  }

  /// Generate fraud alert from behavior pattern
  Future<FraudAlert?> generateAlert(
    String alertedUserId,
    String flaggedUserId,
    BehaviorPattern pattern,
  ) async {
    try {
      int riskScore = 0;
      final evidence = <String>[];
      String alertType = 'suspicious_messaging';

      // Calculate risk score
      if (pattern.messagesPerDay > 50) {
        riskScore += 20;
        evidence.add('Unusually high message frequency (${pattern.messagesPerDay}/day)');
      }

      if (pattern.averageResponseTime < 5) {
        riskScore += 15;
        evidence.add('Bot-like instant responses');
      }

      if (pattern.frequentLocationChanges) {
        riskScore += 25;
        evidence.add('Frequent location changes - possible spoofing');
        alertType = 'location_spoofing';
      }

      if (pattern.requestsForMoney > 0) {
        riskScore += 40;
        evidence.add('${pattern.requestsForMoney} request(s) for money');
        alertType = 'payment_fraud';
      }

      if (pattern.suspiciousLinkShares > 0) {
        riskScore += 20;
        evidence.add('${pattern.suspiciousLinkShares} suspicious link(s) shared');
      }

      if (!pattern.photoConsistency) {
        riskScore += 30;
        evidence.add('Profile photos appear inconsistent/fake');
        alertType = 'fake_profile';
      }

      // Only generate alert if risk score is above threshold
      if (riskScore < 30) return null;

      final recommendation = _getRecommendation(riskScore, alertType);

      return FraudAlert(
        alertId: '${DateTime.now().millisecondsSinceEpoch}',
        userId: alertedUserId,
        flaggedUserId: flaggedUserId,
        alertType: alertType,
        riskScore: riskScore.clamp(0, 100),
        description: _generateDescription(alertType, evidence),
        evidence: evidence,
        recommendation: recommendation,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error generating fraud alert', e);
      return null;
    }
  }

  int _calculateMessagesPerDay(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return 0;

    final oldest = messages.first;
    final newest = messages.last;
    final days = newest['timestamp']?.difference(oldest['timestamp']).inDays ?? 1;

    return (messages.length / (days > 0 ? days : 1)).ceil();
  }

  double _calculateResponseTime(List<Map<String, dynamic>> messages) {
    if (messages.length < 2) return 0;

    int totalTime = 0;
    int count = 0;

    for (int i = 1; i < messages.length; i++) {
      if (messages[i]['senderId'] != messages[i - 1]['senderId']) {
        final diff = (messages[i]['timestamp']?.difference(messages[i - 1]['timestamp']).inMinutes ?? 0) as int;
        if (diff > 0) {
          totalTime += diff;
          count++;
        }
      }
    }

    return count > 0 ? totalTime / count : 0;
  }

  bool _detectFrequentLocationChanges(Map<String, dynamic> locationHistory) {
    // Check if user's location changed rapidly
    // This would require comparing timestamps and distances
    return false; // Placeholder
  }

  int _countMoneyRequests(List<Map<String, dynamic>> messages) {
    return messages
        .where((m) =>
            (m['text'] ?? '')
                .toString()
                .toLowerCase()
                .contains(RegExp(r'money|pay|transfer|venmo|bitcoin|crypto')) &&
            m['senderId'] != 'current_user')
        .length;
  }

  int _countSuspiciousLinks(List<Map<String, dynamic>> messages) {
    return messages
        .where((m) => (m['text'] ?? '').toString().contains(RegExp(r'http|bit\.ly|tinyurl')))
        .length;
  }

  bool _checkPhotoConsistency(String userId) {
    // Would analyze user's photos for consistency
    // Using computer vision: face detection, same person verification
    return true; // Placeholder
  }

  String _getRecommendation(int riskScore, String alertType) {
    if (riskScore >= 80) return 'block';
    if (riskScore >= 60) return 'verify_identity';
    return 'warn_user';
  }

  String _generateDescription(String alertType, List<String> evidence) {
    switch (alertType) {
      case 'fake_profile':
        return 'This profile may be using fake or misleading photos';
      case 'location_spoofing':
        return 'Suspicious location activity detected';
      case 'payment_fraud':
        return 'This user is requesting money or financial information';
      case 'suspicious_messaging':
      default:
        return 'Unusual messaging patterns detected';
    }
  }

  /// Get all active alerts for a user
  Future<List<FraudAlert>> getActiveAlerts(String userId) async {
    try {
      // Fetch from backend
      return [];
    } catch (e) {
      _logger.error('Error fetching alerts', e);
      return [];
    }
  }

  /// Report a user
  Future<bool> reportUser(
    String reportedById,
    String reportedUserId,
    String reason,
    String description,
  ) async {
    try {
      _logger.info('User reported', {
        'reportedBy': reportedById,
        'reportedUser': reportedUserId,
        'reason': reason,
      });
      return true;
    } catch (e) {
      _logger.error('Error reporting user', e);
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String userId, String blockedUserId) async {
    try {
      _logger.info('User blocked', {'userId': userId, 'blockedUser': blockedUserId});
      return true;
    } catch (e) {
      _logger.error('Error blocking user', e);
      return false;
    }
  }
}
