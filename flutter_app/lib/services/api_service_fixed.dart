import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  ApiService({required this.baseUrl});

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _refreshToken = await _storage.read(key: 'refreshToken');
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      await _storage.write(key: 'accessToken', value: _accessToken!);
    } else {
      await clearTokens();
      throw Exception('Token refresh failed');
    }
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _saveTokens(accessToken, refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    _accessToken = null;
    _refreshToken = null;
  }

  Future<bool> hasValidToken() async {
    await _loadTokens();
    return _accessToken != null && _refreshToken != null;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    await _loadTokens();

    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      try {
        await _refreshAccessToken();
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        await clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    await _loadTokens();

    var response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      try {
        await _refreshAccessToken();
        response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      } catch (e) {
        await clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    await _loadTokens();

    var response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      try {
        await _refreshAccessToken();
        response = await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      } catch (e) {
        await clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _loadTokens();

    var response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      try {
        await _refreshAccessToken();
        response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        await clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }

    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
