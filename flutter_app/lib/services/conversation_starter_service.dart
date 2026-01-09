import '../models/conversation_starter.dart';
import '../utils/logger.dart';

class ConversationStarterService {
  static final _logger = Logger();

  // Curated conversation starters by category
  static const Map<String, List<String>> _curatedStarters = {
    'humor': [
      "If you could only eat food of one cuisine for the rest of your life, what would it be? (And would you survive it?)",
      "What's your most embarrassing moment that you now find hilarious?",
      "If you had to pick a superpower but it had a weird side effect, which would you choose?",
      "What's the funniest misunderstanding someone had about you?",
    ],
    'interests': [
      "What's a hobby you're weirdly passionate about?",
      "Tell me about a passion project you're working on or dreaming about",
      "What's an interest you have that surprises people?",
      "If you had a weekend with no plans, what would be your ideal agenda?",
    ],
    'values': [
      "What's something you'd never compromise on?",
      "What does a meaningful relationship look like to you?",
      "What's a core value that defines who you are?",
      "What kind of future do you envision for yourself in 5 years?",
    ],
    'travel': [
      "What's the best trip you've ever taken and why?",
      "Where's a place you've been that changed your perspective?",
      "What's on your travel bucket list?",
      "Are you more of an adventure traveler or comfort traveler?",
    ],
    'lifestyle': [
      "How do you like to spend your ideal day off?",
      "What's a morning/evening routine that's important to you?",
      "How important is balance between work and personal time for you?",
      "What makes you feel most alive?",
    ],
    'values_commitment': [
      "What are you looking for in a relationship right now?",
      "What's a dealbreaker for you in a partnership?",
      "How do you typically handle conflict?",
    ],
  };

  /// Get AI-generated starters based on match profile
  Future<List<ConversationStarter>> generatePersonalizedStarters({
    required String matchId,
    required Map<String, dynamic> matchProfile,
    required Map<String, dynamic> currentUserProfile,
    int count = 3,
  }) async {
    try {
      final starters = <ConversationStarter>[];

      // Analyze match profile to determine best categories
      final categories = _determineCategories(matchProfile, currentUserProfile);

      // Get curated starters from recommended categories
      for (final category in categories.take(3)) {
        final categoryStarters = _curatedStarters[category] ?? [];
        if (categoryStarters.isNotEmpty) {
          final question = categoryStarters[
              DateTime.now().millisecondsSinceEpoch % categoryStarters.length];
          
          starters.add(ConversationStarter(
            id: '${matchId}_${DateTime.now().millisecondsSinceEpoch}',
            question: question,
            category: category,
            difficulty: _getDifficultyByCategory(category),
            followUpSuggestion: _generateFollowUp(question, category),
            isGenerated: true,
            createdAt: DateTime.now(),
          ));
        }
      }

      // Add generic starters if needed
      while (starters.length < count) {
        starters.add(_getGenericStarter());
      }

      return starters.take(count).toList();
    } catch (e) {
      _logger.error('Error generating personalized starters', e);
      return _getDefaultStarters();
    }
  }

  /// Analyze conversation to suggest next moves
  Future<ConversationAnalysis> analyzeConversation({
    required List<Map<String, dynamic>> messageHistory,
    required String matchProfile,
  }) async {
    try {
      final analysis = ConversationAnalysis(
        engagementScore: _calculateEngagement(messageHistory),
        suggestedTone: _determineTone(messageHistory),
        suggestedQuestions:
            await generatePersonalizedStarters(
          matchId: '',
          matchProfile: {},
          currentUserProfile: {},
          count: 3,
        ),
        conversationMomentum: _analyzeMomentum(messageHistory),
        analyzedAt: DateTime.now(),
      );

      return analysis;
    } catch (e) {
      _logger.error('Error analyzing conversation', e);
      return ConversationAnalysis(
        engagementScore: 50,
        suggestedTone: 'thoughtful',
        suggestedQuestions: _getDefaultStarters(),
        conversationMomentum: 'stable',
        analyzedAt: DateTime.now(),
      );
    }
  }

  /// Determine which categories to prioritize
  List<String> _determineCategories(
    Map<String, dynamic> matchProfile,
    Map<String, dynamic> currentUserProfile,
  ) {
    final categories = <String>[];

    // If they share interests, start with that
    if (_hasCommonInterests(matchProfile, currentUserProfile)) {
      categories.add('interests');
    }

    // Check relationship goal alignment for values questions
    if (matchProfile['relationshipGoal'] != null) {
      categories.add('values_commitment');
    }

    // Add travel if mentioned in bio
    if (_mentionsTravelInBio(matchProfile)) {
      categories.add('travel');
    }

    // Add humor/lifestyle
    categories.addAll(['humor', 'lifestyle', 'values']);

    return categories;
  }

