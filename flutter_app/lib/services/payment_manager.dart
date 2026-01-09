import 'package:flutter/foundation.dart';
import 'payment/payfast_service.dart';
import 'payment/ozow_service.dart';
import 'fraud_detection_service.dart';
import 'analytics/analytics.dart';
import '../models/subscription_model.dart';
import 'subscription_service.dart';

class PaymentException implements Exception {
  final String message;
  final dynamic details;

  PaymentException(this.message, [this.details]);

  @override
  String toString() => 'PaymentException: $message';
}

enum PaymentProviderMethod {
  payfast,
  ozow,
  creditCard;

  String get displayName {
    switch (this) {
      case PaymentProviderMethod.payfast:
        return 'PayFast';
      case PaymentProviderMethod.ozow:
        return 'Instant EFT (Ozow)';
      case PaymentProviderMethod.creditCard:
        return 'Credit Card';
    }
  }

  String get description {
    switch (this) {
      case PaymentProviderMethod.payfast:
        return 'Pay securely with credit card, debit card, or instant EFT';
      case PaymentProviderMethod.ozow:
        return 'Pay directly from your bank account';
      case PaymentProviderMethod.creditCard:
        return 'Pay with Visa, Mastercard, or American Express';
    }
  }
}

// SubscriptionTier and Subscription model now live in models/subscription_model.dart

class PaymentManager extends ChangeNotifier {
  final SubscriptionTier _currentTier;
  final String _userId;
  bool _isLoading = false;

  PaymentManager({
    PayFastService? payfastService,
    OzowService? ozowService,
    FraudDetectionService? fraudService,
    SubscriptionService? subscriptionService,
    Analytics? analytics,
    SubscriptionTier initialTier = SubscriptionTier.free,
    String userId = '',
  })  : _payfastService = payfastService ?? PayFastService(),
        _ozowService = ozowService ?? OzowService(),
        _fraudService = fraudService ?? FraudDetectionService(),
        _subscriptionService = subscriptionService ?? SubscriptionService(),
        _analytics = analytics ?? Analytics(),
        _currentTier = initialTier,
        _userId = userId;

  final PayFastService _payfastService;
  final OzowService _ozowService;
  final FraudDetectionService _fraudService;
  final SubscriptionService _subscriptionService;
  final Analytics _analytics;

  Subscription? _currentSubscription;
  Subscription? get currentSubscription => _currentSubscription;

