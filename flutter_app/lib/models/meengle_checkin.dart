import 'package:equatable/equatable.dart';

/// Enhanced CheckIn feature combining location sharing with social engagement
/// Special feature about Meengle - "Where vibes meet location"
class MeengleCheckIn extends Equatable {
  final String id;
  final String userId;
  final String locationName;
  final double latitude;
  final double longitude;
  final String vibe; // User's current vibe/mood
  final List<String> vibeEmojis; // Visual representation
  final DateTime createdAt;
  final DateTime expiresAt;
  final int minutesRemaining;
  
  // Social features
  final int nearbyUserCount;
  final bool isFlashEvent; // Special limited-time event
  final String? flashEventName;
  final DateTime? flashEventExpiresAt;
  final int vibeScore; // How popular this vibe is at location
  
  // Streak system
  final int currentStreak;
  final DateTime? lastCheckInDate;
  final bool streakActive;
  
  // User profile for display
  final String? username;
  final String? photoUrl;
  final int? age;
  final double? compatibilityScore;
  
  const MeengleCheckIn({
    required this.id,
    required this.userId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.vibe,
    this.vibeEmojis = const ['😊'],
    required this.createdAt,
    required this.expiresAt,
    this.minutesRemaining = 0,
    this.nearbyUserCount = 0,
    this.isFlashEvent = false,
    this.flashEventName,
    this.flashEventExpiresAt,
    this.vibeScore = 0,
    this.currentStreak = 0,
    this.lastCheckInDate,
    this.streakActive = false,
    this.username,
    this.photoUrl,
    this.age,
    this.compatibilityScore,
  });

  /// Check if check-in is still valid
  bool get isActive => DateTime.now().isBefore(expiresAt);