  bool _hasCommonInterests(
    Map<String, dynamic> match,
    Map<String, dynamic> user,
  ) {
    final matchInterests = (match['interests'] as List?)?.cast<String>() ?? [];
    final userInterests = (user['interests'] as List?)?.cast<String>() ?? [];
    return matchInterests.toSet().intersection(userInterests.toSet()).isNotEmpty;
  }

  bool _mentionsTravelInBio(Map<String, dynamic> profile) {
    final bio = (profile['bio'] ?? '').toString().toLowerCase();
    return bio.contains('travel') ||
        bio.contains('explore') ||
        bio.contains('adventure');
  }

  int _getDifficultyByCategory(String category) {
    switch (category) {
      case 'humor':
        return 1; // Light
      case 'interests':
        return 1;
      case 'travel':
        return 2;
      case 'values_commitment':
        return 3; // Deep
      case 'values':
        return 3;
      default:
        return 2;
    }
  }

  String? _generateFollowUp(String question, String category) {
    // Generate contextual follow-up suggestions
    switch (category) {
      case 'travel':
        return "Ask about their favorite travel memory";
      case 'interests':
        return "Share your own passion and ask about theirs";
      case 'values':
        return "Share what matters to you too";
      case 'humor':
        return "React to their answer with humor";
      default:
        return null;
    }
  }

  double _calculateEngagement(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return 0;

    int responses = 0;
    int questions = 0;
    int emoticons = 0;

    for (final msg in messages) {
      final text = (msg['text'] ?? '').toString();
      if (text.contains('?')) {
        questions++;
      }
      if (text.contains('😊') ||
          text.contains('❤️') ||
          text.contains('😂') ||
          text.contains('😍')) {
        emoticons++;
      }
      if (text.isNotEmpty && msg['isMine'] == false) {
        responses++;
      }
    }

    // Scoring: responses, questions, emoji usage
    final score =
        (responses * 20 + questions * 15 + emoticons * 10) / messages.length;
    return score.clamp(0, 100).toDouble();
  }

  String _determineTone(List<Map<String, dynamic>> messages) {
    int playfulScore = 0;
    int thoughtfulScore = 0;
    int romanticScore = 0;

    for (final msg in messages) {
      final text = (msg['text'] ?? '').toString().toLowerCase();

      if (text.contains('😂') ||
          text.contains('haha') ||
          text.contains('lol')) {
        playfulScore++;
      }
      if (text.contains('think') ||
          text.contains('believe') ||
          text.contains('important')) {
        thoughtfulScore++;
      }
      if (text.contains('❤️') ||
          text.contains('miss') ||
          text.contains('beautiful')) {
        romanticScore++;
      }
    }

    if (romanticScore > playfulScore && romanticScore > thoughtfulScore) {
      return 'romantic';
    } else if (thoughtfulScore > playfulScore) {
      return 'thoughtful';
    }
    return 'playful';
  }

  String _analyzeMomentum(List<Map<String, dynamic>> messages) {
    if (messages.length < 3) return 'stable';

    final recent = messages.sublist(
      (messages.length - 3).clamp(0, messages.length),
    );
    final older = messages.length > 5
        ? messages.sublist(0, (messages.length - 6).clamp(0, messages.length))
        : <Map<String, dynamic>>[];

    final recentEngagement = _calculateEngagement(recent);
    final olderEngagement =
        older.isNotEmpty ? _calculateEngagement(older) : recentEngagement;

    if (recentEngagement > olderEngagement + 10) {
      return 'heating_up';
    } else if (recentEngagement < olderEngagement - 10) {
      return 'cooling_down';
    }
    return 'stable';
  }

  ConversationStarter _getGenericStarter() {
    return ConversationStarter(
      id: 'generic_${DateTime.now().millisecondsSinceEpoch}',
      question: "What's something most people don't know about you?",
      category: 'interests',
      difficulty: 2,
      createdAt: DateTime.now(),
    );
  }

  List<ConversationStarter> _getDefaultStarters() {
    return [
      ConversationStarter(
        id: 'default_1',
        question: "Tell me something interesting about yourself",
        category: 'interests',
        difficulty: 1,
        createdAt: DateTime.now(),
      ),
      ConversationStarter(
        id: 'default_2',
        question: "What brings you joy?",
        category: 'values',
        difficulty: 2,
        createdAt: DateTime.now(),
      ),
      ConversationStarter(
        id: 'default_3',
        question: "What's on your bucket list?",
        category: 'travel',
        difficulty: 2,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
