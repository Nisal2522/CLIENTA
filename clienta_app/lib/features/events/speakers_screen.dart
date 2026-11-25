import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'agenda_screen.dart';
import 'section_scaffold.dart';

class SpeakersScreen extends StatelessWidget {
  const SpeakersScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final e = store.event(eventId);
    final speakers = e.speakerIds.map(store.speaker).whereType<Speaker>().toList();
    return SectionScaffold(
      title: 'Speakers',
      subtitle: '${speakers.length} speakers · ${e.title}',
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        itemCount: speakers.length,
        itemBuilder: (_, i) => FadeSlideIn(index: i, child: _SpeakerCard(speaker: speakers[i])),
      ),
    );
  }
}

/// Speaker card: navy header band with the name, a photo that pops out of
/// the card on the left, role and company beside it, and the full biography
/// below. Same layout for every speaker; tapping opens their sessions.
class _SpeakerCard extends StatelessWidget {
  const _SpeakerCard({required this.speaker});
  final Speaker speaker;

  static const double _avatar = 86;
  static const double _overlap = 18;
  static const double _infoInset = 16 + _avatar + 14;

  @override
  Widget build(BuildContext context) {
    final s = speaker;
    final pal = context.pal;
    return Pressable(
      onTap: () => showSpeakerSheet(context, s),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: _overlap),
              decoration: BoxDecoration(
                color: pal.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: pal.border.withValues(alpha: 0.8)),
                boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name on a navy gradient band.
                  Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.fromLTRB(_infoInset, 12, 16, 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.navy700, AppColors.navy900]),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                  ),
                  // Role and company beside the photo.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_infoInset, 10, 16, 0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: _avatar - 48 - _overlap + 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: context.tt.bodyMedium?.copyWith(color: AppColors.blue, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(s.company, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  // Full biography across the card.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Text(s.bio, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted, height: 1.55)),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              child: Hero(
                tag: 'speaker-${s.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.navy900.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: AppAvatar(name: s.name, url: s.photoUrl, size: _avatar, ring: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSpeakerSheet(BuildContext context, Speaker s) {
  final store = Store.instance;
  final sessions = <(ClientaEvent, Session)>[
    for (final e in store.events)
      for (final ss in e.sessions.where((x) => x.speakerIds.contains(s.id))) (e, ss),
  ];
  showAppSheet(
    context,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.94,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
        children: [
          Center(child: Hero(tag: 'speaker-${s.id}', child: AppAvatar(name: s.name, url: s.photoUrl, size: 110, ring: true))),
          const SizedBox(height: 14),
          Center(child: Text(s.name, style: ctx.tt.headlineSmall)),
          const SizedBox(height: 4),
          Center(child: Text('${s.title} · ${s.company}', style: ctx.tt.bodyMedium?.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700))),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in s.topics) TagChip(label: t, color: AppColors.purple)],
          ),
          const SizedBox(height: 18),
          Text('Biography', style: ctx.tt.titleMedium),
          const SizedBox(height: 8),
          Text(s.bio, style: ctx.tt.bodyLarge?.copyWith(color: ctx.pal.textMuted)),
          const SizedBox(height: 18),
          Text('Sessions', style: ctx.tt.titleMedium),
          const SizedBox(height: 8),
          for (final (e, ss) in sessions)
            AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              onTap: () => showSessionSheet(ctx, ss),
              child: Row(
                children: [
                  IconBadge(icon: Icons.mic_rounded, color: ss.status == SessionStatus.live ? AppColors.red : AppColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ss.title, style: ctx.tt.titleSmall),
                        Text('${e.title} · ${fmtDate(ss.start)} ${fmtTime(ss.start)}', style: ctx.tt.bodySmall),
                      ],
                    ),
                  ),
                  if (ss.status == SessionStatus.live) const LiveBadge(compact: true),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
