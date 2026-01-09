import 'package:geolocator/geolocator.dart';
import '../models/compatibility_score.dart';
import '../utils/logger.dart';

class CompatibilityService {
  static final _logger = Logger();
  static const double _maxDistance = 50.0; // km

  /// Calculate compatibility score between current user and a match
  Future<CompatibilityScore?> calculateCompatibility({
    required String currentUserId,
    required String matchId,
    required Map<String, dynamic> currentUserData,
    required Map<String, dynamic> matchData,
  }) async {
    try {
      // Get interests overlap
      final interestScore = _calculateInterestAlignment(
        currentUserData['interests'] ?? [],
        matchData['interests'] ?? [],
      );

      // Get location proximity
      final proximityScore = await _calculateLocationProximity(
        currentUserData['location'],
        matchData['location'],
      );

      // Get communication compatibility (from message history if available)
      final commScore = await _calculateCommunicationStyle(
        currentUserId,
        matchId,
      );

      // Get value alignment (long-term goals, lifestyle)
      final valueScore = _calculateValueAlignment(
        currentUserData,
        matchData,
      );

      // Calculate weighted total
      final totalScore = ((interestScore * 0.3 +
              proximityScore * 0.2 +
              commScore * 0.25 +
              valueScore * 0.25)
          .clamp(0, 100))
          .toDouble();

      // Generate match reasons
      final reasons = _generateMatchReasons(
        interestScore,
        proximityScore,
        commScore,
        valueScore,
        currentUserData,
        matchData,
      );

      final score = CompatibilityScore(
        matchId: matchId,
        totalScore: totalScore,
        interestAlignment: interestScore,
        locationProximity: proximityScore,
        communicationStyle: commScore,
        valueAlignment: valueScore,
        topMatchReasons: reasons,
        calculatedAt: DateTime.now(),
      );

      // Cache the score
      await _cacheScore(score);

      return score;
    } catch (e) {
      _logger.error('Error calculating compatibility', e);
      return null;
    }
  }

  /// Calculate interest alignment (0-100)
  double _calculateInterestAlignment(List<dynamic> userInterests, List<dynamic> matchInterests) {
    if (userInterests.isEmpty || matchInterests.isEmpty) return 50;

    final userSet = userInterests.map((e) => e.toString().toLowerCase()).toSet();
    final matchSet = matchInterests.map((e) => e.toString().toLowerCase()).toSet();

    final intersection = userSet.intersection(matchSet).length;
    final union = userSet.union(matchSet).length;

    if (union == 0) return 0;
    final jaccardIndex = intersection / union;
    return (jaccardIndex * 100).clamp(0, 100).toDouble();
  }

  /// Calculate location proximity score (0-100, closer = higher)
  Future<double> _calculateLocationProximity(
    dynamic userLocation,
    dynamic matchLocation,
  ) async {
    try {
      if (userLocation == null || matchLocation == null) return 50;

      // Parse locations (format: "lat,lng" or similar)
      final userCoords = _parseLocation(userLocation);
      final matchCoords = _parseLocation(matchLocation);

      if (userCoords == null || matchCoords == null) return 50;

      final distance = Geolocator.distanceBetween(
        userCoords['lat']!.toDouble(),
        userCoords['lng']!.toDouble(),
        matchCoords['lat']!.toDouble(),
        matchCoords['lng']!.toDouble(),
      );

      final distanceKm = distance / 1000;

      // Score: 100 if same location, decreases with distance
      final score = 100 - ((distanceKm / _maxDistance) * 100);
      return score.clamp(0, 100).toDouble();
    } catch (e) {
      _logger.debug('Location proximity calculation error', e);
      return 50; // Default neutral score
    }
  }

  /// Calculate communication style compatibility
  Future<double> _calculateCommunicationStyle(String userId, String matchId) async {
    try {
      // This could be enhanced with actual message history analysis
      // For now, return a baseline score
      // In production, analyze: response time, message length, emoji usage, etc.
      return 70.0; // Placeholder
    } catch (e) {
      _logger.debug('Communication analysis error', e);
      return 50;
    }
  }

  /// Calculate value alignment (goals, lifestyle, commitment)
  double _calculateValueAlignment(Map<String, dynamic> userdata, Map<String, dynamic> matchData) {
    double score = 50.0;

    // Check relationship goal alignment
    if (userdata['relationshipGoal'] == matchData['relationshipGoal']) {
      score += 15;
    }

    // Check lifestyle compatibility
    if (userdata['lifestyle'] == matchData['lifestyle']) {
      score += 10;
    }

    // Check age proximity (reasonable age gap)
    final userAge = _calculateAge(userdata['dateOfBirth']);
    final matchAge = _calculateAge(matchData['dateOfBirth']);
    if ((userAge - matchAge).abs() <= 5) {
      score += 15;
    } else if ((userAge - matchAge).abs() <= 10) {
      score += 8;
    }

    return score.clamp(0, 100).toDouble();
  }

  /// Generate human-readable match reasons
  List<String> _generateMatchReasons(
    double interests,
    double proximity,
    double communication,
    double values,
    Map<String, dynamic> userData,
    Map<String, dynamic> matchData,
  ) {
    final reasons = <String>[];

    if (interests > 60) {
      reasons.add('🎯 Share many interests');
    }
    if (proximity > 60) {
      reasons.add('📍 Close by');
    }
    if (communication > 65) {
      reasons.add('💬 Great communicators');
    }
    if (values > 70) {
      reasons.add('💭 Aligned values');
    }

    // Add specific interest matches
    final userInterests = (userData['interests'] as List?)?.cast<String>() ?? [];
    final matchInterests = (matchData['interests'] as List?)?.cast<String>() ?? [];
    final commonInterests = userInterests.toSet().intersection(matchInterests.toSet());

    if (commonInterests.isNotEmpty) {
      final firstThree = commonInterests.take(3).join(', ');
      reasons.add('❤️ Both into: $firstThree');
    }

    return reasons.take(4).toList();
  }

  /// Parse location string
  Map<String, double>? _parseLocation(dynamic location) {
    try {
      if (location is String) {
        final parts = location.split(',');
        if (parts.length >= 2) {
          return {
            'lat': double.parse(parts[0]),
            'lng': double.parse(parts[1]),
          };
        }
      } else if (location is Map) {
        return {
          'lat': (location['lat'] as num?)?.toDouble() ?? 0,
          'lng': (location['lng'] as num?)?.toDouble() ?? 0,
        };
      }
    } catch (e) {
      _logger.debug('Location parse error', e);
    }
    return null;
  }

  /// Calculate age from date of birth
  int _calculateAge(dynamic dateOfBirth) {
    try {
      if (dateOfBirth is String) {
        final date = DateTime.parse(dateOfBirth);
        final now = DateTime.now();
        return now.year - date.year - (now.month < date.month || (now.month == date.month && now.day < date.day) ? 1 : 0);
      }
    } catch (e) {
      _logger.debug('Age calculation error', e);
    }
    return 25; // Default
  }

  /// Cache score locally and on server
  Future<void> _cacheScore(CompatibilityScore score) async {
    try {
      // In production, save to local DB and sync with server
      _logger.info('Compatibility score cached', score.toJson());
    } catch (e) {
      _logger.error('Score caching error', e);
    }
  }

  /// Get cached scores for a user
  Future<List<CompatibilityScore>> getCachedScores(String userId) async {
    try {
      // Fetch from local storage or server
      return [];
    } catch (e) {
      _logger.error('Error fetching cached scores', e);
      return [];
    }
  }
}
