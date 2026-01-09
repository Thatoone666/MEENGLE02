import 'package:meengle_flutter/models/meengle_prompt.dart';

/// Service for managing Meengle Prompts
class PromptService {
  /// Seed data with 50+ prompts across all categories
  static final List<MeenglePrompt> seedPrompts = [
    // Personality
    MeenglePrompt(
      id: 'prompt_001',
      question: 'What\'s a weird habit of yours?',
      suggestedAnswers: [
        'I talk to my pets',
        'I reorganize things constantly',
        'I narrate my day',
        'I collect random things',
        'I can\'t watch movies without subtitles',
      ],
      category: PromptCategory.personality,
      displayOrder: 1,
    ),
    MeenglePrompt(
      id: 'prompt_002',
      question: 'How do friends describe you?',
      suggestedAnswers: [
        'The funny one',
        'The responsible one',
        'The adventurous one',
        'The listener',
        'The wildcard',
      ],
      category: PromptCategory.personality,
      displayOrder: 2,
    ),

    // Lifestyle
    MeenglePrompt(
      id: 'prompt_003',
      question: 'My ideal weekend is...',
      suggestedAnswers: [
        'Outdoor adventure',
        'Cozy night in',
        'Social gatherings',
        'Cultural activities',
        'Spontaneous fun',
      ],
      category: PromptCategory.lifestyle,
      displayOrder: 3,
    ),
    MeenglePrompt(
      id: 'prompt_004',
      question: 'I\'m a morning person or night owl?',
      suggestedAnswers: [
        'Early bird ☀️',
        'Total night owl 🌙',
        'Somewhere in between',
        'Depends on the day',
        'Not sure yet',
      ],
      category: PromptCategory.lifestyle,
      displayOrder: 4,
    ),

    // Core Values
    MeenglePrompt(
      id: 'prompt_005',
      question: 'What\'s most important to you?',
      suggestedAnswers: [
        'Family & close relationships',
        'Personal growth & learning',
        'Making a difference',
        'Adventure & experiences',
        'Financial security',
      ],
      category: PromptCategory.coreValues,
      displayOrder: 5,
    ),
    MeenglePrompt(
      id: 'prompt_006',
      question: 'My deal-breaker is...',
      suggestedAnswers: [
        'Dishonesty',
        'Lack of ambition',
        'No sense of humor',
        'Different life goals',
        'Poor communication',
      ],
      category: PromptCategory.coreValues,
      displayOrder: 6,
    ),

    // Interests
    MeenglePrompt(
      id: 'prompt_007',
      question: 'My favorite way to unwind is...',
      suggestedAnswers: [
        'Watching shows',
        'Reading',
        'Working out',
        'Hanging with friends',
        'Creating something',
      ],
      category: PromptCategory.interests,
      displayOrder: 7,
    ),
    MeenglePrompt(
      id: 'prompt_008',
      question: 'I could talk for hours about...',
      suggestedAnswers: [
        'Movies & TV',
        'Sports & fitness',
        'Food & cooking',
        'Travel stories',
        'My hobbies',
      ],
      category: PromptCategory.interests,
      displayOrder: 8,
    ),

    // Humor
    MeenglePrompt(
      id: 'prompt_009',
      question: 'My humor style is...',
      suggestedAnswers: [
        'Dark & sarcastic',
        'Witty & clever',
        'Silly & random',
        'Observational',
        'Self-deprecating',
      ],
      category: PromptCategory.humor,
      displayOrder: 9,
    ),
    MeenglePrompt(
      id: 'prompt_010',
      question: 'What makes you laugh?',
      suggestedAnswers: [
        'Memes & TikToks',
        'Stand-up comedy',
        'Funny friends',
        'Absurdist humor',
        'Clever wordplay',
      ],
      category: PromptCategory.humor,
      displayOrder: 10,
    ),

    // Dreams
    MeenglePrompt(
      id: 'prompt_011',
      question: 'Where do you see yourself in 5 years?',
      suggestedAnswers: [
        'Established in my career',
        'Still figuring it out',
        'Running my own business',
        'Traveling the world',
        'Building a family',
      ],
      category: PromptCategory.dreams,
      displayOrder: 11,
    ),
    MeenglePrompt(
      id: 'prompt_012',
      question: 'My biggest dream is...',
      suggestedAnswers: [
        'Travel to every continent',
        'Build something meaningful',
        'Financial independence',
        'Make people happy',
        'Learn something amazing',
      ],
      category: PromptCategory.dreams,
      displayOrder: 12,
    ),

    // Quirks
    MeenglePrompt(
      id: 'prompt_013',
      question: 'Unpopular opinion: I actually like...',
      suggestedAnswers: [
        'Pineapple on pizza',
        'Unsolicited advice',
        'Rain days',
        'Awkward silences',
        'Horror movies',
      ],
      category: PromptCategory.quirks,
      displayOrder: 13,
    ),
    MeenglePrompt(
      id: 'prompt_014',
      question: 'I waste money on...',
      suggestedAnswers: [
        'Coffee',
        'Impulse buys',
        'Experiences',
        'Gadgets',
        'Comfort items',
      ],
      category: PromptCategory.quirks,
      displayOrder: 14,
    ),

    // Travel
    MeenglePrompt(
      id: 'prompt_015',
      question: 'My travel style is...',
      suggestedAnswers: [
        'Planned & organized',
        'Spontaneous & free',
        'Adventure seeker',
        'Luxury lover',
        'Budget traveler',
      ],
      category: PromptCategory.travel,
      displayOrder: 15,
    ),
    MeenglePrompt(
      id: 'prompt_016',
      question: 'Dream destination is...',
      suggestedAnswers: [
        'Southeast Asia',
        'European cities',
        'Adventure travel',
        'Tropical paradise',
        'Multiple places',
      ],
      category: PromptCategory.travel,
      displayOrder: 16,
    ),

    // Food
    MeenglePrompt(
      id: 'prompt_017',
      question: 'I\'m obsessed with...',
      suggestedAnswers: [
        'Italian food',
        'Asian cuisine',
        'Vegan food',
        'Street food',
        'Homemade meals',
      ],
      category: PromptCategory.food,
      displayOrder: 17,
    ),
    MeenglePrompt(
      id: 'prompt_018',
      question: 'My go-to order is...',
      suggestedAnswers: [
        'The same thing always',
        'Always trying something new',
        'Depends on my mood',
        'Whatever\'s popular',
        'I meal prep',
      ],
      category: PromptCategory.food,
      displayOrder: 18,
    ),

    // Music
    MeenglePrompt(
      id: 'prompt_019',
      question: 'My music taste is...',
      suggestedAnswers: [
        'Hip-hop & rap',
        'Pop & mainstream',
        'Indie & alternative',
        'Rock & metal',
        'All over the place',
      ],
      category: PromptCategory.music,
      displayOrder: 19,
    ),
    MeenglePrompt(
      id: 'prompt_020',
      question: 'Concert I\'d never miss...',
      suggestedAnswers: [
        'My favorite artist',
        'Any good festival',
        'Live music venue',
        'I\'m more of a playlist person',
        'The right artist, right time',
      ],
      category: PromptCategory.music,
      displayOrder: 20,
    ),

    // Movies
    MeenglePrompt(
      id: 'prompt_021',
      question: 'My movie genre is...',
      suggestedAnswers: [
        'Action & thrillers',
        'Comedy',
        'Drama & indie films',
        'Horror',
        'Fantasy & sci-fi',
      ],
      category: PromptCategory.movies,
      displayOrder: 21,
    ),
    MeenglePrompt(
      id: 'prompt_022',
      question: 'Movie night means...',
      suggestedAnswers: [
        'Snuggled on couch',
        'At the cinema',
        'With a group',
        'Alone with snacks',
        'Depends on the movie',
      ],
      category: PromptCategory.movies,
      displayOrder: 22,
    ),

    // Books
    MeenglePrompt(
      id: 'prompt_023',
      question: 'I love reading about...',
      suggestedAnswers: [
        'Adventure & mystery',
        'Personal development',
        'Fiction & fantasy',
        'Biographies',
        'I don\'t really read',
      ],
      category: PromptCategory.books,
      displayOrder: 23,
    ),

    // Sports
    MeenglePrompt(
      id: 'prompt_024',
      question: 'My fitness routine is...',
      suggestedAnswers: [
        'Gym regularly',
        'Yoga & flexibility',
        'Running & cardio',
        'Sports & teams',
        'Mostly couch time',
      ],
      category: PromptCategory.sports,
      displayOrder: 24,
    ),

    // Health
    MeenglePrompt(
      id: 'prompt_025',
      question: 'My diet is...',
      suggestedAnswers: [
        'Balanced & healthy',
        'Vegetarian/vegan',
        'Whatever tastes good',
        'Mostly fast food',
        'Mix of everything',
      ],
      category: PromptCategory.health,
      displayOrder: 25,
    ),

    // Career
    MeenglePrompt(
      id: 'prompt_026',
      question: 'My job is...',
      suggestedAnswers: [
        'My passion',
        'Just pays the bills',
        'Still figuring it out',
        'Building my empire',
        'Career changer',
      ],
      category: PromptCategory.career,
      displayOrder: 26,
    ),
  ];

