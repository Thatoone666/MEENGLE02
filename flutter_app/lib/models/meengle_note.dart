import 'package:equatable/equatable.dart';

/// Types of notes users can leave on profiles
enum NoteType {
  compliment,
  question,
  connection,
  flirty,
  thoughtful,
}

extension NoteTypeExtension on NoteType {
  String get emoji {
    switch (this) {
      case NoteType.compliment:
        return '💝';
      case NoteType.question:
        return '🤔';
      case NoteType.connection:
        return '🔗';
      case NoteType.flirty:
        return '😉';
      case NoteType.thoughtful:
        return '💭';
    }
  }

  String get label {
    switch (this) {
      case NoteType.compliment:
        return 'Compliment';
      case NoteType.question:
        return 'Question';
      case NoteType.connection:
        return 'Connection';
      case NoteType.flirty:
        return 'Flirty';
      case NoteType.thoughtful:
        return 'Thoughtful';
    }
  }
}

/// Represents a note left on someone's profile
class MeengleNote extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final NoteType type;
  final DateTime createdAt;
  final bool isAnonymous;
  final int likes; // How many people like this note
  final bool likedByRecipient;
  final List<String> replies; // IDs of reply notes

  const MeengleNote({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isAnonymous = false,
    this.likes = 0,
    this.likedByRecipient = false,
    this.replies = const [],
  });

  MeengleNote copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? content,
    NoteType? type,
    DateTime? createdAt,
    bool? isAnonymous,
    int? likes,
    bool? likedByRecipient,
    List<String>? replies,
  }) {
    return MeengleNote(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likes: likes ?? this.likes,
      likedByRecipient: likedByRecipient ?? this.likedByRecipient,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'likes': likes,
      'likedByRecipient': likedByRecipient,
      'replies': replies,
    };
  }

  factory MeengleNote.fromJson(Map<String, dynamic> json) {
    return MeengleNote(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      content: json['content'] as String,
      type: NoteType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      likedByRecipient: json['likedByRecipient'] as bool? ?? false,
      replies: List<String>.from(json['replies'] as List? ?? []),
    );
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        content,
        type,
        createdAt,
        isAnonymous,
        likes,
        likedByRecipient,
        replies,
      ];
}
