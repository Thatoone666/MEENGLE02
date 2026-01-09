import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meengle_flutter/screens/profile_edit.dart';
import 'test_helpers.dart';
import 'package:meengle_flutter/services/api.dart' as api_service;

void main() {
  testWidgets('set primary moves image to front', (WidgetTester tester) async {
    final imgs = ['img1.jpg', 'img2.jpg', 'img3.jpg'];
    final fake = FakeApiClient();
    // respond to profile PUT with OK
    fake.whenPut('/api/profile', http.Response(jsonEncode({'ok': true}), 200));
    api_service.ApiService.client = fake;
    await tester
        .pumpWidget(MaterialApp(home: ProfileEditScreen(initialImages: imgs)));
    await tester.pumpAndSettle();

    // initial primary should be img1.jpg
    final firstImage = find.byType(Image).first;
    expect(firstImage, findsWidgets);

    // tap 'Set Primary' on index 2 (img3)
    final setPrimaryButton =
        find.widgetWithText(TextButton, 'Set Primary').at(1);
    expect(setPrimaryButton, findsOneWidget);
    await tester.tap(setPrimaryButton);
    await tester.pumpAndSettle();

    // After set primary, first thumbnail should display img3
    // Find first Image widget and verify its image provider contains img3
    final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(imageWidgets.isNotEmpty, true);
    final firstImg = imageWidgets.first;
    final imageProvider = firstImg.image;
    expect(imageProvider.toString().contains('img3'), true);
    // assert that a PUT request to /api/profile was recorded and payload contains img3 first
    final last = fake.lastRequest();
    expect(last, isNotNull);
    expect(last!.method, 'PUT');
    final body = last.body as String?;
    expect(body != null && body.contains('img3'), true);
  });

  testWidgets('delete image removes from gallery', (WidgetTester tester) async {
    final imgs = ['a.jpg', 'b.jpg'];
    final fake = FakeApiClient();
    fake.whenPut('/api/profile', http.Response(jsonEncode({'ok': true}), 200));
    api_service.ApiService.client = fake;
    await tester
        .pumpWidget(MaterialApp(home: ProfileEditScreen(initialImages: imgs)));
    await tester.pumpAndSettle();

    // There should be 2 images initially
    expect(find.byType(Image), findsNWidgets(2));

    // Tap delete on second image
    final deleteButtons = find.widgetWithText(TextButton, 'Delete');
    expect(deleteButtons, findsWidgets);
    await tester.tap(deleteButtons.at(1));
    await tester.pumpAndSettle();

    // Confirm dialog appears, tap Delete
    expect(find.text('Delete Image'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    // Now only one image remains
    expect(find.byType(Image), findsOneWidget);
    final last = fake.lastRequest();
    expect(last, isNotNull);
    expect(last!.method, 'PUT');
    final body = last.body as String?;
    expect(body != null && !body.contains('b.jpg'), true);
  });
}
