import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:meengle_flutter/screens/chat.dart';
import 'package:meengle_flutter/services/fake_api_client.dart';
import 'package:meengle_flutter/services/api.dart';
import 'package:meengle_flutter/services/fake_socket_service.dart';

void main() {
  testWidgets(
      'AI suggestions dialog shows prompts and inserts into message field',
      (tester) async {
    final fake = FakeApiClient();
    ApiService.client = fake;
    final url = '${ApiService.baseUrl}/api/ai/openers';
    fake.when(
        url, http.Response('{"prompts":["Hey there","Nice photo!"]}', 200));

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

    // Provide history so chat leaves loading state
    fakeSocket.pushHistory([
      {
        'from': 'u2',
        'text': 'hi',
        'timestamp': DateTime.now().toIso8601String()
      }
    ]);
    await tester.pumpAndSettle();

    // Tap AI suggestions icon
    await tester.tap(find.byIcon(Icons.lightbulb));
    await tester.pumpAndSettle();

    expect(find.text('AI Suggestions'), findsOneWidget);

    // Tap first prompt
    await tester.tap(find.text('Hey there'));
    await tester.pumpAndSettle();

    // The message TextField should contain the selected prompt
    expect(find.widgetWithText(TextField, 'Hey there'), findsOneWidget);
  });
}
