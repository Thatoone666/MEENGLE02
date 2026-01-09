import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/schedule_boost_dialog.dart';

class _FakeBoostService {
  bool called = false;
  Future<void> createBoost(DateTime start, Duration duration) async {
    called = true;
  }
}

void main() {
  testWidgets('Schedule boost dialog calls service',
      (WidgetTester tester) async {
    final fake = _FakeBoostService();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              await showDialog(
                context: ctx,
                builder: (_) => ScheduleBoostDialog(),
              );
            },
            child: Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Boost'), findsOneWidget);
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(fake.called, isTrue);
  });
}
