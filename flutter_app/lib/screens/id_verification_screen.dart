import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import 'video_verification_screen.dart';

class IDVerificationScreen extends StatelessWidget {
  const IDVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ID Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify your identity to unlock premium trust badges.'),
            SizedBox(height: 12),
            ElevatedButton(
              key: Key('start_verification_button'),
              onPressed: () {
                AnalyticsService.track('id_verification_started');
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => VideoVerificationScreen()));
              },
              child: Text('Start video verification'),
            ),
            SizedBox(height: 12),
            Text(
                'We only use this for identity verification. Photos and videos are deleted after verification.')
          ],
        ),
      ),
    );
  }
}
