import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'event_dashboard_screen.dart';

String eventHeroTag(String id) => 'event-cover-$id';

IconData categoryIcon(String c) => switch (c) {
      'Technology' => Icons.memory_rounded,
      'Sustainability' => Icons.eco_rounded,
      'Certification' => Icons.verified_rounded,
      'Corporate' => Icons.business_center_rounded,
      _ => Icons.event_rounded,
    };

Color categoryColor(String c) => switch (c) {
      'Technology' => AppColors.blue,
      'Sustainability' => AppColors.darkGrey,
      'Certification' => AppColors.blueDeep,
      'Corporate' => AppColors.darkBlue80,
      _ => AppColors.blue,
    };

void openEvent(BuildContext context, ClientaEvent e) => push(context, EventDashboardScreen(eventId: e.id));

/// "Mon, 23 Nov · 09:00 – 16:00" for one-day events, otherwise the date range and start time.
String eventWhen(ClientaEvent e) => sameDay(e.start, e.end)
    ? '${fmtDate(e.start)} · ${fmtTime(e.start)} – ${fmtTime(e.end)}'
    : '${fmtDate(e.start)} – ${fmtDate(e.end)} · ${fmtTime(e.start)}';

/// "BMICH, Bauddhaloka Mawatha, Colombo 07 🇱🇰" style full location.
String eventWhere(ClientaEvent e) => '${e.venue.name}, ${e.venue.city}, ${e.venue.country} ${e.venue.flag}';

/// Event cover photo with the generative artwork as a fallback.
class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.event, this.icon, this.iconSize = 54});
  final ClientaEvent event;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final fallback = CoverArt(seed: e.id, theme: e.art, icon: icon, iconSize: iconSize);
    if (e.image == null) return fallback;
    return Image.asset(e.image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, _, _) => fallback);
  }
}

/// Large premium card used in carousels.
class EventHeroCard extends StatelessWidget {
  const EventHeroCard({super.key, required this.event, this.heroEnabled = true});
  final ClientaEvent event;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          EventImage(event: e),
          // Darken towards the bottom so the title and details stay readable on any photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x40000000), Color(0x10000000), Color(0xCC0B1120)],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
        ],
      ),
    );
    return Pressable(
      onTap: () => openEvent(context, e),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: CoverArt.colorsFor(e.art)[1].withValues(alpha: 0.45), blurRadius: 26, offset: const Offset(0, 14), spreadRadius: -6)],
        ),
        child: Stack(
          children: [
            Positioned.fill(child: heroEnabled ? Hero(tag: eventHeroTag(e.id), child: cover) : cover),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              TagChip(label: e.category, color: Colors.white, icon: categoryIcon(e.category)),
                              if (e.inviteOnly) const TagChip(label: 'PCU only', color: AppColors.blueDeep, icon: Icons.lock_rounded),
                            ],
                          ),
                        ),
                        if (e.isLive) const LiveBadge(),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      e.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                      tint: Colors.white.withValues(alpha: 0.16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HeroInfo(icon: Icons.schedule_rounded, text: eventWhen(e), bold: true),
                                const SizedBox(height: 6),
                                _HeroInfo(icon: Icons.place_rounded, text: eventWhere(e)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward_rounded, color: AppColors.navy900, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({required this.icon, required this.text, this.bold = false});
  final IconData icon;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, color: Colors.white, size: 16)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, fontSize: 13, height: 1.3)),
          ),
        ],
      );
}

/// Compact horizontal event row used in lists.
class EventListCard extends StatelessWidget {
  const EventListCard({super.key, required this.event});
  final ClientaEvent event;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final pal = context.pal;
    final store = Store.instance;
    final registered = store.isRegistered(e.id);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => openEvent(context, e),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: EventImage(event: e, icon: categoryIcon(e.category), iconSize: 34),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text('${e.start.day}', style: const TextStyle(color: AppColors.navy900, fontWeight: FontWeight.w800, fontSize: 15, height: 1)),
                        Text(monthShort(e.start).toUpperCase(), style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 9.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: TagChip(label: e.category, small: true, color: categoryColor(e.category))),
                    const SizedBox(width: 6),
                    if (e.isLive) const LiveBadge(compact: true) else if (e.isPast) const TagChip(label: 'Past', small: true, color: AppColors.steel),
                  ],
                ),
                const SizedBox(height: 8),
                Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleMedium),
                const SizedBox(height: 6),
                _ListInfo(icon: Icons.schedule_rounded, text: eventWhen(e)),
                const SizedBox(height: 4),
                _ListInfo(icon: Icons.place_outlined, text: eventWhere(e)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 15, color: pal.textFaint),
                    const SizedBox(width: 4),
                    Text('${e.attendees}', style: context.tt.bodySmall),
                    const Spacer(),
                    if (registered)
                      const TagChip(label: 'Registered', small: true, color: AppColors.green, icon: Icons.check_rounded)
                    else if (!e.isPast)
                      Text(countdown(e.start), style: context.tt.labelMedium?.copyWith(color: AppColors.blue)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListInfo extends StatelessWidget {
  const _ListInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 14, color: context.pal.textMuted)),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: context.tt.bodySmall?.copyWith(height: 1.35))),
        ],
      );
}