  /// Format time remaining (e.g., "2h 30m", "15m")
  String get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inMinutes;
    if (remaining <= 0) return 'Expired';
    if (remaining < 60) return '${remaining}m';
    final hours = remaining ~/ 60;
    final mins = remaining % 60;
    return '${hours}h ${mins}m';
  }

  /// Get color based on vibe
  static String getVibeColor(String vibe) {
    final vibeLower = vibe.toLowerCase();
    const colors = {
      'party': '#FF6B9D',
      'chill': '#00D9FF',
      'adventurous': '#FF9500',
      'romantic': '#FF006E',
      'casual': '#FFD60A',
      'energetic': '#FB5607',
      'intellectual': '#8338EC',
      'foodie': '#FFBE0B',
      'sporty': '#06D6A0',
      'artsy': '#D62828',
      'nature': '#06A77D',
      'nightlife': '#2A2A2A',
    };
    return colors[vibeLower] ?? '#D4AF37';
  }

  /// Get emoji for vibe
  static String getVibeEmoji(String vibe) {
    const emojis = {
      'party': '🎉',
      'chill': '😎',
      'adventurous': '🧗',
      'romantic': '💕',
      'casual': '☕',
      'energetic': '⚡',
      'intellectual': '🧠',
      'foodie': '🍽️',
      'sporty': '⚽',
      'artsy': '🎨',
      'nature': '🌿',
      'nightlife': '🌙',
    };
    return emojis[vibe.toLowerCase()] ?? '😊';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'vibe': vibe,
        'vibeEmojis': vibeEmojis,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'minutesRemaining': minutesRemaining,
        'nearbyUserCount': nearbyUserCount,
        'isFlashEvent': isFlashEvent,
        'flashEventName': flashEventName,
        'flashEventExpiresAt': flashEventExpiresAt?.toIso8601String(),
        'vibeScore': vibeScore,
        'currentStreak': currentStreak,
        'lastCheckInDate': lastCheckInDate?.toIso8601String(),
        'streakActive': streakActive,
        'username': username,
        'photoUrl': photoUrl,
        'age': age,
        'compatibilityScore': compatibilityScore,
      };

  /// Create from JSON
  factory MeengleCheckIn.fromJson(Map<String, dynamic> json) => MeengleCheckIn(
        id: json['id'] as String,
        userId: json['userId'] as String,
        locationName: json['locationName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        vibe: json['vibe'] as String? ?? 'casual',
        vibeEmojis: List<String>.from(json['vibeEmojis'] as List? ?? ['😊']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        minutesRemaining: json['minutesRemaining'] as int? ?? 0,
        nearbyUserCount: json['nearbyUserCount'] as int? ?? 0,
        isFlashEvent: json['isFlashEvent'] as bool? ?? false,
        flashEventName: json['flashEventName'] as String?,
        flashEventExpiresAt: json['flashEventExpiresAt'] != null
            ? DateTime.parse(json['flashEventExpiresAt'] as String)
            : null,
        vibeScore: json['vibeScore'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        lastCheckInDate: json['lastCheckInDate'] != null
            ? DateTime.parse(json['lastCheckInDate'] as String)
            : null,
        streakActive: json['streakActive'] as bool? ?? false,
        username: json['username'] as String?,
        photoUrl: json['photoUrl'] as String?,
        age: json['age'] as int?,
        compatibilityScore:
            (json['compatibilityScore'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        locationName,
        latitude,
        longitude,
        vibe,
        vibeEmojis,
        createdAt,
        expiresAt,
        nearbyUserCount,
        isFlashEvent,
        flashEventName,
        vibeScore,
        currentStreak,
        streakActive,
        username,
        photoUrl,
        age,
        compatibilityScore,
      ];

  MeengleCheckIn copyWith({
    String? id,
    String? userId,
    String? locationName,
    double? latitude,
    double? longitude,
    String? vibe,
    List<String>? vibeEmojis,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? minutesRemaining,
    int? nearbyUserCount,
    bool? isFlashEvent,
    String? flashEventName,
    DateTime? flashEventExpiresAt,
    int? vibeScore,
    int? currentStreak,
    DateTime? lastCheckInDate,
    bool? streakActive,
    String? username,
    String? photoUrl,
    int? age,
    double? compatibilityScore,
  }) =>
      MeengleCheckIn(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        locationName: locationName ?? this.locationName,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        vibe: vibe ?? this.vibe,
        vibeEmojis: vibeEmojis ?? this.vibeEmojis,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        minutesRemaining: minutesRemaining ?? this.minutesRemaining,
        nearbyUserCount: nearbyUserCount ?? this.nearbyUserCount,
        isFlashEvent: isFlashEvent ?? this.isFlashEvent,
        flashEventName: flashEventName ?? this.flashEventName,
        flashEventExpiresAt: flashEventExpiresAt ?? this.flashEventExpiresAt,
        vibeScore: vibeScore ?? this.vibeScore,
        currentStreak: currentStreak ?? this.currentStreak,
        lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
        streakActive: streakActive ?? this.streakActive,
        username: username ?? this.username,
        photoUrl: photoUrl ?? this.photoUrl,
        age: age ?? this.age,
        compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      );
}

/// Badge for check-in streaks and achievements
enum CheckInBadgeType {
  streak3('🔥 3 Day Streak', '3 days in a row!'),
  streak7('🔥 Week Warrior', '7 days checked in!'),
  streak30('🔥 Obsessed!', '30 day streak!'),
  socialButterfly('🦋 Social Butterfly', '50+ connections'),
  vibeVendor('✨ Vibe Vendor', '100+ vibes shared'),
  locationExplorer('🗺️ Explorer', '25 locations'),
  eventParticipant('🎉 Event Star', '10 flash events'),
  compatibilityMatches('💝 Connector', '20+ compatible matches');

  final String title;
  final String description;

  const CheckInBadgeType(this.title, this.description);
}

/// User streak information
class CheckInStreak extends Equatable {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCheckInDate;
  final List<CheckInBadgeType> badges;
  final int totalCheckIns;
  final int uniqueLocations;
  final double totalHoursSharing;

  const CheckInStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCheckInDate,
    this.badges = const [],
    required this.totalCheckIns,
    required this.uniqueLocations,
    this.totalHoursSharing = 0,
  });

  /// Check if user should earn a new badge
  List<CheckInBadgeType> getEarnedBadges() {
    final earned = <CheckInBadgeType>[];

    if (currentStreak >= 3) earned.add(CheckInBadgeType.streak3);
    if (currentStreak >= 7) earned.add(CheckInBadgeType.streak7);
    if (currentStreak >= 30) earned.add(CheckInBadgeType.streak30);
    if (totalCheckIns >= 50) earned.add(CheckInBadgeType.vibeVendor);
    if (uniqueLocations >= 25) earned.add(CheckInBadgeType.locationExplorer);

    return earned;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCheckInDate': lastCheckInDate.toIso8601String(),
        'badges': badges.map((b) => b.toString()).toList(),
        'totalCheckIns': totalCheckIns,
        'uniqueLocations': uniqueLocations,
        'totalHoursSharing': totalHoursSharing,
      };

  factory CheckInStreak.fromJson(Map<String, dynamic> json) => CheckInStreak(
        userId: json['userId'] as String,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastCheckInDate:
            DateTime.parse(json['lastCheckInDate'] as String),
        badges: [],
        totalCheckIns: json['totalCheckIns'] as int? ?? 0,
        uniqueLocations: json['uniqueLocations'] as int? ?? 0,
        totalHoursSharing:
            (json['totalHoursSharing'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [
        userId,
        currentStreak,
        longestStreak,
        lastCheckInDate,
        badges,
        totalCheckIns,
        uniqueLocations,
        totalHoursSharing,
      ];
}

/// Flash event at location (limited time)
class FlashEvent extends Equatable {
  final String id;
  final String locationName;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String emoji;
  final DateTime startsAt;
  final DateTime expiresAt;
  final int participantCount;
  final List<String> topVibes;
  final int minutesRemaining;

  const FlashEvent({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.emoji,
    required this.startsAt,
    required this.expiresAt,
    this.participantCount = 0,
    this.topVibes = const [],
    this.minutesRemaining = 0,
  });

  bool get isActive =>
      DateTime.now().isAfter(startsAt) && DateTime.now().isBefore(expiresAt);

  String get timeRemaining {
    final remaining =
        expiresAt.difference(DateTime.now()).inMinutes;
    if (remaining <= 0) return 'Ended';
    if (remaining < 60) return '${remaining}m left';
    final hours = remaining ~/ 60;
    return '${hours}h left';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'description': description,
        'emoji': emoji,
        'startsAt': startsAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'participantCount': participantCount,
        'topVibes': topVibes,
      };

  factory FlashEvent.fromJson(Map<String, dynamic> json) => FlashEvent(
        id: json['id'] as String,
        locationName: json['locationName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        title: json['title'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String? ?? '✨',
        startsAt: DateTime.parse(json['startsAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        participantCount: json['participantCount'] as int? ?? 0,
        topVibes: List<String>.from(json['topVibes'] as List? ?? []),
      );

  @override
  List<Object?> get props => [
        id,
        locationName,
        latitude,
        longitude,
        title,
        description,
        emoji,
        startsAt,
        expiresAt,
        participantCount,
        topVibes,
      ];
}
