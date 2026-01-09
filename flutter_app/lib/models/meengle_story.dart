import 'package:equatable/equatable.dart';

/// Represents a Meengle Story - 24-hour authentic content like Snapchat
class MeengleStory extends Equatable {
  final String id;
  final String userId;
  final String mediaUrl; // Image or video URL
  final String mediaType; // 'image' or 'video'
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final int likeCount; // Number of likes on the story
  final List<String> likedByUserIds; // IDs of users who liked this story
  final List<String> viewedByUserIds;
  final List<StoryReaction> reactions;
  final List<String> commentIds;
  final bool isHidden; // Hidden from profile but still visible to friends

  const MeengleStory({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.likedByUserIds = const [],
    this.viewedByUserIds = const [],
    this.reactions = const [],
    this.commentIds = const [],
    this.isHidden = false,
  });

  /// Check if story has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Alias for mediaUrl for compatibility
  String? get imageUrl => mediaUrl;

  /// Time remaining in seconds
  int get secondsRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Time remaining formatted (e.g., "5h 20m")
  String get timeRemainingFormatted {
    final remaining = secondsRemaining;
    if (remaining == 0) return 'Expired';
    
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  MeengleStory copyWith({
    String? id,
    String? userId,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    List<String>? likedByUserIds,
    List<String>? viewedByUserIds,
    List<StoryReaction>? reactions,
    List<String>? commentIds,
    bool? isHidden,
  }) {
    return MeengleStory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      viewedByUserIds: viewedByUserIds ?? this.viewedByUserIds,
      reactions: reactions ?? this.reactions,
      commentIds: commentIds ?? this.commentIds,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'likedByUserIds': likedByUserIds,
      'viewedByUserIds': viewedByUserIds,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'commentIds': commentIds,
      'isHidden': isHidden,
    };
  }

  factory MeengleStory.fromJson(Map<String, dynamic> json) {
    return MeengleStory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      likedByUserIds:
          List<String>.from(json['likedByUserIds'] as List? ?? []),
      viewedByUserIds:
          List<String>.from(json['viewedByUserIds'] as List? ?? []),
      reactions: (json['reactions'] as List?)
              ?.map((r) => StoryReaction.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      commentIds: List<String>.from(json['commentIds'] as List? ?? []),
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        mediaUrl,
        mediaType,
        caption,
        createdAt,
        expiresAt,
        viewCount,
        likeCount,
        likedByUserIds,
        viewedByUserIds,
        reactions,
        commentIds,
        isHidden,
      ];
}

/// Reaction to a story (emoji)
class StoryReaction extends Equatable {
  final String userId;
  final String emoji; // e.g., '❤️', '😍', '🔥', etc.
  final DateTime reactedAt;

  const StoryReaction({
    required this.userId,
    required this.emoji,
    required this.reactedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'reactedAt': reactedAt.toIso8601String(),
    };
  }

  factory StoryReaction.fromJson(Map<String, dynamic> json) {
    return StoryReaction(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      reactedAt: DateTime.parse(json['reactedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [userId, emoji, reactedAt];
}

/// Comment on a story
class StoryComment extends Equatable {
  final String id;
  final String storyId;
  final String userId;
  final String comment;
  final DateTime createdAt;
  final int likes;
  final bool likedByViewer;

  const StoryComment({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.likedByViewer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'userId': userId,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedByViewer': likedByViewer,
    };
  }

  factory StoryComment.fromJson(Map<String, dynamic> json) {
    return StoryComment(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      likedByViewer: json['likedByViewer'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storyId,
        userId,
        comment,
        createdAt,
        likes,
        likedByViewer,
      ];
}
