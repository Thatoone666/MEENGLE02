import 'package:equatable/equatable.dart';

/// Represents Meengle Roam - travel + adventure matching + local guides
class MeengleRoam extends Equatable {
  final String id;
  final String userId;
  final bool isActive; // Whether in travel mode
  final String currentCity; // City code or name
  final double latitude;
  final double longitude;
  final DateTime activatedAt;
  final DateTime? deactivatedAt;
  final List<String> travelInterests; // e.g., 'hiking', 'nightlife', 'museums'
  final List<String> lookingFor; // e.g., 'adventure partner', 'local guide', 'date'

  const MeengleRoam({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.currentCity,
    required this.latitude,
    required this.longitude,
    required this.activatedAt,
    this.deactivatedAt,
    required this.travelInterests,
    required this.lookingFor,
  });

  /// Duration of current roam in seconds
  int get durationSeconds {
    final end = deactivatedAt ?? DateTime.now();
    return end.difference(activatedAt).inSeconds;
  }

  /// Duration formatted
  String get durationFormatted {
    final seconds = durationSeconds;
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  MeengleRoam copyWith({
    String? id,
    String? userId,
    bool? isActive,
    String? currentCity,
    double? latitude,
    double? longitude,
    DateTime? activatedAt,
    DateTime? deactivatedAt,
    List<String>? travelInterests,
    List<String>? lookingFor,
  }) {
    return MeengleRoam(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      currentCity: currentCity ?? this.currentCity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      activatedAt: activatedAt ?? this.activatedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      travelInterests: travelInterests ?? this.travelInterests,
      lookingFor: lookingFor ?? this.lookingFor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'isActive': isActive,
      'currentCity': currentCity,
      'latitude': latitude,
      'longitude': longitude,
      'activatedAt': activatedAt.toIso8601String(),
      'deactivatedAt': deactivatedAt?.toIso8601String(),
      'travelInterests': travelInterests,
      'lookingFor': lookingFor,
    };
  }

  factory MeengleRoam.fromJson(Map<String, dynamic> json) {
    return MeengleRoam(
      id: json['id'] as String,
      userId: json['userId'] as String,
      isActive: json['isActive'] as bool,
      currentCity: json['currentCity'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      activatedAt: DateTime.parse(json['activatedAt'] as String),
      deactivatedAt: json['deactivatedAt'] != null
          ? DateTime.parse(json['deactivatedAt'] as String)
          : null,
      travelInterests:
          List<String>.from(json['travelInterests'] as List? ?? []),
      lookingFor: List<String>.from(json['lookingFor'] as List? ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        isActive,
        currentCity,
        latitude,
        longitude,
        activatedAt,
        deactivatedAt,
        travelInterests,
        lookingFor,
      ];
}

/// Local guide or event recommendation
class LocalGuide extends Equatable {
  final String id;
  final String name;
  final String bio;
  final String profileImageUrl;
  final String city;
  final double rating; // 1-5 stars
  final int reviewCount;
  final List<String> specialties; // e.g., 'hiking', 'nightlife', 'food tours'
  final int yearsLocal;
  final bool isVerified;
  final String? contactInfo;

  const LocalGuide({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileImageUrl,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.specialties,
    required this.yearsLocal,
    required this.isVerified,
    this.contactInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'city': city,
      'rating': rating,
      'reviewCount': reviewCount,
      'specialties': specialties,
      'yearsLocal': yearsLocal,
      'isVerified': isVerified,
      'contactInfo': contactInfo,
    };
  }

  factory LocalGuide.fromJson(Map<String, dynamic> json) {
    return LocalGuide(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      city: json['city'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      specialties: List<String>.from(json['specialties'] as List),
      yearsLocal: json['yearsLocal'] as int,
      isVerified: json['isVerified'] as bool,
      contactInfo: json['contactInfo'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        profileImageUrl,
        city,
        rating,
        reviewCount,
        specialties,
        yearsLocal,
        isVerified,
        contactInfo,
      ];
}

/// Local event or activity
class LocalEvent extends Equatable {
  final String id;
  final String name;
  final String description;
  final String city;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String category; // 'party', 'art', 'sports', 'food', 'outdoor', etc.
  final int attendeeCount;
  final int capacity;
  final String imageUrl;
  final double? rating;

  const LocalEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.attendeeCount,
    required this.capacity,
    required this.imageUrl,
    this.rating,
  });

  /// Is event happening now
  bool get isHappening {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Is event coming up (within 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final nextDay = now.add(Duration(days: 1));
    return startTime.isAfter(now) && startTime.isBefore(nextDay);
  }

  /// How full is the event
  double get fillPercentage => (attendeeCount / capacity) * 100;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category,
      'attendeeCount': attendeeCount,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  factory LocalEvent.fromJson(Map<String, dynamic> json) {
    return LocalEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      category: json['category'] as String,
      attendeeCount: json['attendeeCount'] as int,
      capacity: json['capacity'] as int,
      imageUrl: json['imageUrl'] as String,
      rating: json['rating'] as double?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        city,
        latitude,
        longitude,
        startTime,
        endTime,
        category,
        attendeeCount,
        capacity,
        imageUrl,
        rating,
      ];
}
