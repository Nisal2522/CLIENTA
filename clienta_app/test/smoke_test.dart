import 'package:clienta/app.dart';
import 'package:clienta/core/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Walks through every major screen on a phone-sized viewport, in dark and
/// light mode, and fails if any layout overflow or exception is reported.
void main() {
  testWidgets('CLIENTA smoke test — all screens render without errors', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final errors = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (d) {
      final msg = d.exceptionAsString().split('\n').first;
      final where = RegExp(r'lib/[\w/]+\.dart:\d+').allMatches(d.toString()).map((m) => m.group(0)).toSet().take(2).join(', ');
      errors.add('$msg  [${d.context?.toDescription() ?? ''}] $where  (at: $_step)');
    };

    Future<void> settle([int ms = 1600]) async {
      for (var t = 0; t < ms; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    NavigatorState nav() => tester.state<NavigatorState>(find.byType(Navigator).first);

    Future<void> tapText(String text) async {
      _step = text;
      var f = find.text(text);
      if (f.hitTestable().evaluate().isEmpty) {
        final scrollable = find.byWidgetPredicate((w) => w is Scrollable && axisDirectionToAxis(w.axisDirection) == Axis.vertical).hitTestable();
        if (scrollable.evaluate().isNotEmpty) {
          for (final delta in [-300.0, 300.0]) {
            if (f.hitTestable().evaluate().isNotEmpty) break;
            try {
              await tester.scrollUntilVisible(f.hitTestable(), delta, scrollable: scrollable.first, maxScrolls: 25);
            } catch (_) {}
          }
        }
        expect(f, findsWidgets, reason: 'Missing "$text"');
        if (f.hitTestable().evaluate().isEmpty) await tester.ensureVisible(f.first);
        await tester.pump(const Duration(milliseconds: 300));
      }
      f = f.hitTestable();
      expect(f, findsWidgets, reason: '"$text" is not tappable');
      await tester.tap(f.first, warnIfMissed: false);
      await settle();
    }

    Future<void> back() async {
      nav().pop();
      await settle(900);
    }

    try {
      // Splash → onboarding → welcome
      await tester.pumpWidget(const ClientaApp());
      _step = 'splash';
      await settle(3600);
      await tapText('Skip');

      // Employee sign-in → shell
      await tapText('PCU employee sign-in');
      await settle(2500);
      expect(find.textContaining('Hello,'), findsOneWidget);

      for (final mode in [ThemeMode.dark, ThemeMode.light]) {
        ThemeController.instance.value = mode;
        await settle(900);

        // Home shortcuts
        for (final s in ['Contacts', 'Knowledge Hub']) {
          await tapText(s);
          await back();
        }
        _step = 'Support AI bubble';
        await tester.tap(find.byTooltip('Support AI').hitTestable().first, warnIfMissed: false);
        await settle();
        expect(find.text('Support AI'), findsWidgets);
        await back();

        // Event dashboard and every feature
        await tapText('FutureTech Connect 2026');
        await settle(1500);
        for (final f in [
          'About Event',
          'Tips',
          'Agenda',
          'Speakers',
          'Location',
          'Gallery',
          'Certificate',
          'Evaluations',
          'Live Chat',
          'Meetings',
          'Groups',
          'My Notes',
          'Contact Us',
          'Resources',
          'Notifications',
          'Participants',
        ]) {
          await tapText(f);
          await settle(800);
          await back();
        }
        await back();

        // Tabs
        for (final tab in [Icons.event_outlined, Icons.campaign_outlined, Icons.chat_bubble_outline_rounded, Icons.person_outline_rounded, Icons.home_outlined]) {
          _step = 'tab $tab';
          await tester.tap(find.byIcon(tab).last, warnIfMissed: false);
          await settle(2000);
        }
      }

      // Regression: switching tabs must never leave the previous tab visible.
    _step = 'tab overlap check';
    await tester.tap(find.byIcon(Icons.event_outlined).last, warnIfMissed: false);
    await settle(1000);
    expect(find.text('Popular Events'), findsNothing, reason: 'Home tab still visible behind Events');
    expect(find.text('Explore and register for PCU events worldwide'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home_outlined).last, warnIfMissed: false);
    await settle(1000);

    // A few deeper screens
      await tester.tap(find.byIcon(Icons.person_outline_rounded).last, warnIfMissed: false);
      await settle();
      for (final s in ['Edit profile', 'My certificates']) {
        await tapText(s);
        await back();
      }
      _step = 'open settings';
      await tester.tap(find.byIcon(Icons.settings_rounded).hitTestable().first, warnIfMissed: false);
      await settle();
      for (final s in ['Language', 'Privacy settings', 'Account management']) {
        await tapText(s);
        await back();
      }
      await tapText('UI states gallery');
      for (final s in ['Empty', 'Error', 'Offline', 'Success', 'Permissions']) {
        await tapText(s);
      }
      await back();
      await back();

      await tester.tap(find.byIcon(Icons.campaign_outlined).last, warnIfMissed: false);
      await settle();
      await tapText('PCU');
      await tapText('For you');
      await tapText('GOTS Version 7.0 is now fully effective');
      _step = 'news reaction panel';
      await tester.scrollUntilVisible(find.text('React to this article'), 300, scrollable: find.byType(Scrollable).first);
      await settle(600);
      await tapText('👏');
      expect(find.textContaining('You and'), findsOneWidget);
      await back();

      // Events: tabs, date filter, header back → Home.
      await tester.tap(find.byIcon(Icons.event_outlined).last, warnIfMissed: false);
      await settle();
      expect(find.text('Past'), findsNothing);
      await tapText('All Events');
      // Test font is wide: scroll the chip row to reach the last chip.
      await tester.drag(find.text('All Events').hitTestable().first, const Offset(-250, 0));
      await settle(600);
      await tapText('My Events');
      _step = 'events date filter';
      await tester.tap(find.byIcon(Icons.tune_rounded).hitTestable().first, warnIfMissed: false);
      await settle(900);
      expect(find.text('Category'.toUpperCase()), findsNothing);
      await tapText('This month');
      await tapText('Show results');
      // Events is a tab without a back button: return Home with the nav bar.
      _step = 'events to home';
      await tester.tap(find.byIcon(Icons.home_outlined).last, warnIfMissed: false);
      await settle();
      expect(find.text('Explore and register for PCU events worldwide'), findsNothing, reason: 'Home tab should leave Events');
      expect(find.text('Home'), findsOneWidget, reason: 'Should land on Home');

      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).last, warnIfMissed: false);
      await settle();

      // Pin a chat via long-press.
      _step = 'pin chat';
      await tester.longPress(find.text('Mei Lin Chen').hitTestable().first, warnIfMissed: false);
      await settle(900);
      await tapText('Pin chat');
      expect(find.byIcon(Icons.push_pin_rounded), findsWidgets);

      await tapText('Ravindu Silva');
      await settle(1500);

      // Long-press → react.
      _step = 'react to message';
      await tester.longPress(find.text('Does 4:30 work for you?').hitTestable().first, warnIfMissed: false);
      await settle(900);
      await tapText('❤️');
      expect(find.text('❤️'), findsWidgets);

      // Swipe right → reply preview → send.
      _step = 'swipe to reply';
      await tester.drag(find.text('Does 4:30 work for you?').hitTestable().first, const Offset(120, 0));
      await settle(900);
      expect(find.byTooltip('Cancel reply'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '4:30 is perfect');
      await tester.tap(find.byIcon(Icons.send_rounded).last, warnIfMissed: false);
      await settle(4000);
      expect(find.text('4:30 is perfect'), findsOneWidget);
      expect(find.byTooltip('Cancel reply'), findsNothing);

      // Call screen.
      _step = 'call';
      await tester.tap(find.byIcon(Icons.call_rounded).hitTestable().first, warnIfMissed: false);
      await settle(5000);
      expect(find.textContaining('00:0'), findsOneWidget, reason: 'Call should be connected with a running timer');
      await tester.tap(find.byIcon(Icons.call_end_rounded), warnIfMissed: false);
      await settle(1500);
      expect(find.byIcon(Icons.call_end_rounded), findsNothing);
      await back();
    } catch (e, st) {
      final trace = st.toString().split('\n').where((l) => l.contains('clienta')).take(6).join('\n');
      errors.add('FAILED at step "$_step": $e\n$trace');
    } finally {
      // Tear down: unmount to stop repeating animations and flush timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
      FlutterError.onError = original;
    }

    if (errors.isNotEmpty) {
      // ignore: avoid_print
      print('FOUND ${errors.length} ERRORS:\n${errors.toSet().join('\n')}');
    }
    expect(errors, isEmpty);
  });
}

String _step = '';
