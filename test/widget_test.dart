import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:moon_cake_app/main.dart';


class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final originalHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _TestHttpOverrides();

    try {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the FAB increment button and trigger a frame.
      await tester.tap(find.byTooltip('Increment'));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    } finally {
      HttpOverrides.global = originalHttpOverrides;
    }
  });
}
