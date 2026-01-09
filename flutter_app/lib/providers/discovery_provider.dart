import 'package:flutter/foundation.dart';
import '../models/meengle_match.dart';
import '../services/discovery_service.dart';

class DiscoveryProvider extends ChangeNotifier {
  final DiscoveryService _service = DiscoveryService();
  
  List<MeengleMatch> _candidates = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;
  int _likeCount = 0;

  List<MeengleMatch> get candidates => _candidates;
  MeengleMatch? get currentCandidate => _currentIndex < _candidates.length ? _candidates[_currentIndex] : null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get likeCount => _likeCount;

  Future<void> loadCandidates() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _candidates = await _service.getDiscoveryCandidates();
      _currentIndex = 0;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> like(String userId) async {
    try {
      await _service.likeUser(userId);
      _likeCount++;
      _currentIndex++;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pass(String userId) async {
    try {
      _currentIndex++;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> getLikes() async {
    try {
      final result = await _service.getReceivedLikes();
      _likeCount = result;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