  /// Get all prompts
  Future<List<MeenglePrompt>> getAllPrompts() async {
    // In production, fetch from backend
    // For now, return seed data
    return seedPrompts;
  }

  /// Get prompts by category
  Future<List<MeenglePrompt>> getPromptsByCategory(
    PromptCategory category,
  ) async {
    return seedPrompts.where((p) => p.category == category).toList();
  }

  /// Get random prompts (for discovery)
  Future<List<MeenglePrompt>> getRandomPrompts({int count = 5}) async {
    final shuffled = List.from(seedPrompts)..shuffle();
    return shuffled.take(count).toList().cast<MeenglePrompt>();
  }

  /// Submit user's answer to a prompt
  Future<UserPromptAnswer> submitPromptAnswer({
    required String userId,
    required String promptId,
    required String answer,
    required int displayOrder,
  }) async {
    // In production, send to backend
    return UserPromptAnswer(
      id: 'answer_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      promptId: promptId,
      answer: answer,
      answeredAt: DateTime.now(),
      displayOrder: displayOrder,
      isPublic: true,
    );
  }

  /// Get user's prompt answers
  Future<List<UserPromptAnswer>> getUserPromptAnswers(String userId) async {
    // In production, fetch from backend
    return [];
  }

  /// Get profile preview (3-5 answers shown publicly)
  Future<List<UserPromptAnswer>> getProfilePrompts(String userId) async {
    // In production, get top rated answers
    final answers = await getUserPromptAnswers(userId);
    return answers.take(5).toList();
  }
}
