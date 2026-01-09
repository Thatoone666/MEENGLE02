import 'package:flutter/foundation.dart';
import '../models/meengle_prompt.dart';
import '../services/prompt_service.dart';

/// Provider for managing prompts state
class PromptProvider extends ChangeNotifier {
  final PromptService _service = PromptService();
  
  List<MeenglePrompt> _allPrompts = [];
  final List<UserPromptAnswer> _userAnswers = [];
  bool _isLoading = false;
  String? _error;

  List<MeenglePrompt> get allPrompts => _allPrompts;
  List<UserPromptAnswer> get userAnswers => _userAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MeenglePrompt> get unansweredPrompts {
    final answeredIds = _userAnswers.map((a) => a.promptId).toSet();
    return _allPrompts.where((p) => !answeredIds.contains(p.id)).toList();
  }

  int get answeredCount => _userAnswers.length;
  int get totalCount => _allPrompts.length;

  Future<void> loadPrompts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allPrompts = await _service.getAllPrompts();
      // _userAnswers = await _service.getUserAnswers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String promptId, String answer) async {
    try {
      final newAnswer = UserPromptAnswer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        promptId: promptId,
        answer: answer,
        answeredAt: DateTime.now(),
        displayOrder: _userAnswers.length,
      );

      _userAnswers.add(newAnswer);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isPromptAnswered(String promptId) {
    return _userAnswers.any((a) => a.promptId == promptId);
  }

  UserPromptAnswer? getAnswerForPrompt(String promptId) {
    try {
      return _userAnswers.firstWhere((a) => a.promptId == promptId);
    } catch (e) {
      return null;
    }
  }
}
