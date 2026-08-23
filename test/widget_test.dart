// Basic smoke test for the Marketing Management System.
//
// Verifies that the app boots and the splash screen is displayed.

import 'package:flutter_test/flutter_test.dart';

import 'package:marketing_management_system/main.dart';

void main() {
  testWidgets('App boots and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarketingApp());

    // Splash screen branding should be visible.
    expect(find.text('MarketFlow'), findsOneWidget);
    expect(find.text('Marketing Management System'), findsOneWidget);

    // Advance the splash timer to ensure the login navigation is scheduled.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // After 3 seconds the app should be on the login screen.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}