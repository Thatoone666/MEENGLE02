import 'package:flutter/foundation.dart';
import '../models/meengle_roam.dart';

class RoamProvider extends ChangeNotifier {
  List<MeengleRoam> _roams = [];
  List<MeengleRoam> _filteredRoams = [];
  bool _isLoading = false;
  String? _error;
  MeengleRoam? _userRoam;

  List<MeengleRoam> get roams => _filteredRoams.isEmpty ? _roams : _filteredRoams;
  bool get isLoading => _isLoading;
  String? get error => _error;
  MeengleRoam? get userRoam => _userRoam;

  Future<void> loadRoams() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // For demo, create mock roams
      _roams = [
        MeengleRoam(
          id: 'roam1',
          userId: 'user1',
          isActive: true,
          currentCity: 'Paris',
          latitude: 48.8566,
          longitude: 2.3522,
          activatedAt: DateTime.now().subtract(const Duration(days: 3)),
          travelInterests: ['museums', 'food', 'nightlife'],
          lookingFor: ['adventure partner', 'date'],
        ),
        MeengleRoam(
          id: 'roam2',
          userId: 'user2',
          isActive: true,
          currentCity: 'Tokyo',
          latitude: 35.6762,
          longitude: 139.6503,
          activatedAt: DateTime.now().subtract(const Duration(days: 1)),
          travelInterests: ['temples', 'anime', 'cuisine'],
          lookingFor: ['local guide', 'adventure partner'],
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void filterByCity(String city) {
    if (city.isEmpty) {
      _filteredRoams = [];
    } else {
      _filteredRoams = _roams.where((r) => r.currentCity.toLowerCase().contains(city.toLowerCase())).toList();
    }
    notifyListeners();
  }
}
