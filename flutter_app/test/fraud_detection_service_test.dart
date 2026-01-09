import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meengle_flutter/services/fraud_detection_service.dart';

@GenerateMocks([http.Client])
import 'fraud_detection_service_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late FraudDetectionService fraudService;

  setUp(() {
    mockClient = MockClient();
    fraudService = FraudDetectionService(client: mockClient);
  });

  group('FraudDetectionService', () {
    test('assessTransaction returns RiskAssessment on success', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            '{"riskLevel": "low", "flags": [], "details": {}, "shouldBlock": false}',
            200,
          ));

      final assessment = await fraudService.assessTransaction(
        userId: 'user123',
        transactionId: 'tx123',
        amount: 100.0,
        paymentMethod: 'card',
        ipAddress: '127.0.0.1',
      );

      expect(assessment, isA<RiskAssessment>());
      expect(assessment.riskLevel, equals(RiskLevel.low));
      expect(assessment.flags, isEmpty);
      expect(assessment.shouldBlock, isFalse);
    });

    test('assessTransaction handles high risk scenarios', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            '''{
              "riskLevel": "high",
              "flags": ["suspicious_ip", "multiple_cards"],
              "details": {"attemptCount": 5},
              "shouldBlock": true
            }''',
            200,
          ));

      final assessment = await fraudService.assessTransaction(
        userId: 'user123',
        transactionId: 'tx123',
        amount: 1000.0,
        paymentMethod: 'card',
        ipAddress: '1.2.3.4',
      );

      expect(assessment.riskLevel, equals(RiskLevel.high));
      expect(assessment.flags, contains('suspicious_ip'));
      expect(assessment.details['attemptCount'], equals(5));
      expect(assessment.shouldBlock, isTrue);
    });

    test('reportFraudulentTransaction returns true on success', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 200));

      final result = await fraudService.reportFraudulentTransaction(
        transactionId: 'tx123',
        reason: 'stolen_card',
      );

      expect(result, isTrue);
    });

    test('getKnownPatterns returns list of patterns', () async {
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(
            '''[{
              "id": "pattern1",
              "pattern": "multiple_cards",
              "description": "Multiple cards used in short time",
              "riskLevel": "high",
              "indicators": ["rapid_attempts", "different_cards"]
            }]''',
            200,
          ));

      final patterns = await fraudService.getKnownPatterns();

      expect(patterns, hasLength(1));
      expect(patterns.first.id, equals('pattern1'));
      expect(patterns.first.riskLevel, equals(RiskLevel.high));
    });

    test('handles API errors gracefully', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Server error', 500));

      expect(
        () => fraudService.assessTransaction(
          userId: 'user123',
          transactionId: 'tx123',
          amount: 100.0,
          paymentMethod: 'card',
          ipAddress: '127.0.0.1',
        ),
        throwsException,
      );
    });
  });

  group('RiskLevel', () {
    test('provides meaningful descriptions', () {
      expect(RiskLevel.low.description, contains('normal'));
      expect(RiskLevel.medium.description, contains('suspicious'));
      expect(RiskLevel.high.description, contains('High risk'));
    });
  });
}