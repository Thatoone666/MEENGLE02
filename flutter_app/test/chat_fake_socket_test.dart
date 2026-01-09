import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meengle_flutter/screens/chat.dart';
import 'package:meengle_flutter/services/fake_socket_service.dart';

void main() {
  testWidgets(
      'ChatScreen subscribes to history and messages and disposes cleanly',
      (tester) async {
    final fake = FakeSocketService();

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(arguments: {
                'userId': '1',
                'match': {'id': '2', 'name': 'Test'}
              }),
              builder: (_) => ChatScreen(socketService: fake),
            ));
          },
          child: Text('open'),
        );
      }),
    ));

    // Open the chat screen route
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // simulate history arriving
    fake.pushHistory([
      {
        'from': '2',
        'text': 'Hello from history',
        'timestamp': DateTime.now().toIso8601String()
      }
    ]);
    // allow the stream events to be processed
    await tester.pumpAndSettle();

    expect(find.textContaining('Hello from history'), findsOneWidget);

    // simulate a new message
    fake.pushMessage({
      'from': '2',
      'text': 'New message',
      'timestamp': DateTime.now().toIso8601String()
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('New message'), findsOneWidget);

    // Now dispose the widget by popping the route and verify no errors
    Navigator.of(tester.element(find.byType(ChatScreen))).pop();
    await tester.pumpAndSettle();

    // If we reach here without exceptions the dispose path is fine.
    expect(true, isTrue);
  });
}
