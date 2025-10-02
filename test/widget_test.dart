import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:askar_import/main.dart';

void main() {
  testWidgets('App launches and displays main page', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Download Askar Export (Phase 1)'), findsOneWidget);

    // Verify that key UI elements are present
    expect(find.text('Server URL'), findsOneWidget);
    expect(find.text('Profile (sub-wallet) name'), findsOneWidget);
    expect(find.text('Check Health'), findsOneWidget);
    expect(find.text('Download Export JSON'), findsOneWidget);
    expect(find.text('Status: Ready'), findsOneWidget);
  });

  testWidgets('Text fields accept input', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find text form fields
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    // Test entering text in server URL field
    await tester.enterText(textFields.first, 'http://test.example.com:9000');
    await tester.pump();

    // Test entering text in profile field
    await tester.enterText(textFields.last, 'test_profile_123');
    await tester.pump();

    // Verify the text controllers have the correct values
    expect(find.text('http://test.example.com:9000'), findsOneWidget);
    expect(find.text('test_profile_123'), findsOneWidget);
  });
}
