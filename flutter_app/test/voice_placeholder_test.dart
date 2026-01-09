import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/voice_placeholder.dart';

class _FakeVoiceService {
  bool uploaded = false;
  Future<Map<String, dynamic>> uploadSample(dynamic bytes) async {
    uploaded = true;
    return {'url': '/voice/1'};
  }
}

void main() {
  testWidgets('Voice placeholder uploads sample', (WidgetTester tester) async {
    final fake = _FakeVoiceService();
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  await showDialog(
                      context: ctx,
                      builder: (_) =>
                          VoicePlaceholder(voiceService: fake as dynamic));
                },
                child: Text('Open')))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Voice Message'), findsOneWidget);
    await tester.tap(find.text('Record'));
    await tester.pump();
    // Stop recording
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(fake.uploaded, isTrue);
  });
}
