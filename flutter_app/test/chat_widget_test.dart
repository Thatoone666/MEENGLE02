import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meengle_flutter/screens/chat.dart';
import 'package:meengle_flutter/services/fake_socket_service.dart';

void main() {
  testWidgets('ChatScreen subscribes to history and messages and cleans up',
      (WidgetTester tester) async {
    final fake = FakeSocketService();
    await tester.pumpWidget(MaterialApp(home: ChatScreen(socketService: fake)));

    // simulate history arriving
    fake.pushHistory([
      {
        'from': 'userA',
        'text': 'hello',
        'timestamp': DateTime.now().toIso8601String()
      }
    ]);
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);

    // simulate live message
    fake.pushMessage({
      'from': 'userB',
      'text': 'hi there',
      'timestamp': DateTime.now().toIso8601String()
    });
    await tester.pumpAndSettle();
    expect(find.text('hi there'), findsOneWidget);

    // ensure disposing does not throw
    await tester.pumpWidget(Container());
    fake.dispose();
  });
}
