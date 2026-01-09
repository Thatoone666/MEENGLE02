abstract class PaymentProvider {
  Future<Map<String, dynamic>> createPayment({
    required String amount,
    required String currency,
    required String customerId,
    String? description,
  });

  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String planId,
  });

  Future<void> cancelSubscription(String subscriptionId);
}

class PaymentException implements Exception {
  final String message;
  final String? details;

  PaymentException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

class PaymentConfiguration {
  final String merchantId;
  final String merchantKey;
  final String passphrase;
  final bool isSandbox;
  final String returnUrl;
  final String cancelUrl;
  final String notifyUrl;

  PaymentConfiguration({
    required this.merchantId,
    required this.merchantKey,
    required this.passphrase,
    this.isSandbox = false,
    String? returnUrl,
    String? cancelUrl,
    String? notifyUrl,
  })  : returnUrl = returnUrl ?? const String.fromEnvironment('PAYMENT_RETURN_URL'),
        cancelUrl = cancelUrl ?? const String.fromEnvironment('PAYMENT_CANCEL_URL'),
        notifyUrl = notifyUrl ?? const String.fromEnvironment('PAYMENT_NOTIFY_URL');
}