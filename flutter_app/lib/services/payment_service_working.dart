import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String stripePublishableKey = 'pk_test_YOUR_TEST_KEY';
  static const String backendURL = 'http://localhost:3001/api';

  static Future<void> initialize() async {
    Stripe.publishableKey = stripePublishableKey;
  }

  static Future<bool> upgradeToTier(String tier, String email) async {
    try {
      // Create payment intent on backend
      final intentResponse = await http.post(
        Uri.parse('$backendURL/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'tier': tier,
          'amount': _getTierPrice(tier),
        }),
      );

      if (intentResponse.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final intentData = jsonDecode(intentResponse.body);
      final clientSecret = intentData['clientSecret'];

      // Present Stripe payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Confirm payment on backend
      final confirmResponse = await http.post(
        Uri.parse('$backendURL/payments/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'tier': tier,
        }),
      );

      if (confirmResponse.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }

  static int _getTierPrice(String tier) {
    switch (tier) {
      case 'spark':
        return 499; // $4.99
      case 'flame':
        return 999; // $9.99
      case 'wildfire':
        return 1999; // $19.99
      default:
        return 0;
    }
  }

  static String getTierDescription(String tier) {
    switch (tier) {
      case 'spark':
        return 'Spark+ - \$4.99/month\nSee who likes you\nAdvanced filters';
      case 'flame':
        return 'Flame - \$9.99/month\nUnlimited likes\nTravel mode\nRead receipts';
      case 'wildfire':
        return 'Wildfire - \$19.99/month\nVIP concierge\nAdvanced analytics\nExclusive events';
      default:
        return '';
    }
  }
}
