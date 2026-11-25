import 'package:flutter/material.dart';

import 'theme.dart';

/// Elegant fade + slide page transition used across the app.
class AppRoute<T> extends PageRouteBuilder<T> {
  AppRoute(Widget page, {bool fadeOnly = false})
      : super(
          transitionDuration: const Duration(milliseconds: 460),
          reverseTransitionDuration: const Duration(milliseconds: 340),
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final fade = FadeTransition(opacity: curved, child: child);
            if (fadeOnly) return fade;
            return SlideTransition(
              position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved),
              child: fade,
            );
          },
        );
}

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(AppRoute<T>(page));

Future<T?> replaceAll<T>(BuildContext context, Widget page) =>
    Navigator.of(context).pushAndRemoveUntil<T>(AppRoute<T>(page, fadeOnly: true), (_) => false);

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 420),
      reverseDuration: Duration(milliseconds: 280),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: builder(ctx),
    ),
  );
}

void toast(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded, Color? color}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2400),
      content: Row(
        children: [
          Icon(icon, color: color ?? AppColors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final pal = context.pal;
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, a, _, _) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(curved),
          child: AlertDialog(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: pal.text)),
            content: Text(message, style: TextStyle(color: pal.textMuted, height: 1.5)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: destructive ? AppColors.red : AppColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
