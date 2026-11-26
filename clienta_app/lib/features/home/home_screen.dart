import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/notification_center_screen.dart';
import '../common/qr_screen.dart';
import '../events/event_card.dart';
import '../news/news_card.dart';
import '../services/contacts_screen.dart';
import '../services/knowledge_hub_screen.dart';
import '../services/support_ai_screen.dart';
import '../shell/main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AsyncView(
            keys: const ['events', 'news', 'notifications', 'chats'],
            skeleton: const _HomeSkeleton(),
            builder: (context) => const _HomeContent(),
          ),
        ),
        const _SupportAiBubble(),
      ],
    );
  }
}

/// Floating Support AI button. Starts at the bottom-right (above the nav bar)
/// and can be dragged anywhere on the home screen; tap opens Support AI.
class _SupportAiBubble extends StatefulWidget {
  const _SupportAiBubble();

  @override
  State<_SupportAiBubble> createState() => _SupportAiBubbleState();
}

class _SupportAiBubbleState extends State<_SupportAiBubble> {
  static const double _size = 58;
  static const double _margin = 12;
  Offset? _pos; // top-left; null until first layout → default bottom-right

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context); // bottom includes the floating nav bar
    return Positioned.fill(
      child: LayoutBuilder(builder: (context, c) {
        const minX = _margin;
        final maxX = (c.maxWidth - _size - _margin).clamp(minX, double.infinity);
        final minY = pad.top + _margin;
        final maxY = (c.maxHeight - pad.bottom - _size - _margin).clamp(minY, double.infinity);
        Offset clamp(Offset o) => Offset(o.dx.clamp(minX, maxX), o.dy.clamp(minY, maxY));
        final pos = clamp(_pos ?? Offset(maxX, maxY));
        return Stack(
          children: [
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _pos = clamp(pos + d.delta)),
                child: Pressable(
                  scale: 0.9,
                  onTap: () => push(context, const SupportAiScreen()),
                  child: Tooltip(
                    message: 'Support AI',
                    child: Container(
                      width: _size,
                      height: _size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      alignment: Alignment.center,
                      child: const BotIcon(size: 32),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final upcoming = store.events.where((e) => !e.isPast).toList();

    return RefreshIndicator(
      color: AppColors.blue,
      edgeOffset: 60,
      onRefresh: () => store.refresh(['events', 'news', 'notifications']),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: FadeSlideIn(
              index: 3,
              child: _WeekStrip(
                selected: _selected,
                hasSessions: (d) => store.events.any((e) => store.isRegistered(e.id) && e.sessions.any((s) => sameDay(s.start, d))),
                onSelect: (d) => setState(() => _selected = d),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Popular Events', action: 'See all', onAction: () => ShellScope.maybeOf(context)?.goTo(1)),
          ),
          SliverToBoxAdapter(child: FadeSlideIn(index: 4, child: _EventCarousel(events: upcoming))),
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Recent News', action: 'See more', onAction: () => ShellScope.maybeOf(context)?.goTo(2)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => FadeSlideIn(index: 5 + i, child: NewsCard(article: store.news[i])),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'CLIENTA Services')),
          const SliverToBoxAdapter(child: _Services()),
          const SliverToBoxAdapter(child: SizedBox(height: kNavBarSpace)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final user = app.user!;
    final pal = context.pal;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    return ListenableBuilder(
      listenable: Listenable.merge([app, Store.instance]),
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  Image.asset('assets/images/control_union_logo.png', height: 30, fit: BoxFit.contain),
                  const Spacer(),
                  CircleIconBtn(
                    icon: Icons.flag_rounded,
                    size: 42,
                    onTap: () => _regionSheet(context),
                    child: Text(app.regionFlag, style: const TextStyle(fontSize: 19, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                  ),
                  const SizedBox(width: 8),
                  const _ThemeToggle(),
                  const SizedBox(width: 8),
                  CircleIconBtn(
                    icon: Icons.notifications_none_rounded,
                    size: 42,
                    badge: Store.instance.unreadNotifications,
                    onTap: () => push(context, const NotificationCenterScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
                        const SizedBox(height: 2),
                        Text('Hello, ${user.firstName} 👋', style: context.tt.headlineMedium),
                        const SizedBox(height: 4),
                        Text('Let’s explore what’s happening at Control Union', style: context.tt.bodySmall),
                      ],
                    ),
                  ),
                  CircleIconBtn(icon: Icons.qr_code_2_rounded, size: 48, onTap: () => push(context, const QrScreen())),
                  const SizedBox(width: 10),
                  Pressable(
                    onTap: () => ShellScope.maybeOf(context)?.goTo(4),
                    child: AppAvatar(name: user.name, url: user.photoUrl, size: 52, ring: true, online: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _regionSheet(BuildContext context) {
    const regions = {'Sri Lanka': '🇱🇰', 'India': '🇮🇳', 'Bangladesh': '🇧🇩', 'China': '🇨🇳', 'Netherlands': '🇳🇱', 'Italy': '🇮🇹', 'Global': '🌍'};
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your region', style: ctx.tt.titleLarge),
            const SizedBox(height: 4),
            Text('Used to personalise country news and event suggestions.', style: ctx.tt.bodySmall),
            const SizedBox(height: 12),
            for (final r in regions.entries)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Text(r.value, style: const TextStyle(fontSize: 26, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                title: Text(r.key, style: ctx.tt.titleSmall),
                trailing: AppState.instance.regionCountry == r.key ? const Icon(Icons.check_circle_rounded, color: AppColors.blue) : null,
                onTap: () {
                  AppState.instance.update(() {
                    AppState.instance.regionCountry = r.key;
                    AppState.instance.regionFlag = r.value;
                  });
                  Navigator.pop(ctx);
                  toast(context, 'Region set to ${r.key}');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return CircleIconBtn(
      icon: Icons.dark_mode_rounded,
      size: 42,
      onTap: () => ThemeController.instance.toggle(Theme.of(context).brightness),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (c, a) => RotationTransition(
          turns: Tween(begin: 0.6, end: 1.0).animate(a),
          child: ScaleTransition(scale: a, child: c),
        ),
        child: Icon(
          dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(dark),
          size: 20,
          color: dark ? AppColors.lightBlue60 : AppColors.cuDarkBlue,
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.onSelect, required this.hasSessions});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final bool Function(DateTime) hasSessions;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day - 1 + i));
    final selIndex = days.indexWhere((d) => sameDay(d, selected)).clamp(0, 6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: pal.border.withValues(alpha: 0.7)),
        ),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth / 7;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                left: selIndex * w + 3,
                top: 0,
                bottom: 0,
                width: w - 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    SizedBox(
                      width: w,
                      child: Pressable(
                        scale: 0.9,
                        onTap: () => onSelect(days[i]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11.5, fontWeight: FontWeight.w600, color: i == selIndex ? Colors.white70 : pal.textFaint),
                              child: Text(sameDay(days[i], now) ? 'Today' : weekdayShort(days[i])),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: i == selIndex ? Colors.white : pal.text),
                              child: Text('${days[i].day}'),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasSessions(days[i]) ? (i == selIndex ? Colors.white : AppColors.blue) : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _EventCarousel extends StatefulWidget {
  const _EventCarousel({required this.events});
  final List<ClientaEvent> events;

  @override
  State<_EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<_EventCarousel> {
  final _c = PageController(viewportFraction: 0.86);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(() => setState(() => _page = _c.page ?? 0));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Column(
      children: [
        SizedBox(
          height: 345,
          child: PageView.builder(
            controller: _c,
            itemCount: widget.events.length,
            padEnds: false,
            itemBuilder: (context, i) {
              final delta = (i - _page).abs().clamp(0.0, 1.0);
              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? 20 : 8, right: 8, top: 6, bottom: 18),
                child: Transform.scale(
                  scale: 1 - 0.06 * delta,
                  child: Opacity(opacity: 1 - 0.3 * delta, child: EventHeroCard(event: widget.events[i])),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.events.length, (i) {
            final a = (1 - (i - _page).abs()).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6 + 16 * a,
              height: 6,
              decoration: BoxDecoration(color: Color.lerp(pal.border, AppColors.blue, a), borderRadius: BorderRadius.circular(6)),
            );
          }),
        ),
      ],
    );
  }
}

class _Services extends StatelessWidget {
  const _Services();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.contacts_rounded, 'Contacts', 'Find participants', AppColors.blueDeep, () => push(context, const ContactsScreen())),
      (Icons.lightbulb_rounded, 'Knowledge Hub', 'Standards & guides', AppColors.blue, () => push(context, const KnowledgeHubScreen())),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          for (var i = 0; i < items.length; i++)
            FadeSlideIn(
              index: 8 + i,
              child: AppCard(
                padding: const EdgeInsets.all(16),
                onTap: items[i].$5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon: items[i].$1, color: items[i].$4, size: 42, solid: true),
                    const Spacer(),
                    Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(items[i].$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 20, 20),
        children: const [
          Row(children: [SkeletonBox(height: 30, circle: true), SizedBox(width: 10), SkeletonBox(width: 90), Spacer(), SkeletonBox(height: 42, circle: true), SizedBox(width: 8), SkeletonBox(height: 42, circle: true), SizedBox(width: 8), SkeletonBox(height: 42, circle: true)]),
          SizedBox(height: 26),
          SkeletonBox(width: 110),
          SizedBox(height: 10),
          SkeletonBox(width: 220, height: 28),
          SizedBox(height: 22),
          SkeletonBox(height: 84, radius: 24),
          SizedBox(height: 28),
          SkeletonBox(width: 150, height: 20),
          SizedBox(height: 14),
          SkeletonBox(height: 270, radius: 28),
          SizedBox(height: 24),
          SkeletonBox(height: 120, radius: 22),
        ],
      ),
    );
  }
}
