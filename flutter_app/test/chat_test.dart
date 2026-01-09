import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:meengle_flutter/screens/chat.dart';
import 'package:meengle_flutter/services/fake_socket_service.dart';

void main() {
  testWidgets('ChatScreen shows messages from injected socket',
      (WidgetTester tester) async {
    final fake = FakeSocketService();

    // Build a small app that pushes ChatScreen with RouteSettings so
    // ModalRoute.of(context)?.settings.arguments is available.
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

    // Tap to open the ChatScreen route
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Now push a message from the fake socket and verify it's shown
    fake.pushMessage({
      'from': '2',
      'text': 'hello',
      'timestamp': DateTime.now().toIso8601String()
    });
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsOneWidget);
  });
}
