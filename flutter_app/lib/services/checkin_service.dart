import 'dart:convert';
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/models/meengle_checkin.dart';

/// Enhanced CheckIn service with streaks, badges, flash events, and social features
/// This is THE special feature that makes Meengle unique - "Where vibes meet location"
class CheckInService {
  static final Map<String, MeengleCheckIn> _checkIns = {};
  static final Map<String, CheckInStreak> _streaks = {};
  static final Map<String, FlashEvent> _flashEvents = {};
  static final List<String> _vibes = [
    'party',
    'chill',
    'adventurous',
    'romantic',
    'casual',
    'energetic',
    'intellectual',
    'foodie',
    'sporty',
    'artsy',
    'nature',
    'nightlife',
  ];

  /// Seed data for flash events
  static final _seedFlashEvents = [
    FlashEvent(
      id: 'flash_001',
      locationName: 'The Local Pub',
      latitude: 37.4310,
      longitude: -122.0840,
      title: '🍺 Happy Hour',
      description: '50% off drinks! Join the party vibes',
      emoji: '🍺',
      startsAt: DateTime.now().add(const Duration(minutes: 15)),
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      participantCount: 23,
      topVibes: ['party', 'casual', 'energetic'],
    ),
    FlashEvent(
      id: 'flash_002',
      locationName: 'Downtown Coffee',
      latitude: 37.4270,
      longitude: -122.0850,
      title: '☕ WiFi & Chill',
      description: 'Quiet space for focused work or relaxation',
      emoji: '☕',
      startsAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      participantCount: 8,
      topVibes: ['chill', 'intellectual', 'casual'],
    ),
    FlashEvent(
      id: 'flash_003',
      locationName: 'City Park',
      latitude: 37.4250,
      longitude: -122.0860,
      title: '⚽ Pickup Soccer',
      description: 'Join the game! No experience needed',
      emoji: '⚽',
      startsAt: DateTime.now().add(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      participantCount: 12,
      topVibes: ['sporty', 'energetic', 'casual'],
    ),
  ];

  /// Create a check-in with streak tracking
  static Future<Map<String, dynamic>?> checkIn(
    String locationName,
    String vibe, {
    double latitude = 37.4310,
    double longitude = -122.0840,
    String? username,
    String? photoUrl,
    int? age,
  }) async {
    try {
      final token = await ApiService.getToken();
      final url = Uri.parse('${ApiService.baseUrl}/api/checkin');
      final res = await ApiService.client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'locationName': locationName,
          'vibe': vibe,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 24));

        final checkIn = MeengleCheckIn(
          id: '${data['_id'] ?? 'temp_${now.millisecondsSinceEpoch}'}',
          userId: data['userId'] as String? ?? 'user_temp',
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          vibe: vibe,
          vibeEmojis: [MeengleCheckIn.getVibeEmoji(vibe)],
          createdAt: now,
          expiresAt: expiresAt,
          minutesRemaining: 1440,
          username: username,
          photoUrl: photoUrl,
          age: age,
        );

        _checkIns[checkIn.userId] = checkIn;
        await _updateStreak(checkIn.userId);
        _checkFlashEventsNearby(locationName);

        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all active check-ins at a location
  static Future<List<dynamic>?> getCheckIns(String locationName) async {
    try {
      final token = await ApiService.getToken();
      final url = Uri.parse('${ApiService.baseUrl}/api/checkin/$locationName');
      final res = await ApiService.client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get nearby check-ins within radius (in km)
  static Future<List<MeengleCheckIn>> getNearbyCheckIns(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) async {
    final now = DateTime.now();
    return _checkIns.values
        .where((ci) {
          if (now.isAfter(ci.expiresAt)) return false;

          final latDiff = (ci.latitude - latitude).abs();
          final lngDiff = (ci.longitude - longitude).abs();
          final distance = (latDiff + lngDiff) * 111;

          return distance <= radiusKm;
        })
        .toList();
  }

  /// Get user's current check-in
  static Future<MeengleCheckIn?> getUserCheckIn(String userId) async {
    final checkIn = _checkIns[userId];
    if (checkIn != null && DateTime.now().isBefore(checkIn.expiresAt)) {
      return checkIn;
    }
    _checkIns.remove(userId);
    return null;
  }

  /// Check out from location
  static Future<bool> checkOut() async {
    try {
      final token = await ApiService.getToken();
      final url = Uri.parse('${ApiService.baseUrl}/api/checkin');
      final res = await ApiService.client.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get user's streak information
  static Future<CheckInStreak> getUserStreak(String userId) async {
    return _streaks[userId] ??
        CheckInStreak(
          userId: userId,
          currentStreak: 0,
          longestStreak: 0,
          lastCheckInDate: DateTime.now(),
          totalCheckIns: 0,
          uniqueLocations: 0,
        );
  }

  /// Update user's streak
  static Future<void> _updateStreak(String userId) async {
    final existing = _streaks[userId];
    final now = DateTime.now();

    if (existing == null) {
      _streaks[userId] = CheckInStreak(
        userId: userId,
        currentStreak: 1,
        longestStreak: 1,
        lastCheckInDate: now,
        totalCheckIns: 1,
        uniqueLocations: 1,
      );
    } else {
      final daysSinceLastCheckIn =
          now.difference(existing.lastCheckInDate).inDays;

      int newStreak = existing.currentStreak;
      if (daysSinceLastCheckIn == 1) {
        newStreak = existing.currentStreak + 1;
      } else if (daysSinceLastCheckIn > 1) {
        newStreak = 1;
      }

      final newLongest = newStreak > existing.longestStreak
          ? newStreak
          : existing.longestStreak;

      _streaks[userId] = CheckInStreak(
        userId: userId,
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastCheckInDate: now,
        badges: existing.badges,
        totalCheckIns: existing.totalCheckIns + 1,
        uniqueLocations: existing.uniqueLocations + 1,
        totalHoursSharing: existing.totalHoursSharing + 24,
      );
    }
  }

  /// Get all available vibes
  static List<String> getAvailableVibes() => _vibes;

  /// Get vibes at location
  static Future<Map<String, int>> getVibesAtLocation(
      String locationName) async {
    final checkIns = await getCheckIns(locationName);
    final vibes = <String, int>{};

    if (checkIns != null) {
      for (final checkIn in checkIns) {
        final vibe = checkIn['vibe'] as String?;
        if (vibe != null) {
          vibes[vibe] = (vibes[vibe] ?? 0) + 1;
        }
      }
    }

    return vibes;
  }

  /// Get active flash events
  static Future<List<FlashEvent>> getActiveFlashEvents() async {
    if (_flashEvents.isEmpty) {
      for (final event in _seedFlashEvents) {
        _flashEvents[event.id] = event;
      }
    }

    final now = DateTime.now();
    return _flashEvents.values
        .where((event) => now.isBefore(event.expiresAt))
        .toList();
  }

  /// Get flash events by location
  static Future<List<FlashEvent>> getFlashEventsByLocation(
      String locationName) async {
    final events = await getActiveFlashEvents();
    return events.where((event) => event.locationName == locationName).toList();
  }

  /// Check for flash events nearby
  static void _checkFlashEventsNearby(String locationName) {
    if (_flashEvents.isEmpty) {
      for (final event in _seedFlashEvents) {
        _flashEvents[event.id] = event;
      }
    }
  }

  /// Get badges earned
  static Future<List<CheckInBadgeType>> getUserBadges(String userId) async {
    final streak = _streaks[userId];
    if (streak == null) return [];
    return streak.getEarnedBadges();
  }

  /// Get location heat map (activity density)
  static Future<Map<String, int>> getLocationHeatMap() async {
    final locations = <String, int>{};

    for (final checkIn in _checkIns.values) {
      if (DateTime.now().isBefore(checkIn.expiresAt)) {
        locations[checkIn.locationName] =
            (locations[checkIn.locationName] ?? 0) + 1;
      }
    }

    return locations;
  }

  /// Get vibe compatibility (0-100)
  static int getVibeCompatibility(String vibe1, String vibe2) {
    const compatibility = {
      'party': {'party': 100, 'energetic': 90, 'casual': 70},
      'chill': {'chill': 100, 'casual': 85, 'intellectual': 75},
      'romantic': {'romantic': 100, 'casual': 80, 'intellectual': 60},
      'casual': {'casual': 100, 'party': 70, 'chill': 85, 'romantic': 80},
      'adventurous': {
        'adventurous': 100,
        'sporty': 90,
        'energetic': 85
      },
    };

    return compatibility[vibe1]?[vibe2] ??
        compatibility[vibe2]?[vibe1] ??
        50;
  }
}
