// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import 'package:flutter/cupertino.dart';

class PremiumScreen extends StatefulWidget {
  final String email;
  const PremiumScreen({super.key, required this.email});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _loading = false;
  String? _message;
  bool _boosting = false;

  Future<void> _buy() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final resp = await PremiumService.purchaseSubscriptionViaStripe(
          '9.99', widget.email);
      // For now assume success if a clientSecret or url is returned
      if (resp.containsKey('clientSecret') || resp.containsKey('url')) {
        await PremiumService.setPremium(true);
        setState(() => _message = 'Purchase successful — premium unlocked');
      } else {
        setState(() => _message = 'Unexpected response: $resp');
      }
    } catch (e) {
      setState(() => _message = 'Purchase failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _boostNow() async {
    setState(() => _boosting = true);
    final ok = await PremiumService.boostNow();
    setState(() => _boosting = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Boost activated!')));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Boost failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Go Premium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Unlock premium features for just 9.99',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _buy,
              child:
                  _loading ? CupertinoActivityIndicator() : Text('Buy Premium'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _boosting ? null : _boostNow,
              icon: const Icon(Icons.rocket_launch),
              label: _boosting
                  ? const Text('Boosting...')
                  : const Text('Boost Now'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Placeholder for a screen that would use this service
                PremiumService.advancedSearch({
                  'interests': ['coding']
                }).then((results) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Advanced search returned ${results?.length ?? 0} users.')));
                });
              },
              child: const Text('Advanced Search'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // In a real scenario, you'd get a targetId from another screen
                // For now, show a placeholder message.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Select a user from the sthat was still not siwipe screen to use Instant Match!')));
                // Example of how it would be called:
                // final success = await PremiumService.instantMatch('some_user_id');
                // if (success) ...
              },
              child: const Text('Instant Match'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final event = await PremiumService.flashEvent('some_location');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(event != null
                        ? 'Flash Event: ${event['event']}'
                        : 'No flash event found.')));
              },
              child: const Text('Flash Event'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // In a real scenario, you'd get a targetId from another screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Select a user to send a Wingman request!')));
                // Example of how it would be called:
                // final success = await PremiumService.sendWingmanRequest('some_user_id');
              },
              child: const Text('Wingman Requests'),
            ),
            if (_message != null) ...[
              SizedBox(height: 12),
              Text(_message!),
            ]
          ],
        ),
      ),
    );
  }
}
