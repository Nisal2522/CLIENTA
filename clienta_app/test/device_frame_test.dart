import 'package:clienta/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Laptop-sized window: the app starts in the iPhone 16 Pro frame and the
/// ⋮ menu switches to full screen and back without losing the current screen.
void main() {
  testWidgets('wide screen: iPhone 16 Pro frame ↔ full screen', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<void> settle([int ms = 1000]) async {
      for (var t = 0; t < ms; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(const ClientaApp());
    await settle(3600);
    expect(find.text('Skip'), findsOneWidget);

    // Starts as a phone: app laid out at 402 pt wide.
    double appWidth() => MediaQuery.sizeOf(tester.element(find.text('Skip'))).width;
    expect(appWidth(), 402);

    // ⋮ → Full screen.
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await settle(300);
    expect(find.text('iPhone 16 Pro'), findsOneWidget);
    await tester.tap(find.text('Full screen'));
    await settle(600);
    expect(find.text('iPhone 16 Pro'), findsNothing, reason: 'menu closes after picking');
    expect(find.text('Skip'), findsOneWidget, reason: 'same screen kept');
    expect(appWidth(), 1440);

    // ⋮ → Mobile again.
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await settle(300);
    await tester.tap(find.text('Mobile'));
    await settle(600);
    expect(find.text('Skip'), findsOneWidget);
    expect(appWidth(), 402);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  });
}
