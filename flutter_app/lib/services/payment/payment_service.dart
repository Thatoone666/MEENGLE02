import 'package:flutter/foundation.dart';
import 'payment_provider.dart';
import 'payfast_provider.dart';
import 'ozow_provider.dart';

enum PaymentMethod {
  payfast,
  ozow;

  String get displayName {
    switch (this) {
      case PaymentMethod.payfast:
        return 'PayFast';
      case PaymentMethod.ozow:
        return 'Ozow';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.payfast:
        return 'Credit Card, Debit Card, Instant EFT';
      case PaymentMethod.ozow:
        return 'Instant EFT';
    }
  }

  String get logoAsset {
    switch (this) {
      case PaymentMethod.payfast:
        return 'assets/images/payfast_logo.png';
      case PaymentMethod.ozow:
        return 'assets/images/ozow_logo.png';
    }
  }
}

class PaymentService extends ChangeNotifier {
  final Map<PaymentMethod, PaymentProvider> _providers;
  PaymentMethod _selectedMethod;
  bool _isLoading = false;

  PaymentService({
    required PaymentConfiguration payfastConfig,
    required PaymentConfiguration ozowConfig,
    PaymentMethod defaultMethod = PaymentMethod.payfast,
  })  : _providers = {
          PaymentMethod.payfast: PayFastProvider(config: payfastConfig),
          PaymentMethod.ozow: OzowProvider(config: ozowConfig),
        },
        _selectedMethod = defaultMethod;

  PaymentMethod get selectedMethod => _selectedMethod;
  bool get isLoading => _isLoading;

  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<Map<String, dynamic>> processPayment({
    required String amount,
    required String customerId,
    String? description,
  }) async {
    try {
      _setLoading(true);
      final provider = _providers[_selectedMethod];
      if (provider == null) {
        throw PaymentException('Selected payment method not available');
      }

      return await provider.createPayment(
        amount: amount,
        currency: 'ZAR',
        customerId: customerId,
        description: description,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String planId,
  }) async {
    try {
      _setLoading(true);
      final provider = _providers[_selectedMethod];
      if (provider == null) {
        throw PaymentException('Selected payment method not available');
      }

      return await provider.createSubscription(
        customerId: customerId,
        planId: planId,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      _setLoading(true);
      final provider = _providers[_selectedMethod];
      if (provider == null) {
        throw PaymentException('Selected payment method not available');
      }

      await provider.cancelSubscription(subscriptionId);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var provider in _providers.values) {
      if (provider is PayFastProvider) provider.dispose();
      if (provider is OzowProvider) provider.dispose();
    }
    super.dispose();
  }
}

class PaymentException implements Exception {
  final String message;
  final String details;

  PaymentException(this.message, [this.details = '']);

  @override
  String toString() => 'PaymentException: $message${details.isNotEmpty ? '\nDetails: $details' : ''}';
}