import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/share_eta_dialog.dart';

class _FakeSafety {
  bool called = false;
  Future<void> shareEta(String matchId, DateTime eta) async {
    called = true;
  }
}

void main() {
  testWidgets('Share ETA dialog calls service', (WidgetTester tester) async {
    final fake = _FakeSafety();
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  await showDialog(
                      context: ctx,
                      builder: (_) => ShareETADialog(
                          matchId: '123', safetyService: fake as dynamic));
                },
                child: Text('Open')))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Share your ETA'), findsOneWidget);
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(fake.called, isTrue);
  });
}
