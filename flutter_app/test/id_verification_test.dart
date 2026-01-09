import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/id_verification_screen.dart';
import 'package:meengle_flutter/screens/video_verification_screen.dart';

void main() {
  testWidgets('ID verification screen navigates to video verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: IDVerificationScreen()));
    expect(find.text('ID Verification'), findsOneWidget);
    await tester.tap(find.text('Start video verification'));
    await tester.pumpAndSettle();
    expect(find.byType(VideoVerificationScreen), findsOneWidget);
  });
}
// unit tests for id verification moved to id_verification_service_test.dart
