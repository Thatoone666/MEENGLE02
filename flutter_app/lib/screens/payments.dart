import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/payment/payment_bloc.dart';
import '../bloc/payment/payment_event.dart';
import '../bloc/payment/payment_state.dart';
import '../widgets/subscription_card.dart';
import '../widgets/payment_error_dialog.dart';
import '../models/subscription_model.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentFailure) {
          showDialog(
            context: context,
            builder: (context) => PaymentErrorDialog(error: state.error),
          );
        } else if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscribe'),
            elevation: 0,
          ),
          body: state is PaymentLoading || state is PaymentProcessing
              ? const Center(child: CircularProgressIndicator())
              : _buildSubscriptionOptions(context),
        );
      },
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Choose your plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SubscriptionCard(
          title: 'Premium',
          price: SubscriptionTier.premium.priceInRand,
          features: const [
            '100 swipes per day',
            '5 super likes',
            'Rewind feature',
            'Ad-free experience',
            'See who likes you',
          ],
          onSubscribe: () => _startPayment(
            context,
            SubscriptionTier.premium,
            user?.email ?? '',
            user?.id ?? '',
            user?.displayName,
          ),
        ),
        const SizedBox(height: 16),
        SubscriptionCard(
          title: 'VIP',
          price: SubscriptionTier.vip.priceInRand,
          features: const [
            'Unlimited swipes',
            '10 super likes',
            'Rewind feature',
            'Ad-free experience',
            'See who likes you',
            'Priority in search results',
            'Exclusive features',
          ],
          highlighted: true,
          onSubscribe: () => _startPayment(
            context,
            SubscriptionTier.vip,
            user?.email ?? '',
            user?.id ?? '',
            user?.displayName,
          ),
        ),
      ],
    );
  }

  void _startPayment(
    BuildContext context,
    SubscriptionTier tier,
    String email,
    String userId,
    String? name,
  ) {
    context.read<PaymentBloc>().add(StartPayment(
      userId: userId,
      email: email,
      name: name,
      tier: tier,
    ));
  }
}
