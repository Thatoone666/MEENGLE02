import 'package:equatable/equatable.dart';

/// Story model for API responses
class Story extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userProfilePic;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewCount;
  final int likeCount;
  final bool isLiked;
  final bool isOwnStory;
  final List<String> viewedByIds;

  const Story({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isOwnStory = false,
    this.viewedByIds = const [],
  });

  /// Check if story has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Time remaining in hours
  int get hoursRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inHours;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if current user has viewed this story
  bool hasUserViewed(String userId) => viewedByIds.contains(userId);

  Story copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePic,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    bool? isLiked,
    bool? isOwnStory,
    List<String>? viewedByIds,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isOwnStory: isOwnStory ?? this.isOwnStory,
      viewedByIds: viewedByIds ?? this.viewedByIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isOwnStory': isOwnStory,
      'viewedByIds': viewedByIds,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonymous',
      userProfilePic: json['userProfilePic'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(Duration(hours: 24)),
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isOwnStory: json['isOwnStory'] as bool? ?? false,
      viewedByIds:
          List<String>.from(json['viewedByIds'] as List? ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userProfilePic,
        imageUrl,
        caption,
        createdAt,
        expiresAt,
        viewCount,
        likeCount,
        isLiked,
        isOwnStory,
        viewedByIds,
      ];
}
