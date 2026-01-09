import 'package:equatable/equatable.dart';

/// Types of circles available
enum CircleType {
  dating,
  friends,
  networking,
  hobbies,
  local,
}

extension CircleTypeExtension on CircleType {
  String get label {
    switch (this) {
      case CircleType.dating:
        return 'Dating';
      case CircleType.friends:
        return 'Friends';
      case CircleType.networking:
        return 'Networking';
      case CircleType.hobbies:
        return 'Hobbies';
      case CircleType.local:
        return 'Local';
    }
  }

  String get emoji {
    switch (this) {
      case CircleType.dating:
        return '💑';
      case CircleType.friends:
        return '👯';
      case CircleType.networking:
        return '💼';
      case CircleType.hobbies:
        return '🎨';
      case CircleType.local:
        return '📍';
    }
  }
}

/// Represents a Meengle Circle - interest-based communities
class MeengleCircle extends Equatable {
  final String id;
  final String name;
  final String description;
  final CircleType type;
  final String imageUrl;
  final List<String> tags; // Interest tags
  final int memberCount;
  final int postsCount;
  final DateTime createdAt;
  final bool isOfficial; // Whether created by Meengle team
  final bool isMember; // Whether current user is a member
  final String? createdByUserId;

  const MeengleCircle({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.tags,
    required this.memberCount,
    required this.postsCount,
    required this.createdAt,
    this.isOfficial = false,
    this.isMember = false,
    this.createdByUserId,
  });

  MeengleCircle copyWith({
    String? id,
    String? name,
    String? description,
    CircleType? type,
    String? imageUrl,
    List<String>? tags,
    int? memberCount,
    int? postsCount,
    DateTime? createdAt,
    bool? isOfficial,
    bool? isMember,
    String? createdByUserId,
  }) {
    return MeengleCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      memberCount: memberCount ?? this.memberCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      isOfficial: isOfficial ?? this.isOfficial,
      isMember: isMember ?? this.isMember,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'tags': tags,
      'memberCount': memberCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'isOfficial': isOfficial,
      'isMember': isMember,
      'createdByUserId': createdByUserId,
    };
  }

  factory MeengleCircle.fromJson(Map<String, dynamic> json) {
    return MeengleCircle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: CircleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      imageUrl: json['imageUrl'] as String,
      tags: List<String>.from(json['tags'] as List),
      memberCount: json['memberCount'] as int,
      postsCount: json['postsCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOfficial: json['isOfficial'] as bool? ?? false,
      isMember: json['isMember'] as bool? ?? false,
      createdByUserId: json['createdByUserId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        imageUrl,
        tags,
        memberCount,
        postsCount,
        createdAt,
        isOfficial,
        isMember,
        createdByUserId,
      ];
}

/// User's membership in a circle
class CircleMembership extends Equatable {
  final String id;
  final String userId;
  final String circleId;
  final DateTime joinedAt;
  final bool isModerator;
  final bool isBlocked;

  const CircleMembership({
    required this.id,
    required this.userId,
    required this.circleId,
    required this.joinedAt,
    this.isModerator = false,
    this.isBlocked = false,
  });

  CircleMembership copyWith({
    String? id,
    String? userId,
    String? circleId,
    DateTime? joinedAt,
    bool? isModerator,
    bool? isBlocked,
  }) {
    return CircleMembership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      circleId: circleId ?? this.circleId,
      joinedAt: joinedAt ?? this.joinedAt,
      isModerator: isModerator ?? this.isModerator,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'circleId': circleId,
      'joinedAt': joinedAt.toIso8601String(),
      'isModerator': isModerator,
      'isBlocked': isBlocked,
    };
  }

  factory CircleMembership.fromJson(Map<String, dynamic> json) {
    return CircleMembership(
      id: json['id'] as String,
      userId: json['userId'] as String,
      circleId: json['circleId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isModerator: json['isModerator'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        circleId,
        joinedAt,
        isModerator,
        isBlocked,
      ];
}
