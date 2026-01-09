import 'package:flutter/foundation.dart';
import '../models/safety_center.dart';
import '../services/safety_service.dart';

// Safety provider for managing safety preferences
class SafetyProvider extends ChangeNotifier {
  final SafetyService _safetyService;

  SafetyPreferences _preferences = SafetyPreferences();
  List<BlockedUser> _blockedUsers = [];
  List<EmergencyContact> _emergencyContacts = [];
  List<SafetyTip> _safetyTips = [];
  Map<String, dynamic>? _verificationStatus;
  Map<String, dynamic>? _trustScore;
  bool _isLoading = false;
  String? _error;

  SafetyProvider({required SafetyService safetyService}) : _safetyService = safetyService;

  // Getters
  SafetyPreferences get preferences => _preferences;
  List<BlockedUser> get blockedUsers => _blockedUsers;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  List<SafetyTip> get safetyTips => _safetyTips;
  Map<String, dynamic>? get verificationStatus => _verificationStatus;
  Map<String, dynamic>? get trustScore => _trustScore;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all safety data
  Future<void> loadSafetyData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadBlockedUsers(),
        _loadEmergencyContacts(),
        _loadSafetyTips(),
        _loadVerificationStatus(),
        _loadTrustScore(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBlockedUsers() async {
    _blockedUsers = await _safetyService.getBlockedUsers();
  }

  Future<void> _loadEmergencyContacts() async {
    _emergencyContacts = await _safetyService.getEmergencyContacts();
  }

  Future<void> _loadSafetyTips() async {
    _safetyTips = await _safetyService.getSafetyTips();
  }

  Future<void> _loadVerificationStatus() async {
    _verificationStatus = await _safetyService.getVerificationStatus();
  }

  Future<void> _loadTrustScore() async {
    _trustScore = await _safetyService.getTrustScore();
  }

  // Block a user
  Future<bool> blockUser(String userId, String? reason) async {
    final result = await _safetyService.blockUser(userId, reason);
    if (result) {
      await _loadBlockedUsers();
      notifyListeners();
    }
    return result;
  }

  // Unblock a user
  Future<bool> unblockUser(String userId) async {
    final result = await _safetyService.unblockUser(userId);
    if (result) {
      await _loadBlockedUsers();
      notifyListeners();
    }
    return result;
  }

  // Add emergency contact
  Future<bool> addEmergencyContact({required String name, required String phoneNumber}) async {
    final result = await _safetyService.addEmergencyContact(name: name, phoneNumber: phoneNumber);
    if (result) {
      await _loadEmergencyContacts();
      notifyListeners();
    }
    return result;
  }

  // Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    final result = await _safetyService.removeEmergencyContact(contactId);
    if (result) {
      await _loadEmergencyContacts();
      notifyListeners();
    }
    return result;
  }

  // Share live location
  Future<bool> shareLiveLocation({required String contactId, required int durationMinutes}) async {
    return _safetyService.shareLiveLocation(contactId: contactId, durationMinutes: durationMinutes);
  }

  // Update preferences
  void updateVideoVerification(bool value) {
    _preferences = SafetyPreferences(
      allowVideoVerification: value,
      requireVideoVerification: _preferences.requireVideoVerification,
      enableLocationSharing: _preferences.enableLocationSharing,
      shareLocationWithEmergencyContacts: _preferences.shareLocationWithEmergencyContacts,
      enableBackgroundCheck: _preferences.enableBackgroundCheck,
      enableFacialRecognition: _preferences.enableFacialRecognition,
      blockScreenshots: _preferences.blockScreenshots,
      disableScreenshare: _preferences.disableScreenshare,
      blockedUsers: _preferences.blockedUsers,
      emergencyContacts: _preferences.emergencyContacts,
    );
    notifyListeners();
  }

  void updateLocationSharing(bool value) {
    _preferences = SafetyPreferences(
      allowVideoVerification: _preferences.allowVideoVerification,
      requireVideoVerification: _preferences.requireVideoVerification,
      enableLocationSharing: value,
      shareLocationWithEmergencyContacts: _preferences.shareLocationWithEmergencyContacts,
      enableBackgroundCheck: _preferences.enableBackgroundCheck,
      enableFacialRecognition: _preferences.enableFacialRecognition,
      blockScreenshots: _preferences.blockScreenshots,
      disableScreenshare: _preferences.disableScreenshare,
      blockedUsers: _preferences.blockedUsers,
      emergencyContacts: _preferences.emergencyContacts,
    );
    notifyListeners();
  }

  void updateScreenProtection(bool blockScreenshots, bool disableScreenshare) {
    _preferences = SafetyPreferences(
      allowVideoVerification: _preferences.allowVideoVerification,
      requireVideoVerification: _preferences.requireVideoVerification,
      enableLocationSharing: _preferences.enableLocationSharing,
      shareLocationWithEmergencyContacts: _preferences.shareLocationWithEmergencyContacts,
      enableBackgroundCheck: _preferences.enableBackgroundCheck,
      enableFacialRecognition: _preferences.enableFacialRecognition,
      blockScreenshots: blockScreenshots,
      disableScreenshare: disableScreenshare,
      blockedUsers: _preferences.blockedUsers,
      emergencyContacts: _preferences.emergencyContacts,
    );
    notifyListeners();
  }
}
