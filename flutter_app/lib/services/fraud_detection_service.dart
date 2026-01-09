import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../web/web_utils_export.dart';

enum RiskLevel {
  low,
  medium,
  high;

  String get description {
    switch (this) {
      case RiskLevel.low:
        return 'Transaction appears normal';
      case RiskLevel.medium:
        return 'Some suspicious patterns detected';
      case RiskLevel.high:
        return 'High risk transaction detected';
    }
  }
}

class FraudDetectionService {
  static const String _apiUrl = String.fromEnvironment(
    'FRAUD_API_URL',
    defaultValue: 'https://api.meengle.com/fraud',
  );

  final http.Client _client;

  FraudDetectionService({http.Client? client})
      : _client = client ?? http.Client();

  Future<RiskAssessment> assessTransaction({
    required String userId,
    required String transactionId,
    required double amount,
    required String paymentMethod,
    required String ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'userId': userId,
        'transactionId': transactionId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'ipAddress': ipAddress,
        'timestamp': DateTime.now().toIso8601String(),
        if (metadata != null) ...metadata,
      };

      final response = await _client.post(
        Uri.parse('$_apiUrl/assess'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return RiskAssessment.fromJson(result);
      } else {
        throw Exception('Failed to assess transaction: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<bool> reportFraudulentTransaction({
    required String transactionId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transactionId': transactionId,
          'reason': reason,
          if (description != null) 'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      return false;
    }
  }

  Future<List<FraudPattern>> getKnownPatterns() async {
    try {
      final response = await _client.get(Uri.parse('$_apiUrl/patterns'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => FraudPattern.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get fraud patterns: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

class RiskAssessment {
  final RiskLevel riskLevel;
  final List<String> flags;
  final Map<String, dynamic> details;
  final bool shouldBlock;

  RiskAssessment({
    required this.riskLevel,
    required this.flags,
    required this.details,
    required this.shouldBlock,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      flags: List<String>.from(json['flags'] ?? []),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      shouldBlock: json['shouldBlock'] ?? false,
    );
  }
}

class FraudPattern {
  final String id;
  final String pattern;
  final String description;
  final RiskLevel riskLevel;
  final List<String> indicators;

  FraudPattern({
    required this.id,
    required this.pattern,
    required this.description,
    required this.riskLevel,
    required this.indicators,
  });

  factory FraudPattern.fromJson(Map<String, dynamic> json) {
    return FraudPattern(
      id: json['id'],
      pattern: json['pattern'],
      description: json['description'],
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      indicators: List<String>.from(json['indicators'] ?? []),
    );
  }
}