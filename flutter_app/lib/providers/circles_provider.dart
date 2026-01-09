import 'package:flutter/foundation.dart';
import '../models/meengle_circle.dart';
import '../services/circle_service.dart';

class CirclesProvider extends ChangeNotifier {
  final CircleService _service = CircleService();
  
  List<MeengleCircle> _circles = [];
  final List<MeengleCircle> _joinedCircles = [];
  bool _isLoading = false;
  String? _error;

  List<MeengleCircle> get circles => _circles;
  List<MeengleCircle> get joinedCircles => _joinedCircles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCircles() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _circles = await _service.getAllCircles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> joinCircle(String circleId) async {
    try {
      final circle = _circles.firstWhere((c) => c.id == circleId);
      await _service.joinCircle(userId: '', circleId: circleId);
      _joinedCircles.add(circle);
      _circles.removeWhere((c) => c.id == circleId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isJoined(String circleId) {
    return _joinedCircles.any((c) => c.id == circleId);
  }
}
