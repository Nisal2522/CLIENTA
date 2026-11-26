import 'dart:ui' show ImageFilter;

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
    // Closed (finished) events stay in the list, dimmed and blurred, but can't be opened.
    final closed = e.isPast;
    final card = AppCard(
      padding: const EdgeInsets.all(12),
      onTap: closed
          ? () => toast(context, 'This event is closed', icon: Icons.lock_clock_rounded, color: AppColors.steel)
          : () => openEvent(context, e),
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
                    child: closed
                        ? ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: ColorFiltered(colorFilter: _greyscale, child: EventImage(event: e, icon: categoryIcon(e.category), iconSize: 34)),
                          )
                        : EventImage(event: e, icon: categoryIcon(e.category), iconSize: 34),
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
                if (e.isLive) ...[
                  const LiveBadge(compact: true),
                  const SizedBox(height: 8),
                ],
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
                    if (closed)
                      const TagChip(label: 'Closed', small: true, color: AppColors.steel, icon: Icons.lock_rounded)
                    else if (registered)
                      const TagChip(label: 'Registered', small: true, color: AppColors.green, icon: Icons.check_rounded)
                    else
                      _RegisterButton(event: e),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!closed) return card;
    return Opacity(
      opacity: 0.55,
      child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6), child: card),
    );
  }
}

const _greyscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

/// Small Register button on an event card. Registers without opening the event.
class _RegisterButton extends StatefulWidget {
  const _RegisterButton({required this.event});
  final ClientaEvent event;

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _busy = false;

  Future<void> _register() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Store.instance.toggleRegistration(widget.event.id);
    toast(
      context,
      widget.event.inviteOnly ? 'Request sent for ${widget.event.title}' : 'You’re registered for ${widget.event.title}',
      icon: Icons.how_to_reg_rounded,
      color: AppColors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _register,
      scale: 0.92,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else
              const Icon(Icons.how_to_reg_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 5),
            const Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
        ),
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
