import 'package:equatable/equatable.dart';

/// Represents a Meengle Moment - time-pressure matching with 24-hour expiry
class MeengleMoment extends Equatable {
  final String id;
  final String userId;
  final String matchId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int extensionsUsed; // How many 6-hour extensions have been used
  final int maxExtensions; // Max extensions allowed (usually 2)
  final bool isExpired;
  final bool hasResponded;
  final DateTime? respondedAt;
  final bool accepted; // null = no response yet, true = accepted, false = rejected
  final String? message; // Optional message from user

  const MeengleMoment({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.createdAt,
    required this.expiresAt,
    required this.extensionsUsed,
    this.maxExtensions = 2,
    required this.isExpired,
    this.hasResponded = false,
    this.respondedAt,
    this.accepted = false,
    this.message,
  });

  /// Time remaining in seconds
  int get secondsRemaining {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Time remaining formatted (e.g., "2h 30m")
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

  /// Can extend this moment
  bool get canExtend => extensionsUsed < maxExtensions && !isExpired;

  /// Calculate new expiry date after extension
  DateTime getExtendedExpiry() {
    return expiresAt.add(Duration(hours: 6));
  }

  MeengleMoment copyWith({
    String? id,
    String? userId,
    String? matchId,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? extensionsUsed,
    int? maxExtensions,
    bool? isExpired,
    bool? hasResponded,
    DateTime? respondedAt,
    bool? accepted,
    String? message,
  }) {
    return MeengleMoment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchId: matchId ?? this.matchId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      extensionsUsed: extensionsUsed ?? this.extensionsUsed,
      maxExtensions: maxExtensions ?? this.maxExtensions,
      isExpired: isExpired ?? this.isExpired,
      hasResponded: hasResponded ?? this.hasResponded,
      respondedAt: respondedAt ?? this.respondedAt,
      accepted: accepted ?? this.accepted,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'matchId': matchId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'extensionsUsed': extensionsUsed,
      'maxExtensions': maxExtensions,
      'isExpired': isExpired,
      'hasResponded': hasResponded,
      'respondedAt': respondedAt?.toIso8601String(),
      'accepted': accepted,
      'message': message,
    };
  }

  factory MeengleMoment.fromJson(Map<String, dynamic> json) {
    return MeengleMoment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchId: json['matchId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      extensionsUsed: json['extensionsUsed'] as int,
      maxExtensions: json['maxExtensions'] as int? ?? 2,
      isExpired: json['isExpired'] as bool,
      hasResponded: json['hasResponded'] as bool? ?? false,
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      accepted: json['accepted'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        matchId,
        createdAt,
        expiresAt,
        extensionsUsed,
        maxExtensions,
        isExpired,
        hasResponded,
        respondedAt,
        accepted,
        message,
      ];
}
