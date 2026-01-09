import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for two-factor authentication
class TwoFactorAuthService {
  final String baseUrl;
  String? _authToken;

  TwoFactorAuthService({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Enable SMS 2FA
  Future<bool> enableSmsMFA(String userId, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/2fa/sms/enable'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[2FAService] SMS 2FA enabled');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[2FAService] Enable SMS error: $e');
      return false;
    }
  }

  /// Enable Email 2FA
  Future<bool> enableEmailMFA(String userId, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/2fa/email/enable'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[2FAService] Email 2FA enabled');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[2FAService] Enable email error: $e');
      return false;
    }
  }

  /// Enable Authenticator App 2FA
  Future<Map<String, dynamic>?> enableAuthenticatorMFA(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/2fa/authenticator/enable'),
        headers: _headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[2FAService] Authenticator 2FA enabled');
        return data; // Contains QR code and secret
      }
      return null;
    } catch (e) {
      debugPrint('[2FAService] Enable authenticator error: $e');
      return null;
    }
  }

  /// Verify 2FA code
  Future<bool> verify2FACode(String userId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/2fa/verify'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[2FAService] 2FA code verified');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[2FAService] Verify error: $e');
      return false;
    }
  }

  /// Disable 2FA
  Future<bool> disable2FA(String userId, String method) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/2fa/disable'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'method': method, // 'sms', 'email', 'authenticator'
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[2FAService] 2FA disabled');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[2FAService] Disable error: $e');
      return false;
    }
  }

  /// Get 2FA settings
  Future<Map<String, dynamic>?> get2FASettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/2fa/settings/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[2FAService] Get settings error: $e');
      return null;
    }
  }
}
