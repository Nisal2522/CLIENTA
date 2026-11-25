import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../../data/store.dart';
import '../chats/chats_screen.dart';
import '../events/events_screen.dart';
import '../home/home_screen.dart';
import '../news/news_screen.dart';
import '../profile/profile_screen.dart';

/// Bottom padding scrollable tab content needs to clear the floating nav bar.
const double kNavBarSpace = 120;

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTo, required super.child});
  final ValueChanged<int> goTo;

  static ShellScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  final Set<int> _visited = {0};
  // Only the newly selected tab fades in; the previous one is hidden at once,
  // so two tabs are never drawn on top of each other.
  late final AnimationController _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);
  late final Animation<double> _fadeCurve = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.event_outlined, Icons.event_rounded, 'Events'),
    (Icons.newspaper_outlined, Icons.newspaper_rounded, 'News'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chats'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  void _go(int i) {
    if (i == _index) return;
    setState(() {
      _index = i;
      _visited.add(i);
    });
    _fade.forward(from: 0);
  }

  Widget _tab(int i) => switch (i) {
        0 => const HomeScreen(),
        1 => const EventsScreen(),
        2 => const NewsScreen(),
        3 => const ChatsScreen(),
        _ => const ProfileScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return ShellScope(
      goTo: _go,
      child: PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _go(0);
        },
        child: Scaffold(
          extendBody: true,
          body: Column(
            children: [
              const _OfflineBanner(),
              Expanded(
                child: Stack(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      if (_visited.contains(i))
                        Positioned.fill(
                          child: Offstage(
                            offstage: i != _index,
                            child: TickerMode(
                              enabled: i == _index,
                              child: HeroMode(
                                enabled: i == _index,
                                // Same widget structure for every tab so state is kept.
                                child: FadeTransition(
                                  opacity: i == _index ? _fadeCurve : const AlwaysStoppedAnimation(1.0),
                                  child: SlideTransition(
                                    position: i == _index
                                        ? Tween(begin: const Offset(0, 0.012), end: Offset.zero).animate(_fadeCurve)
                                        : const AlwaysStoppedAnimation(Offset.zero),
                                    child: _tab(i),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _NavBar(index: _index, items: _items, onTap: _go),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.items, required this.onTap});
  final int index;
  final List<(IconData, IconData, String)> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: pal.dark ? AppColors.navy800.withValues(alpha: 0.82) : Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: pal.dark ? Colors.white.withValues(alpha: 0.08) : pal.border),
              boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: ListenableBuilder(
              listenable: Store.instance,
              builder: (context, _) => Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      flex: i == index ? 19 : 10,
                      child: _NavItem(
                        selected: i == index,
                        icon: items[i].$1,
                        activeIcon: items[i].$2,
                        label: items[i].$3,
                        badge: i == 3 ? Store.instance.unreadChats : 0,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.selected, required this.icon, required this.activeIcon, required this.label, required this.onTap, this.badge = 0});
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 0),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.brandGradient : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badge > 0,
                label: Text('$badge'),
                backgroundColor: AppColors.red,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Icon(
                    selected ? activeIcon : icon,
                    key: ValueKey(selected),
                    color: selected ? Colors.white : pal.textMuted,
                    size: 24,
                  ),
                ),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(label, maxLines: 1, overflow: TextOverflow.fade, softWrap: false, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final offline = AppState.instance.offline;
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: offline
              ? Container(
                  width: double.infinity,
                  color: AppColors.orange,
                  padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 6, bottom: 8, left: 16, right: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('You’re offline — showing saved content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5))),
                      GestureDetector(
                        onTap: () => AppState.instance.update(() => AppState.instance.offline = false),
                        child: const Text('Go online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}
