import 'package:flutter_test/flutter_test.dart';
import 'package:meengle_flutter/main.dart';
import 'package:meengle_flutter/repositories/user_repository.dart';

void main() {
  testWidgets('App builds and shows login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(userRepository: UserRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}
