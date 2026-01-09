import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './analytics_service.dart';

/// Comprehensive payment service supporting 12 payment methods
class PaymentService {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  // Original payment methods
  static const String PAYMENT_METHOD_CARD = 'card';
  static const String PAYMENT_METHOD_EFT = 'eft';
  static const String PAYMENT_METHOD_SNAPSCAN = 'snapscan';
  static const String PAYMENT_METHOD_CAPITEC = 'capitec';
  static const String PAYMENT_METHOD_TAKEALOT = 'takealot';
  static const String PAYMENT_METHOD_PAYPAL = 'paypal';
  static const String PAYMENT_METHOD_CRYPTO = 'crypto';
  
  // NEW: BNPL & Alternative payment methods
  static const String PAYMENT_METHOD_PAYSHAP = 'payshap';
  static const String PAYMENT_METHOD_ZAPPER = 'zapper';
  static const String PAYMENT_METHOD_PAYFLEX = 'payflex';
  static const String PAYMENT_METHOD_PAYFAST = 'payfast';
  
  // Stripe integration
  static const String STRIPE_ENDPOINT = '/payments/stripe';
  
  // Luno (Crypto) integration
  static const String LUNO_ENDPOINT = '/payments/luno';
  
  // Yoco integration
  static const String YOCO_ENDPOINT = '/payments/yoco';
  
  // Payfast integration
  static const String PAYFAST_ENDPOINT = '/payments/payfast';
  
  // Ozow integration
  static const String OZOW_ENDPOINT = '/payments/ozow';

