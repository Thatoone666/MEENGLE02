import 'package:equatable/equatable.dart';

/// Video profile model
class VideoProfile extends Equatable {
  final String id;
  final String userId;
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final DateTime uploadedAt;
  final int viewCount;
  final bool isActive;

  const VideoProfile({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.uploadedAt,
    this.viewCount = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, userId, videoUrl, thumbnailUrl, durationSeconds, uploadedAt, viewCount, isActive];
}

/// Achievement badges model
class AchievementBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final String category; // 'verification', 'activity', 'milestone'

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, description, icon, unlockedAt, category];
}

/// Call/messaging status
class UserPresence extends Equatable {
  final String userId;
  final String status; // 'online', 'away', 'offline', 'on_call'
  final DateTime lastSeen;
  final bool isTyping;
  final String? currentCallWith;

  const UserPresence({
    required this.userId,
    required this.status,
    required this.lastSeen,
    this.isTyping = false,
    this.currentCallWith,
  });

  @override
  List<Object?> get props => [userId, status, lastSeen, isTyping, currentCallWith];
}

/// Match compatibility details
class MatchCompatibility extends Equatable {
  final String userId;
  final int compatibilityScore; // 0-100
  final List<String> commonInterests;
  final List<String> commonVerifications;
  final String reason;

  const MatchCompatibility({
    required this.userId,
    required this.compatibilityScore,
    required this.commonInterests,
    required this.commonVerifications,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, compatibilityScore, commonInterests, commonVerifications, reason];
}

/// Voice message model
class VoiceMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String audioUrl;
  final int durationSeconds;
  final DateTime sentAt;
  final bool isListened;

  const VoiceMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.audioUrl,
    required this.durationSeconds,
    required this.sentAt,
    this.isListened = false,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, audioUrl, durationSeconds, sentAt, isListened];
}
