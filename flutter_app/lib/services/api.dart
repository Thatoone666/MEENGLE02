import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Api client abstraction so tests can substitute a fake client.
abstract class ApiClient {
  Future<http.Response> post(Uri uri,
      {Map<String, String>? headers, Object? body});
  Future<http.Response> get(Uri uri, {Map<String, String>? headers});
  Future<http.Response> put(Uri uri,
      {Map<String, String>? headers, Object? body});
  Future<http.Response> delete(Uri uri, {Map<String, String>? headers});
  Future<http.StreamedResponse> sendMultipart(http.MultipartRequest req);
}

/// Default HTTP implementation of [ApiClient].
class HttpApiClient implements ApiClient {
  final http.Client _inner;
  HttpApiClient([http.Client? client]) : _inner = client ?? http.Client();

  @override
  Future<http.Response> post(Uri uri,
          {Map<String, String>? headers, Object? body}) =>
      _inner.post(uri, headers: headers, body: body);

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _inner.get(uri, headers: headers);

  @override
  Future<http.Response> put(Uri uri,
          {Map<String, String>? headers, Object? body}) =>
      _inner.put(uri, headers: headers, body: body);

  @override
  Future<http.Response> delete(Uri uri, {Map<String, String>? headers}) =>
      _inner.delete(uri, headers: headers);

  @override
  Future<http.StreamedResponse> sendMultipart(http.MultipartRequest req) =>
      _inner.send(req);
}

/// High-level API facade used by the app. Methods are static for easy access
/// from widgets; during tests set `ApiService.client = FakeApiClient()`.
class ApiService {
  // Base URL (default points to Android emulator host for local backend)
  static String baseUrl = const String.fromEnvironment('API_BASE',
      defaultValue: 'http://10.0.2.2:3000/api');
  static const authKey = 'meengle_token';

  // Replaceable client for tests
  static ApiClient client = HttpApiClient();

  // --- Authentication ---
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final res = await client.post(url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] ?? body['accessToken'] ?? body['authToken'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(authKey, token.toString());
        return true;
      }
      return false;
    }
    return false;
  }

  static Future<bool> signUp(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final res = await client.post(url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final token = body['token'] ?? body['accessToken'] ?? body['authToken'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(authKey, token.toString());
        return true;
      }
      return false;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authKey);
  }

  // Internal token accessor (socket_service used _getToken in older code)
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authKey);
  }

  // Public token accessor
  static Future<String?> getToken() => _getToken();

  // --- Profile ---
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/profile');
    final res = await client.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    throw Exception('Failed to load profile: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> payload) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/profile');
    final res = await client.put(url, body: jsonEncode(payload), headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    throw Exception('Failed to update profile: ${res.statusCode} ${res.body}');
  }

  // --- Uploads ---
  static Future<String?> uploadFile(String filePath, String filename) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/upload');
    final req = http.MultipartRequest('POST', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('file', filePath,
        filename: filename));
    final streamed = await client.sendMultipart(req);
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['url']?.toString();
    }
    throw Exception('Upload failed: ${res.statusCode} ${res.body}');
  }

  // --- Payments ---
  static Future<Map<String, dynamic>> createStripePayment(
      String amount, String itemName, String email) async {
    final uri = Uri.parse('$baseUrl/stripe');
    final res = await client.post(uri,
        body: jsonEncode(
            {'amount': amount, 'item_name': itemName, 'email': email}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Stripe request failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> createPayFast(
      String amount, String itemName, String email) async {
    final uri = Uri.parse('$baseUrl/payfast');
    final res = await client.post(uri,
        body: jsonEncode(
            {'amount': amount, 'item_name': itemName, 'email': email}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('PayFast request failed: ${res.statusCode} ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> createPayPal(
      String amount, String itemName) async {
    final uri = Uri.parse('$baseUrl/paypal');
    final res = await client.post(uri,
        body: jsonEncode({'amount': amount, 'item_name': itemName}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('PayPal request failed: ${res.statusCode} ${res.body}');
  }

  // --- Misc ---
  static String resolveAssetUrl(String? url) {
    if (url == null) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }

  // --- Matches ---
  static Future<List<Map<String, dynamic>>> getPotentialMatches() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/matches/potential');
    final res = await client.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) return List<Map<String, dynamic>>.from(body);
      return [];
    }
    throw Exception('Failed to load potential matches: ${res.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getMatches() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/matches');
    final res = await client.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) return List<Map<String, dynamic>>.from(body);
      return [];
    }
    throw Exception('Failed to load matches: ${res.statusCode}');
  }

  static Future<bool> likeUser(String id, String context) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/matches/like/$id');
    final res = await client
        .post(url, body: jsonEncode({'context': context}), headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>> recordSwipe(
      String userId, bool liked, bool superLiked) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/matches/swipe/$userId');
    final res = await client.post(
      url,
      body: jsonEncode({
        'liked': liked,
        'superLiked': superLiked,
      }),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to record swipe: ${res.statusCode}');
  }
}
