import 'package:flutter/foundation.dart';
import '../models/video_profile.dart';
import '../services/video_profile_service.dart';
import '../services/achievement_service.dart';
import '../services/calling_service.dart';
import '../services/matching_service.dart';
import '../services/voice_message_service.dart';
import '../services/presence_service.dart';
import '../services/swipe_history_service.dart';
import '../services/icebreaker_game_service.dart';

/// Provider for video profiles
class VideoProfileProvider extends ChangeNotifier {
  final VideoProfileService _service;
  VideoProfile? _userVideo;
  bool _isLoading = false;
  String? _error;

  VideoProfileProvider({required VideoProfileService service}) : _service = service;

  VideoProfile? get userVideo => _userVideo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserVideo(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userVideo = await _service.getUserVideoProfile(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for achievements
class AchievementProvider extends ChangeNotifier {
  final AchievementService _service;
  List<AchievementBadge> _achievements = [];
  bool _isLoading = false;
  String? _error;

  AchievementProvider({required AchievementService service}) : _service = service;

  List<AchievementBadge> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _achievements = await _service.getUserAchievements(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for calling features
class CallingProvider extends ChangeNotifier {
  final CallingService _service;
  bool _inCall = false;
  String? _callId;
  String? _callWith;

  CallingProvider({required CallingService service}) : _service = service;

  bool get inCall => _inCall;
  String? get callId => _callId;
  String? get callWith => _callWith;

  Future<void> initiateVideoCall(String recipientId) async {
    final result = await _service.initiateVideoCall(recipientId);
    if (result != null) {
      _inCall = true;
      _callId = result['callId'];
      _callWith = recipientId;
      notifyListeners();
    }
  }

  Future<void> endCurrentCall() async {
    if (_callId != null) {
      await _service.endCall(_callId!);
      _inCall = false;
      _callId = null;
      _callWith = null;
      notifyListeners();
    }
  }
}

/// Provider for matching
class MatchingProvider extends ChangeNotifier {
  final MatchingService _service;
  List<MatchCompatibility> _topMatches = [];
  bool _isLoading = false;

  MatchingProvider({required MatchingService service}) : _service = service;

  List<MatchCompatibility> get topMatches => _topMatches;
  bool get isLoading => _isLoading;

  Future<void> loadTopMatches(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _topMatches = await _service.getTopMatches(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for presence/status
class PresenceProvider extends ChangeNotifier {
  final PresenceService _service;
  final Map<String, UserPresence> _presences = {};

  PresenceProvider({required PresenceService service}) : _service = service;

  UserPresence? getPresence(String userId) => _presences[userId];

  Future<void> updatePresence({
    required String userId,
    required String status,
  }) async {
    await _service.updatePresence(userId: userId, status: status);
    notifyListeners();
  }

  Future<void> loadPresence(String userId) async {
    final presence = await _service.getUserPresence(userId);
    if (presence != null) {
      _presences[userId] = presence;
      notifyListeners();
    }
  }
}

/// Provider for voice messages
class VoiceMessageProvider extends ChangeNotifier {
  final VoiceMessageService _service;
  List<VoiceMessage> _messages = [];
  bool _isLoading = false;

  VoiceMessageProvider({required VoiceMessageService service}) : _service = service;

  List<VoiceMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadChatVoiceMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages = await _service.getChatVoiceMessages(chatId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for swipe history/rewind
class SwipeHistoryProvider extends ChangeNotifier {
  final SwipeHistoryService _service;
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _rewindInfo;
  bool _isLoading = false;

  SwipeHistoryProvider({required SwipeHistoryService service}) : _service = service;

  List<Map<String, dynamic>> get history => _history;
  Map<String, dynamic>? get rewindInfo => _rewindInfo;
  bool get isLoading => _isLoading;

  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _service.getSwipeHistory(userId);
      _rewindInfo = await _service.getRewindInfo(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rewindLastSwipe(String userId) async {
    final result = await _service.undoLastSwipe(userId);
    if (result != null) {
      await loadHistory(userId);
      return true;
    }
    return false;
  }
}

/// Provider for icebreaker games
class IcebreakerGameProvider extends ChangeNotifier {
  final IcebreakerGameService _service;
  List<Map<String, dynamic>> _availableGames = [];
  List<Map<String, dynamic>> _gameHistory = [];
  bool _isLoading = false;

  IcebreakerGameProvider({required IcebreakerGameService service}) : _service = service;

  List<Map<String, dynamic>> get availableGames => _availableGames;
  List<Map<String, dynamic>> get gameHistory => _gameHistory;
  bool get isLoading => _isLoading;

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableGames = await _service.getAvailableGames();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGameHistory(String userId) async {
    try {
      _gameHistory = await _service.getGameHistory(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading game history: $e');
    }
  }
}
