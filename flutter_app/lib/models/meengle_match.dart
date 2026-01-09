import 'package:equatable/equatable.dart';

/// Represents a match candidate with compatibility information
class MeengleMatch extends Equatable {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final int distance;
  final int matchScore;
  final List<String> matchReasons;
  final bool isVerified;

  const MeengleMatch({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.distance,
    required this.matchScore,
    required this.matchReasons,
    this.isVerified = false,
  });

  MeengleMatch copyWith({
    String? id,
    String? name,
    int? age,
    String? bio,
    List<String>? photos,
    int? distance,
    int? matchScore,
    List<String>? matchReasons,
    bool? isVerified,
  }) {
    return MeengleMatch(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      distance: distance ?? this.distance,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'photos': photos,
      'distance': distance,
      'matchScore': matchScore,
      'matchReasons': matchReasons,
      'isVerified': isVerified,
    };
  }

  /// Create from JSON
  factory MeengleMatch.fromJson(Map<String, dynamic> json) {
    return MeengleMatch(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      bio: json['bio'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      distance: json['distance'] as int,
      matchScore: json['matchScore'] as int,
      matchReasons: List<String>.from(json['matchReasons'] as List? ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, age, bio, photos, distance, matchScore, matchReasons, isVerified];
}
