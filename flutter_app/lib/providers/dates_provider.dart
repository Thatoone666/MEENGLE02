import 'package:flutter/foundation.dart';
import '../models/meengle_date.dart';
import '../services/date_service.dart';

class DatesProvider extends ChangeNotifier {
  final DateService _service = DateService();
  
  List<MeengleDate> _suggestions = [];
  final List<MeengleDate> _history = [];
  bool _isLoading = false;
  String? _error;

  List<MeengleDate> get suggestions => _suggestions;
  List<MeengleDate> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSuggestions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _suggestions = await _service.getAllDateIdeas();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> proposeDate(String matchId, String title, String location, DateTime time, String vibe) async {
    try {
      await _service.suggestDate(
        fromUserId: '',
        toUserId: matchId,
        dateId: title,
      );
      final date = MeengleDate(
        id: 'date_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: '',
        category: DateCategory.casual,
        location: location,
        estimatedDuration: 120,
        estimatedCost: 2,
        tags: [],
        popularity: 0,
        imageUrl: '',
      );
      _history.insert(0, date);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> acceptDate(String dateId) async {
    try {
      await _service.acceptDate(dateId);
      final idx = _history.indexWhere((d) => d.id == dateId);
      if (idx >= 0) {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
