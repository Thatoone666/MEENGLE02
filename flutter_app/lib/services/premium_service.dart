import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'dart:convert';

class PremiumService {
  static const _key = 'is_premium';

  /// Check whether the current user is premium (local cache)
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark the user as premium locally
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Start a Stripe purchase flow. Returns the parsed Stripe response map.
  /// Caller is responsible for navigating to a WebView or Stripe SDK with the response.
  static Future<Map<String, dynamic>> purchaseSubscriptionViaStripe(
      String amount, String email) async {
    final resp = await ApiService.createStripePayment(
        amount, 'Premium Subscription', email);
    return resp;
  }

  // --- Backend-powered premium API wrappers ---

  /// Trigger an immediate boost for the current user.
  /// Returns true on success.
  static Future<bool> boostNow() async {
    final token = await ApiService.getToken();
    final url = Uri.parse('${ApiService.baseUrl}/api/profile/boost');
    final res = await ApiService.client.post(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return res.statusCode == 200;
  }

  /// Set a profile theme (diamond-only on server).
  static Future<bool> setTheme(String theme) async {
    final token = await ApiService.getToken();
    final url = Uri.parse('${ApiService.baseUrl}/api/profile/theme');
    final res = await ApiService.client.post(url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'theme': theme}));
    return res.statusCode == 200;
  }

  /// Send an instant-match request to a specific user id.
  static Future<bool> instantMatch(String targetId) async {
    final token = await ApiService.getToken();
    final url =
        Uri.parse('${ApiService.baseUrl}/api/profile/instant-match/$targetId');
    final res = await ApiService.client.post(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return res.statusCode == 200;
  }

  /// Perform an advanced search on the server. Returns list of user maps or null on failure.
  static Future<List<dynamic>?> advancedSearch(
      Map<String, dynamic> filters) async {
    final token = await ApiService.getToken();
    final url = Uri.parse('${ApiService.baseUrl}/api/profile/advanced-search');
    final res = await ApiService.client.post(url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(filters));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return null;
  }

  /// Query flash event details for a location.
  static Future<Map<String, dynamic>?> flashEvent(String locationName) async {
    final token = await ApiService.getToken();
    final url = Uri.parse(
        '${ApiService.baseUrl}/api/profile/flash-event/$locationName');
    final res = await ApiService.client.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Send a wingman request to another user.
  static Future<bool> sendWingmanRequest(String targetId) async {
    final token = await ApiService.getToken();
    final url = Uri.parse(
        '${ApiService.baseUrl}/api/profile/wingman/request/$targetId');
    final res = await ApiService.client.post(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return res.statusCode == 200;
  }
}
