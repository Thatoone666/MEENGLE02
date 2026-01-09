import 'package:equatable/equatable.dart';
import '../../models/subscription_model.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class StartPayment extends PaymentEvent {
  final String userId;
  final String email;
  final String? name;
  final SubscriptionTier tier;

  const StartPayment({
    required this.userId,
    required this.email,
    this.name,
    required this.tier,
  });

  @override
  List<Object?> get props => [userId, email, name, tier];
}

class CompletePayment extends PaymentEvent {
  final String paymentIntentId;
  final SubscriptionTier tier;

  const CompletePayment({
    required this.paymentIntentId,
    required this.tier,
  });

  @override
  List<Object> get props => [paymentIntentId, tier];
}

class CancelPayment extends PaymentEvent {}