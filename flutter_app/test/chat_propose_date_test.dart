import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/screens/chat.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_socket_service.dart';

void main() {
  testWidgets('Propose date dialog opens and calls API', (tester) async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/dates/propose';
    fake.when(
        url, http.Response('{"dateId":"d_test","status":"pending"}', 200));

    final fakeSocket = FakeSocketService();
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(arguments: {
                'userId': 'u1',
                'match': {'id': 'u2', 'name': 'Test'}
              }),
              builder: (_) => ChatScreen(socketService: fakeSocket),
            ));
          },
          child: Text('open'),
        );
      }),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Tap the propose date icon
    // Provide initial history so the chat's loading spinner clears
    fakeSocket.pushHistory([
      {
        'from': 'u2',
        'text': 'hi',
        'timestamp': DateTime.now().toIso8601String()
      }
    ]);
    await tester.tap(find.byIcon(Icons.event));
    await tester.pumpAndSettle();

    // Dialog should appear
    expect(find.text('Propose a Date'), findsOneWidget);

    // Tap Send (it will use the FakeApiClient)
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    // After sending the dialog should be dismissed
    expect(find.text('Propose a Date'), findsNothing);

    // The chat should receive an announcement message from the propose flow
    await tester.pumpAndSettle();
    expect(find.textContaining('I proposed a date'), findsOneWidget);
  });
}
