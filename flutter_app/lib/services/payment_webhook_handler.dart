import 'package:flutter/foundation.dart';
import './payment_analytics.dart';
import '../web/web_utils.dart';

class PaymentWebhookHandler {
  final PaymentAnalytics _analytics;
  final void Function(Map<String, dynamic> data)? onPaymentSuccess;
  final void Function(Map<String, dynamic> data)? onPaymentFailure;
  final void Function(Map<String, dynamic> data)? onSubscriptionUpdated;

  PaymentWebhookHandler({
    PaymentAnalytics? analytics,
    this.onPaymentSuccess,
    this.onPaymentFailure,
    this.onSubscriptionUpdated,
  }) : _analytics = analytics ?? PaymentAnalytics();

  Future<void> handlePayFastWebhook(
    Map<String, String> data,
    String signature,
  ) async {
    try {
      final eventType = data['payment_status']?.toLowerCase();
      final amount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
      final userId = data['custom_str1'] ?? '';

      switch (eventType) {
        case 'complete':
          await _analytics.trackPaymentEvent(
            eventName: 'payment_success',
            userId: userId,
            paymentMethod: 'payfast',
            amount: amount,
            metadata: {
              'transactionId': data['pf_payment_id'],
              'paymentStatus': eventType,
            },
          );
          onPaymentSuccess?.call(Map<String, dynamic>.from(data));
          break;

        case 'failed':
        case 'cancelled':
          await _analytics.trackPaymentEvent(
            eventName: 'payment_failed',
            userId: userId,
            paymentMethod: 'payfast',
            amount: amount,
            metadata: {
              'transactionId': data['pf_payment_id'],
              'paymentStatus': eventType,
              'failureReason': data['reason'] ?? 'Unknown',
            },
          );
          onPaymentFailure?.call(Map<String, dynamic>.from(data));
          break;

        case 'subscription_cancelled':
        case 'subscription_paused':
          await _analytics.trackPaymentEvent(
            eventName: 'subscription_updated',
            userId: userId,
            paymentMethod: 'payfast',
            amount: amount,
            metadata: {
              'subscriptionId': data['subscription_id'],
              'status': eventType,
            },
          );
          onSubscriptionUpdated?.call(Map<String, dynamic>.from(data));
          break;
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      debugPrint('Error handling PayFast webhook: $e');
    }
  }

  Future<void> handleOzowWebhook(Map<String, dynamic> data) async {
    try {
      final status = data['Status']?.toString().toLowerCase();
      final amount = double.tryParse(data['Amount']?.toString() ?? '0') ?? 0.0;
      final userId = data['Customer']?.toString() ?? '';

      switch (status) {
        case 'complete':
          await _analytics.trackPaymentEvent(
            eventName: 'payment_success',
            userId: userId,
            paymentMethod: 'ozow',
            amount: amount,
            metadata: {
              'transactionId': data['TransactionId'],
              'paymentStatus': status,
            },
          );
          onPaymentSuccess?.call(data);
          break;

        case 'failed':
        case 'cancelled':
          await _analytics.trackPaymentEvent(
            eventName: 'payment_failed',
            userId: userId,
            paymentMethod: 'ozow',
            amount: amount,
            metadata: {
              'transactionId': data['TransactionId'],
              'paymentStatus': status,
              'failureReason': data['FailureReason'] ?? 'Unknown',
            },
          );
          onPaymentFailure?.call(data);
          break;
      }
    } catch (e) {
      if (kIsWeb) WebUtils.handleWebError(e, StackTrace.current);
      debugPrint('Error handling Ozow webhook: $e');
    }
  }

  void dispose() {
    _analytics.dispose();
  }
}