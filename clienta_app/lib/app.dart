import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/splash_screen.dart';

class ClientaApp extends StatelessWidget {
  const ClientaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Brand screens (splash, onboarding, sign-in) are always white; after
    // sign-in the user's theme preference applies.
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeController.instance, AppState.instance]),
      builder: (context, _) => MaterialApp(
        title: 'CLIENTA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: AppState.instance.user == null ? ThemeMode.light : ThemeController.instance.value,
        themeAnimationDuration: const Duration(milliseconds: 500),
        themeAnimationCurve: Curves.easeInOutCubic,
        home: const SplashScreen(),
        builder: (context, child) => _DeviceFrame(child: child!),
      ),
    );
  }
}

/// How the app is shown on a wide screen (web / laptop presentation).
enum PreviewMode { mobile, fullScreen }

/// On wide screens the app can be shown inside an iPhone 16 Pro frame or
/// full-screen; a ⋮ menu switches between them. On phones it is full-screen.
class _DeviceFrame extends StatefulWidget {
  const _DeviceFrame({required this.child});
  final Widget child;

  @override
  State<_DeviceFrame> createState() => _DeviceFrameState();
}

class _DeviceFrameState extends State<_DeviceFrame> {
  // Keeps the app's state (current screen) when switching modes.
  final _appKey = GlobalKey();
  PreviewMode _mode = PreviewMode.mobile;
  bool _menuOpen = false;

  // iPhone 16 Pro: 402 × 874 pt, 62 pt top / 34 pt bottom safe area.
  static const _screen = Size(402, 874);
  static const _safe = EdgeInsets.only(top: 62, bottom: 34);
  static const _bezel = 12.0;
  static const _rim = 3.0;

  void _select(PreviewMode m) => setState(() {
        _mode = m;
        _menuOpen = false;
      });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final app = KeyedSubtree(key: _appKey, child: widget.child);
    if (mq.size.width < 600) return app;

    final mobile = _mode == PreviewMode.mobile;
    return ColoredBox(
      color: const Color(0xFF070B14),
      child: Stack(
        children: [
          if (mobile) ...[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.6, -0.7),
                    radius: 1.3,
                    colors: [AppColors.blue.withValues(alpha: 0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FittedBox(child: _phone(context, mq, app)),
              ),
            ),
          ] else
            Positioned.fill(child: app),
          // Tap outside closes the menu.
          if (_menuOpen)
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _menuOpen = false)),
            ),
          Positioned(
            top: 16,
            right: mobile ? 20 : null,
            left: mobile ? null : 0,
            child: mobile ? _menu() : SizedBox(width: mq.size.width, child: Center(child: _menu())),
          ),
        ],
      ),
    );
  }

  Widget _phone(BuildContext context, MediaQueryData mq, Widget app) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.white : Colors.black;
    final outer = Size(_screen.width + 2 * (_bezel + _rim), _screen.height + 2 * (_bezel + _rim));
    // Side buttons stick out a little, so leave room for them.
    return SizedBox(
      width: outer.width + 8,
      height: outer.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left: action button, volume up, volume down. Right: power, camera control.
          for (final (left, top, h) in [(true, 150.0, 34.0), (true, 210.0, 62.0), (true, 286.0, 62.0), (false, 230.0, 96.0), (false, 520.0, 72.0)])
            Positioned(
              left: left ? 0 : null,
              right: left ? null : 0,
              top: top,
              child: Container(
                width: 6,
                height: h,
                decoration: BoxDecoration(color: const Color(0xFF4A4D55), borderRadius: BorderRadius.circular(3)),
              ),
            ),
          Positioned(
            left: 4,
            top: 0,
            child: Container(
              width: outer.width,
              height: outer.height,
              padding: const EdgeInsets.all(_rim),
              decoration: BoxDecoration(
                // Titanium rim
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8A8D93), Color(0xFF3E4047), Color(0xFF8A8D93)],
                ),
                borderRadius: BorderRadius.circular(70),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 60, offset: Offset(0, 30))],
              ),
              child: Container(
                padding: const EdgeInsets.all(_bezel),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(67)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: SizedBox.fromSize(
                    size: _screen,
                    child: MediaQuery(
                      data: mq.copyWith(size: _screen, padding: _safe, viewPadding: _safe, devicePixelRatio: 3),
                      child: Stack(
                        children: [
                          Positioned.fill(child: app),
                          // Status bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 54,
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(44, 18, 34, 0),
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Icon(Icons.signal_cellular_alt_rounded, size: 18, color: fg),
                                    const SizedBox(width: 5),
                                    Icon(Icons.wifi_rounded, size: 18, color: fg),
                                    const SizedBox(width: 5),
                                    Transform.rotate(angle: math.pi / 2, child: Icon(Icons.battery_full_rounded, size: 22, color: fg)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Dynamic Island
                          Positioned(
                            top: 11,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 126,
                                  height: 37,
                                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                          // Home indicator
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 140,
                                  height: 5,
                                  decoration: BoxDecoration(color: fg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(3)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu() {
    Widget item(PreviewMode m, IconData icon, String label, String sub) {
      final sel = _mode == m;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _select(m),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 22, color: sel ? AppColors.blue : Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: sel ? AppColors.blue : Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              if (sel) const Icon(Icons.check_rounded, size: 18, color: AppColors.blue),
            ],
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // No Tooltip here: this sits above the app's Navigator, so there is no Overlay.
          Semantics(
            label: 'View options',
            button: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => _menuOpen = !_menuOpen),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B1E26).withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.more_vert_rounded, color: Colors.white),
              ),
            ),
          ),
          if (_menuOpen)
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item(PreviewMode.mobile, Icons.phone_iphone_rounded, 'Mobile', 'iPhone 16 Pro'),
                  item(PreviewMode.fullScreen, Icons.desktop_windows_rounded, 'Full screen', 'Fill the browser window'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
