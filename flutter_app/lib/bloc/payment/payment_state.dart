import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentProcessing extends PaymentState {}

class PaymentReady extends PaymentState {
  final String paymentIntentId;

  const PaymentReady(this.paymentIntentId);

  @override
  List<Object> get props => [paymentIntentId];
}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String error;

  const PaymentFailure(this.error);

  @override
  List<Object> get props => [error];
}

class PaymentCancelled extends PaymentState {}