// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:jamuin/src/app/app.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: JamuinApp()));

    // Initial route is Splash.
    expect(find.text('Jamuin'), findsOneWidget);

    // Let the splash delay + route transition complete.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // With no stored session, app should land on Login.
    expect(find.widgetWithText(AppBar, 'Masuk'), findsOneWidget);
  });
}
