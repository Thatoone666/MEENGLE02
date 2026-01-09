import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/stripe_service.dart';
import '../../services/payment_manager.dart';
import '../../services/subscription_service.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final StripeService _stripeService;
  final PaymentManager _paymentManager;

  PaymentBloc({
    required StripeService stripeService,
    required PaymentManager paymentManager,
    required SubscriptionService subscriptionService,
  })  : _stripeService = stripeService,
        _paymentManager = paymentManager,
        super(PaymentInitial()) {
    on<StartPayment>(_onStartPayment);
    on<CompletePayment>(_onCompletePayment);
    on<CancelPayment>(_onCancelPayment);
  }

  Future<void> _onStartPayment(
    StartPayment event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());

      // Create or get customer
      final customer = await _stripeService.createCustomer(
        email: event.email,
        name: event.name,
        metadata: {'userId': event.userId},
      );

      // Create payment intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: (event.tier.priceInRand * 100).round().toString(), // Convert to cents
        currency: 'zar',
        customerId: customer['id'],
        description: '${event.tier.displayName} Subscription',
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Meengle',
          customerId: customer['id'],
          style: ThemeMode.system,
        ),
      );

      emit(PaymentReady(paymentIntent['id']));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onCompletePayment(
    CompletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentProcessing());

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Create subscription
      await _paymentManager.verifyPayment(
        method: PaymentProviderMethod.creditCard,
        notificationData: {
          'transaction_id': event.paymentIntentId,
          'amount': event.tier.priceInRand.toString(),
          'signature': '', // Not needed for Stripe
        },
        tier: event.tier,
      );

      emit(PaymentSuccess());
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onCancelPayment(
    CancelPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentCancelled());
  }
}