  /// Create a subscription with Stripe
  static Future<Map<String, dynamic>?> createStripeSubscription({
    required String tierId,
    required String billingCycle,
    required double amount,
  }) async {
    try {
      AnalyticsService.logEvent('stripe_subscription_initiated', {
        'tier_id': tierId,
        'billing_cycle': billingCycle,
        'amount': amount,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl$STRIPE_ENDPOINT/subscribe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tierId': tierId,
          'billingCycle': billingCycle,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('stripe_subscription_created', {
          'subscription_id': data['subscriptionId'],
          'tier_id': tierId,
        });
        return data;
      }

      AnalyticsService.logEvent('stripe_subscription_failed', {
        'error': response.body,
      });
      return null;
    } catch (e) {
      AnalyticsService.logEvent('stripe_subscription_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create EFT transfer for South African users
  static Future<Map<String, dynamic>?> createEFTTransfer({
    required String bankAccountId,
    required double amount,
    required String tierId,
  }) async {
    try {
      AnalyticsService.logEvent('eft_transfer_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/eft/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bankAccountId': bankAccountId,
          'amount': amount,
          'tierId': tierId,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('eft_transfer_created', {
          'reference': data['reference'],
          'status': data['status'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('eft_transfer_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create SnapScan payment (instant bank transfer)
  static Future<Map<String, dynamic>?> createSnapScanPayment({
    required double amount,
    required String tierId,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('snapscan_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl$SNAPSCAN_ENDPOINT/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('snapscan_payment_created', {
          'transaction_id': data['transactionId'],
          'qr_code': data['qrCode'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('snapscan_payment_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create Capitec payment (app-to-app transfer)
  static Future<Map<String, dynamic>?> createCapitecPayment({
    required double amount,
    required String tierId,
  }) async {
    try {
      AnalyticsService.logEvent('capitec_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl$CAPITEC_ENDPOINT/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('capitec_payment_created', {
          'reference': data['reference'],
          'deeplink': data['deeplink'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('capitec_payment_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create Takealot Checkout payment
  static Future<Map<String, dynamic>?> createTakealotCheckout({
    required double amount,
    required String tierId,
  }) async {
    try {
      AnalyticsService.logEvent('takealot_checkout_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/takealot/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('takealot_checkout_created', {
          'checkout_token': data['checkoutToken'],
          'redirect_url': data['redirectUrl'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('takealot_checkout_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create PayShap payment plan (Buy Now Pay Later)
  static Future<Map<String, dynamic>?> createPayShapPlan({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('payshap_plan_creation_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/payshap/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payshap_plan_created', {
          'plan_id': data['planId'],
          'installments': data['numberOfInstallments'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('payshap_plan_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create Zapper payment request (Instant EFT)
  static Future<Map<String, dynamic>?> createZapperPayment({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      AnalyticsService.logEvent('zapper_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/zapper/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('zapper_payment_created', {
          'request_id': data['requestId'],
          'redirect_url': data['redirectUrl'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('zapper_payment_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create PayFlex payment plan (Buy Now Pay Later)
  static Future<Map<String, dynamic>?> createPayFlexPlan({
    required double amount,
    required String tierId,
    required String email,
    required String phoneNumber,
    required int numberOfInstallments,
  }) async {
    try {
      AnalyticsService.logEvent('payflex_plan_initiated', {
        'amount': amount,
        'tier_id': tierId,
        'installments': numberOfInstallments,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/payflex/plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'phoneNumber': phoneNumber,
          'numberOfInstallments': numberOfInstallments,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payflex_plan_created', {
          'plan_id': data['planId'],
          'installments': numberOfInstallments,
          'amount_per_installment': data['amountPerInstallment'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('payflex_plan_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Create PayFast payment
  static Future<Map<String, dynamic>?> createPayFastPayment({
    required double amount,
    required String tierId,
    required String email,
    required String itemName,
  }) async {
    try {
      AnalyticsService.logEvent('payfast_payment_initiated', {
        'amount': amount,
        'tier_id': tierId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/payfast/charge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'tierId': tierId,
          'email': email,
          'itemName': itemName,
          'description': 'Meengle Premium Subscription',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('payfast_payment_created', {
          'payment_id': data['paymentId'],
          'redirect_url': data['redirectUrl'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('payfast_payment_error', {
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Process boost purchase with selected payment method
  static Future<bool> purchaseBoost({
    required String boostId,
    required double price,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      AnalyticsService.logEvent('boost_purchase_initiated', {
        'boost_id': boostId,
        'price': price,
        'payment_method': paymentMethod,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/boosts/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'boostId': boostId,
          'price': price,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AnalyticsService.logEvent('boost_purchase_successful', {
          'boost_id': boostId,
          'payment_method': paymentMethod,
        });
        return true;
      }

      AnalyticsService.logEvent('boost_purchase_failed', {
        'error': response.body,
      });
      return false;
    } catch (e) {
      AnalyticsService.logEvent('boost_purchase_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Verify payment status
  static Future<Map<String, dynamic>?> verifyPaymentStatus({
    required String transactionId,
    required String paymentMethod,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/verify/$transactionId?method=$paymentMethod'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error verifying payment: $e');
      return null;
    }
  }

  /// Get payment methods available for user's country
  static Future<List<Map<String, dynamic>>?> getAvailablePaymentMethods({
    required String countryCode,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/methods?country=$countryCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['methods']);
      }

      return null;
    } catch (e) {
      print('Error getting payment methods: $e');
      return null;
    }
  }

  /// Get exchange rate for cryptocurrency
  static Future<Map<String, dynamic>?> getCryptoExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/exchange-rate?from=$fromCurrency&to=$toCurrency'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('Error getting exchange rate: $e');
      return null;
    }
  }

  /// Cancel subscription
  static Future<bool> cancelSubscription({
    required String subscriptionId,
  }) async {
    try {
      AnalyticsService.logEvent('subscription_cancellation_initiated', {
        'subscription_id': subscriptionId,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/tiers/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
        }),
      );

      if (response.statusCode == 200) {
        AnalyticsService.logEvent('subscription_cancelled', {
          'subscription_id': subscriptionId,
        });
        return true;
      }

      return false;
    } catch (e) {
      AnalyticsService.logEvent('subscription_cancellation_error', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Create 7-day free trial
  static Future<Map<String, dynamic>?> createFreeTrial({
    required String tier,
    required int durationDays,
  }) async {
    try {
      AnalyticsService.logEvent('free_trial_creation_initiated', {
        'tier': tier,
        'duration_days': durationDays,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/tiers/trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tier': tier,
          'durationDays': durationDays,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AnalyticsService.logEvent('free_trial_created', {
          'tier': tier,
          'expires_at': data['expiresAt'],
        });
        return data;
      }

      return null;
    } catch (e) {
      AnalyticsService.logEvent('free_trial_error', {
        'error': e.toString(),
      });
      return null;
    }
  }
}
