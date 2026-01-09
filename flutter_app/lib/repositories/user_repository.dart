import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../models/user.dart';
import '../utils/logger.dart';

class UserRepository {
  static const String tokenKey = 'meengle_token';
  static final _logger = Logger();

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<void> persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<bool> authenticate(String email, String password) async {
    final success = await ApiService.login(email, password);
    if (success) {
      final token = await ApiService.getToken();
      if (token != null) {
        await persistToken(token);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final success = await ApiService.signUp(email, password);
    if (success) {
      // After registration, perform login to get the token
      return authenticate(email, password);
    }
    return false;
  }

  Future<User?> getProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (profile != null) {
        return User(
          id: profile['id'] ?? profile['_id'] ?? '',
          email: profile['email'] ?? '',
          displayName: profile['displayName'] ?? profile['name'],
        );
      }
    } catch (e) {
      // Log error but don't throw
      _logger.error('Error fetching profile', e);
    }
    return null;
  }
}
