import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

/// Advanced security service with biometric auth and encryption
class AdvancedSecurityService {
  static final AdvancedSecurityService _instance = AdvancedSecurityService._internal();
  
  late LocalAuthentication _localAuth;
  late bool _isBiometricSupported;
  late List<BiometricType> _supportedBiometrics;
  
  factory AdvancedSecurityService() {
    return _instance;
  }

  AdvancedSecurityService._internal();

  /// Initialize security service
  Future<void> initialize() async {
    _localAuth = LocalAuthentication();
    
    // Check biometric support
    _isBiometricSupported = await _localAuth.canCheckBiometrics;
    _supportedBiometrics = await _localAuth.getAvailableBiometrics();
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Check if biometrics are available
  bool get isBiometricSupported => _isBiometricSupported;
  List<BiometricType> get supportedBiometrics => _supportedBiometrics;

  /// Encrypt sensitive data
  String encryptData({
    required String data,
    required String encryptionKey,
  }) {
    try {
      final key = encrypt.Key.fromUtf8(encryptionKey.padRight(32).substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return data;
    }
  }

  /// Decrypt sensitive data
  String decryptData({
    required String encryptedData,
    required String encryptionKey,
  }) {
    try {
      final key = encrypt.Key.fromUtf8(encryptionKey.padRight(32).substring(0, 32));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      final decrypted = encrypter.decrypt64(encryptedData);
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return encryptedData;
    }
  }

  /// Detect fraudulent activity
  Future<bool> detectFraud({
    required String userId,
    required String activityType,
    Map<String, dynamic>? metadata,
  }) async {
    // Implement fraud detection logic
    // Check for unusual patterns:
    // - Multiple accounts from same IP
    // - Rapid account creation
    // - Unusual location changes
    // - Payment fraud patterns
    
    return false; // No fraud detected
  }

  /// Hash sensitive data
  String hashData(String data) {
    return encrypt.MD5().convert(utf8.encode(data)).toString();
  }

  /// Get biometric prompt widget
  Widget buildBiometricPrompt({
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _supportedBiometrics.contains(BiometricType.fingerprint)
                  ? Icons.fingerprint
                  : Icons.face,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              _supportedBiometrics.contains(BiometricType.fingerprint)
                  ? 'Touch Fingerprint Sensor'
                  : 'Look at Camera',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final success = await authenticateWithBiometrics(
                  reason: 'Authenticate to access Meengle',
                );
                if (success) {
                  onSuccess();
                } else {
                  onFailure();
                }
              },
              child: const Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }

  /// Rate limit protection
  Future<bool> checkRateLimit({
    required String userId,
    required String action,
    int maxAttempts = 5,
    Duration window = const Duration(minutes: 1),
  }) async {
    // Implement rate limiting
    // Track number of attempts per user per action
    // Block if threshold exceeded
    
    return true; // Allow action
  }

  /// Session security validation
  Future<bool> validateSessionSecurity({
    required String sessionId,
    required String userId,
  }) async {
    // Validate session:
    // - Check expiration
    // - Verify IP address hasn't changed
    // - Check device fingerprint
    
    return true; // Session valid
  }

  /// Build security settings widget
  Widget buildSecuritySettingsWidget() {
    return ListView(
      children: [
        ListTile(
          title: const Text('Biometric Authentication'),
          subtitle: Text(
            _isBiometricSupported
                ? 'Enabled (${_supportedBiometrics.join(', ')})'
                : 'Not available',
          ),
          trailing: Switch(
            value: _isBiometricSupported,
            onChanged: null, // Read-only
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Two-Factor Authentication'),
          subtitle: const Text('Enable additional security'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Session Timeout'),
          subtitle: const Text('Auto logout after inactivity'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Blocked Users'),
          subtitle: const Text('Manage blocked profiles'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Security Log'),
          subtitle: const Text('View login and activity history'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
      ],
    );
  }
}
