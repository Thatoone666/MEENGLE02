import 'package:equatable/equatable.dart';

/// Categories for Meengle Prompts
enum PromptCategory {
  personality,
  lifestyle,
  coreValues,
  interests,
  humor,
  dreams,
  quirks,
  travel,
  food,
  music,
  movies,
  books,
  sports,
  health,
  career,
}

extension PromptCategoryExtension on PromptCategory {
  String get label {
    switch (this) {
      case PromptCategory.personality:
        return 'Personality';
      case PromptCategory.lifestyle:
        return 'Lifestyle';
      case PromptCategory.coreValues:
        return 'Core Values';
      case PromptCategory.interests:
        return 'Interests';
      case PromptCategory.humor:
        return 'Humor';
      case PromptCategory.dreams:
        return 'Dreams';
      case PromptCategory.quirks:
        return 'Quirks';
      case PromptCategory.travel:
        return 'Travel';
      case PromptCategory.food:
        return 'Food';
      case PromptCategory.music:
        return 'Music';
      case PromptCategory.movies:
        return 'Movies';
      case PromptCategory.books:
        return 'Books';
      case PromptCategory.sports:
        return 'Sports';
      case PromptCategory.health:
        return 'Health';
      case PromptCategory.career:
        return 'Career';
    }
  }

  String get emoji {
    switch (this) {
      case PromptCategory.personality:
        return '✨';
      case PromptCategory.lifestyle:
        return '🌟';
      case PromptCategory.coreValues:
        return '💎';
      case PromptCategory.interests:
        return '🎯';
      case PromptCategory.humor:
        return '😄';
      case PromptCategory.dreams:
        return '🌙';
      case PromptCategory.quirks:
        return '🎪';
      case PromptCategory.travel:
        return '✈️';
      case PromptCategory.food:
        return '🍽️';
      case PromptCategory.music:
        return '🎵';
      case PromptCategory.movies:
        return '🎬';
      case PromptCategory.books:
        return '📚';
      case PromptCategory.sports:
        return '⚽';
      case PromptCategory.health:
        return '💪';
      case PromptCategory.career:
        return '💼';
    }
  }
}

/// Represents a Meengle Prompt - quick personality questions
class MeenglePrompt extends Equatable {
  final String id;
  final String question;
  final List<String> suggestedAnswers;
  final PromptCategory category;
  final int characterLimit;
  final int displayOrder;
  final bool isActive;

  const MeenglePrompt({
    required this.id,
    required this.question,
    required this.suggestedAnswers,
    required this.category,
    this.characterLimit = 150,
    required this.displayOrder,
    this.isActive = true,
  });

  /// Create a copy with modified fields
  MeenglePrompt copyWith({
    String? id,
    String? question,
    List<String>? suggestedAnswers,
    PromptCategory? category,
    int? characterLimit,
    int? displayOrder,
    bool? isActive,
  }) {
    return MeenglePrompt(
      id: id ?? this.id,
      question: question ?? this.question,
      suggestedAnswers: suggestedAnswers ?? this.suggestedAnswers,
      category: category ?? this.category,
      characterLimit: characterLimit ?? this.characterLimit,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'suggestedAnswers': suggestedAnswers,
      'category': category.toString().split('.').last,
      'characterLimit': characterLimit,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory MeenglePrompt.fromJson(Map<String, dynamic> json) {
    return MeenglePrompt(
      id: json['id'] as String,
      question: json['question'] as String,
      suggestedAnswers: List<String>.from(json['suggestedAnswers'] as List),
      category: PromptCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      characterLimit: json['characterLimit'] as int? ?? 150,
      displayOrder: json['displayOrder'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        question,
        suggestedAnswers,
        category,
        characterLimit,
        displayOrder,
        isActive,
      ];
}

/// User's response to a Meengle Prompt
class UserPromptAnswer extends Equatable {
  final String id;
  final String userId;
  final String promptId;
  final String answer;
  final DateTime answeredAt;
  final int displayOrder;
  final bool isPublic;

  const UserPromptAnswer({
    required this.id,
    required this.userId,
    required this.promptId,
    required this.answer,
    required this.answeredAt,
    required this.displayOrder,
    this.isPublic = true,
  });

  UserPromptAnswer copyWith({
    String? id,
    String? userId,
    String? promptId,
    String? answer,
    DateTime? answeredAt,
    int? displayOrder,
    bool? isPublic,
  }) {
    return UserPromptAnswer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      promptId: promptId ?? this.promptId,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
      displayOrder: displayOrder ?? this.displayOrder,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'promptId': promptId,
      'answer': answer,
      'answeredAt': answeredAt.toIso8601String(),
      'displayOrder': displayOrder,
      'isPublic': isPublic,
    };
  }

  factory UserPromptAnswer.fromJson(Map<String, dynamic> json) {
    return UserPromptAnswer(
      id: json['id'] as String,
      userId: json['userId'] as String,
      promptId: json['promptId'] as String,
      answer: json['answer'] as String,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      displayOrder: json['displayOrder'] as int,
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        promptId,
        answer,
        answeredAt,
        displayOrder,
        isPublic,
      ];
}
