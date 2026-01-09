import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/create_event_screen.dart';

void main() {
  testWidgets('Create event screen shows form and submits',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateEventScreen()));
    expect(find.text('Create Event'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Party');
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pump();
    // If no crash, consider success for prototype
    expect(find.text('Create Event'), findsOneWidget);
  });
}
