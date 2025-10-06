import 'package:flutter_test/flutter_test.dart';
import 'package:askar_alpha/main.dart';

void main() {
  testWidgets('App launches and displays main page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AskarAlphaApp());

    // Verify that the app title is displayed
    expect(find.text('Home'), findsOneWidget);
  });
}
