import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/payment/stripe_provider.dart';
import '../services/payment/yoco_provider.dart';
import '../services/payment/ozow_provider.dart';
import '../services/payment/snapscan_provider.dart';
import '../services/payment/luno_provider.dart';
import '../services/analytics_service.dart';

/// Payment method selection screen
/// Displays all available South African and international payment methods
class PaymentMethodSelectionScreen extends StatefulWidget {
  final double amount;
  final String tierId;
  final Function(String method) onMethodSelected;

  const PaymentMethodSelectionScreen({
    required this.amount,
    required this.tierId,
    required this.onMethodSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethodSelectionScreen> createState() =>
      _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState
    extends State<PaymentMethodSelectionScreen> {
  String? _selectedMethod;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('?? Payment Method'),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Amount summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount to Pay',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Select Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// South African Payment Methods
            const Text(
              '???? South African Methods',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// Yoco (Card & EFT)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'Yoco',
              subtitle: 'Card & Instant EFT',
              description: 'Credit/Debit cards & bank transfer',
              method: PaymentService.PAYMENT_METHOD_YOCO,
              badge: 'Popular',
            ),

            /// Ozow (Open Banking)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'Ozow',
              subtitle: 'Open Banking',
              description: 'Connect to any South African bank',
              method: PaymentService.PAYMENT_METHOD_OZOW,
              badge: 'Secure',
            ),

            /// SnapScan (Instant Transfer)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'SnapScan',
              subtitle: 'Instant Bank Transfer',
              description: 'Scan with your banking app',
              method: PaymentService.PAYMENT_METHOD_SNAPSCAN,
            ),

            /// Capitec (App-to-App)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'Capitec',
              subtitle: 'App Transfer',
              description: 'Direct app-to-app transfer',
              method: PaymentService.PAYMENT_METHOD_CAPITEC,
            ),

            /// Takealot (Checkout)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'Takealot Checkout',
              subtitle: 'Instant Checkout',
              description: 'Quick payment with Takealot',
              method: PaymentService.PAYMENT_METHOD_TAKEALOT,
            ),

            const SizedBox(height: 24),

            /// International Payment Methods
            const Text(
              '?? International Methods',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// Stripe (International Cards)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'Credit/Debit Card',
              subtitle: 'Stripe',
              description: 'Visa, Mastercard, American Express',
              method: PaymentService.PAYMENT_METHOD_CARD,
            ),

            /// PayPal
            _buildPaymentMethodCard(
              icon: '???',
              title: 'PayPal',
              subtitle: 'International Payments',
              description: 'PayPal account or guest checkout',
              method: PaymentService.PAYMENT_METHOD_PAYPAL,
            ),

            /// Bitcoin (Luno)
            _buildPaymentMethodCard(
              icon: '?',
              title: 'Bitcoin',
              subtitle: 'Luno',
              description: 'Pay with Bitcoin or Ethereum',
              method: PaymentService.PAYMENT_METHOD_CRYPTO,
              badge: 'New',
            ),

            const SizedBox(height: 24),

            /// Alternative Payment Methods (BNPL & Flexible)
            const Text(
              '?? Buy Now Pay Later',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// PayShap (BNPL)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'PayShap',
              subtitle: 'Payment Plans',
              description: 'Spread payments with zero interest',
              method: PaymentService.PAYMENT_METHOD_PAYSHAP,
              badge: 'New',
            ),

            /// PayFlex (Installments)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'PayFlex',
              subtitle: 'Flexible Installments',
              description: 'Pay in 3, 6, or 12 installments',
              method: PaymentService.PAYMENT_METHOD_PAYFLEX,
            ),

            /// Zapper (Instant EFT)
            _buildPaymentMethodCard(
              icon: '?',
              title: 'Zapper',
              subtitle: 'Instant EFT',
              description: 'Fastest bank transfer available',
              method: PaymentService.PAYMENT_METHOD_ZAPPER,
              badge: 'Fast',
            ),

            /// PayFast (All methods)
            _buildPaymentMethodCard(
              icon: '??',
              title: 'PayFast',
              subtitle: 'All Payment Methods',
              description: 'Cards, EFT, Zapper, SnapScan & more',
              method: PaymentService.PAYMENT_METHOD_PAYFAST,
              badge: 'Popular',
            ),

            const SizedBox(height: 24),

            /// Payment button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod != null && !_isLoading
                    ? _processPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text(
                        'Continue to Payment',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            /// Security info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'All payments are encrypted and secure. Your data is protected.',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment method card
  Widget _buildPaymentMethodCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required String method,
    String? badge,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = method);
        AnalyticsService.logEvent('payment_method_selected', {
          'method': method,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withAlpha(30)
              : Colors.grey[900],
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : Colors.grey[800]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),

            const SizedBox(width: 16),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (badge != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            /// Selection indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD4AF37),
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[600],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Process payment
  Future<void> _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() => _isLoading = true);

    try {
      AnalyticsService.logEvent('payment_processing_started', {
        'method': _selectedMethod,
        'amount': widget.amount,
      });

      // Route to appropriate payment processor
      switch (_selectedMethod) {
        case PaymentService.PAYMENT_METHOD_CARD:
          await StripePaymentProvider.initialize();
          break;
        case PaymentService.PAYMENT_METHOD_YOCO:
          // Yoco processing
          break;
        case PaymentService.PAYMENT_METHOD_OZOW:
          // Ozow processing
          break;
        case PaymentService.PAYMENT_METHOD_SNAPSCAN:
          // SnapScan processing
          break;
        case PaymentService.PAYMENT_METHOD_CAPITEC:
          // Capitec processing
          break;
        case PaymentService.PAYMENT_METHOD_TAKEALOT:
          // Takealot processing
          break;
        case PaymentService.PAYMENT_METHOD_PAYPAL:
          // PayPal processing
          break;
        case PaymentService.PAYMENT_METHOD_CRYPTO:
          // Luno processing
          break;
      }

      widget.onMethodSelected(_selectedMethod!);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      AnalyticsService.logEvent('payment_error', {
        'error': e.toString(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
