// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jamuin/src/app/app.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VendoApp()));

    // Initial route is Splash.
    expect(find.text('Vendo'), findsOneWidget);

    // Let the splash delay + route transition complete.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Home screen title should still be visible.
    expect(find.text('Vendo'), findsWidgets);
  });
}
