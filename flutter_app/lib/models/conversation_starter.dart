class ConversationStarter {
  final String id;
  final String question;
  final String category; // 'humor', 'interests', 'values', 'travel', 'lifestyle'
  final int difficulty; // 1-3, 1=casual, 3=deep
  final String? followUpSuggestion;
  final bool isGenerated; // AI-generated vs curated
  final DateTime createdAt;
  final bool isUsed;

  ConversationStarter({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    this.followUpSuggestion,
    this.isGenerated = false,
    required this.createdAt,
    this.isUsed = false,
  });

  factory ConversationStarter.fromJson(Map<String, dynamic> json) {
    return ConversationStarter(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? 'interests',
      difficulty: json['difficulty'] ?? 1,
      followUpSuggestion: json['followUpSuggestion'],
      isGenerated: json['isGenerated'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isUsed: json['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'followUpSuggestion': followUpSuggestion,
      'isGenerated': isGenerated,
      'createdAt': createdAt.toIso8601String(),
      'isUsed': isUsed,
    };
  }
}

class ConversationAnalysis {
  final double engagementScore; // 0-100
  final String suggestedTone; // 'playful', 'thoughtful', 'romantic'
  final List<ConversationStarter> suggestedQuestions;
  final String conversationMomentum; // 'heating_up', 'stable', 'cooling_down'
  final DateTime analyzedAt;

  ConversationAnalysis({
    required this.engagementScore,
    required this.suggestedTone,
    required this.suggestedQuestions,
    required this.conversationMomentum,
    required this.analyzedAt,
  });
}
