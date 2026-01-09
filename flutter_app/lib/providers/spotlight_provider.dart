import 'package:flutter/foundation.dart';
import '../models/meengle_spotlight.dart';
import '../services/spotlight_service.dart';

class SpotlightProvider extends ChangeNotifier {
  final SpotlightService _service = SpotlightService();
  
  MeengleSpotlight? _activeSpotlight;
  List<MeengleSpotlight> _history = [];
  bool _isLoading = false;
  String? _error;

  MeengleSpotlight? get activeSpotlight => _activeSpotlight;
  List<MeengleSpotlight> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkActive(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _activeSpotlight = await _service.getUserActiveSpotlight(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> purchaseSpotlight(String userId, SpotlightTier tier) async {
    try {
      final spotlight = await _service.purchaseSpotlight(userId: userId, tier: tier);
      _activeSpotlight = spotlight;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      _history = await _service.getSpotlightHistory(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