  SubscriptionTier get currentTier => _currentTier;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _currentTier != SubscriptionTier.free;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Map<String, String>> createPaymentRequest({
    required PaymentProviderMethod method,
    required SubscriptionTier tier,
    required String transactionId,
    required String returnUrl,
    required String cancelUrl,
    required String notifyUrl,
    String? email,
    String? firstName,
    String? lastName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);

      // Assess fraud risk before processing payment
      if (_userId.isNotEmpty) {
        final assessment = await _fraudService.assessTransaction(
          userId: _userId,
          transactionId: transactionId,
          amount: tier.priceInRand,
          paymentMethod: method.name,
          ipAddress: await _getClientIp(),
          metadata: {
            'tier': tier.name,
            'previousTier': _currentTier.name,
            ...?metadata,
          },
        );

        if (assessment.shouldBlock) {
          _analytics.logBlockedTransaction(
            transactionId: transactionId,
            riskAssessment: assessment,
          );
          throw PaymentException(
            'Transaction blocked: ${assessment.flags.join(", ")}',
            assessment,
          );
        }

        if (assessment.riskLevel != RiskLevel.low) {
          _analytics.logSuspiciousTransaction(
            transactionId: transactionId,
            riskAssessment: assessment,
          );
        }
      }

      final amount = tier.priceInRand.toStringAsFixed(2);
      final itemName = '${tier.displayName} Subscription';

      switch (method) {
        case PaymentProviderMethod.payfast:
          return _payfastService.createPaymentRequest(
            amount: amount,
            itemName: itemName,
            returnUrl: returnUrl,
            cancelUrl: cancelUrl,
            notifyUrl: notifyUrl,
            email: email,
            firstName: firstName,
            lastName: lastName,
          );
        
        case PaymentProviderMethod.ozow:
          return _ozowService.createPaymentRequest(
            amount: amount,
            transactionReference: transactionId,
            successUrl: returnUrl,
            cancelUrl: cancelUrl,
            notifyUrl: notifyUrl,
            bankReference: itemName,
            email: email,
          );
        
        case PaymentProviderMethod.creditCard:
          // Credit card payments are handled through PayFast
          return _payfastService.createPaymentRequest(
            amount: amount,
            itemName: itemName,
            returnUrl: returnUrl,
            cancelUrl: cancelUrl,
            notifyUrl: notifyUrl,
            email: email,
            firstName: firstName,
            lastName: lastName,
            customFields: {'payment_method': 'cc'},
          );
      }
    } catch (e) {
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPayment({
    required PaymentProviderMethod method,
    required Map<String, String> notificationData,
    required SubscriptionTier tier,
  }) async {
    try {
      _setLoading(true);
      bool isValid = false;

      switch (method) {
        case PaymentProviderMethod.payfast:
        case PaymentProviderMethod.creditCard:
          isValid = await _payfastService.verifyNotification(
            notificationData,
            notificationData['signature'] ?? '',
          );
          break;
        
        case PaymentProviderMethod.ozow:
          isValid = await _ozowService.verifyNotification(notificationData);
          break;
      }

      if (isValid) {
        final transactionId = notificationData['transaction_id'] ?? '';
        final amount = double.tryParse(notificationData['amount'] ?? '0') ?? 0.0;

        // Log successful payment
        _analytics.logPaymentSuccess(
          transactionId: transactionId,
          method: method.name,
          amount: amount,
        );

        // Create subscription
        await _createSubscription(
          transactionId: transactionId,
          tier: tier,
          method: method,
          amount: amount,
        );
      }

      return isValid;
    } catch (e) {
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  bool canUseFeature(String feature) {
    return _currentTier.features[feature] ?? false;
  }

  int getRemainingFeatureCount(String feature) {
    final value = _currentTier.features[feature];
    if (value == null) return 0;
    if (value == double.infinity) return 999999;
    return value as int;
  }

  Future<String> _getClientIp() async {
    try {
      if (kIsWeb) {
        // For web, try to get IP from a service
        final response = await _payfastService.getClientIp();
        return response['ip'] ?? 'unknown';
      }
      return 'localhost';
    } catch (e) {
      return 'unknown';
    }
  }

  Future<void> loadCurrentSubscription() async {
    if (_userId.isEmpty) return;

    try {
      _setLoading(true);
      _currentSubscription = await _subscriptionService.getCurrentSubscription(_userId);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Subscription>> getSubscriptionHistory() async {
    if (_userId.isEmpty) return [];
    return _subscriptionService.getSubscriptionHistory(_userId);
  }

  Future<Map<String, dynamic>> getSubscriptionMetrics() async {
    if (_currentSubscription == null) return {};
    return _subscriptionService.getUsageMetrics(_currentSubscription!.id);
  }

  Future<bool> cancelCurrentSubscription() async {
    if (_currentSubscription == null) return false;

    try {
      _setLoading(true);
      final success = await _subscriptionService.cancelSubscription(_currentSubscription!.id);
      
      if (success) {
        _analytics.logSubscriptionCancelled(
          subscriptionId: _currentSubscription!.id,
          reason: 'user_initiated',
        );
        await loadCurrentSubscription(); // Reload to get updated status
      }

      return success;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> shouldShowRenewalPrompt() async {
    if (_currentSubscription == null) return false;
    if (!_currentSubscription!.isActive) return true;
    return _currentSubscription!.isExpiringSoon;
  }

  Future<void> _createSubscription({
    required String transactionId,
    required SubscriptionTier tier,
    required PaymentProviderMethod method,
    required double amount,
  }) async {
    if (_userId.isEmpty) return;

    try {
      final subscription = await _subscriptionService.createSubscription(
        userId: _userId,
        tier: tier,
        paymentMethod: method.name,
        amount: amount,
        transactionId: transactionId,
        metadata: {
          'previousTier': _currentTier.name,
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      _currentSubscription = subscription;
      _analytics.logSubscriptionCreated(
        subscriptionId: subscription.id,
        tier: tier.name,
        amount: amount,
      );

      notifyListeners();
    } catch (e) {
      _analytics.logSubscriptionError(
        error: e.toString(),
        transactionId: transactionId,
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
}
