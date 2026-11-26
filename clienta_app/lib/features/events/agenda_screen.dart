import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'section_scaffold.dart';
import 'speakers_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int _day = 0;
  bool _mine = false;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events'],
      builder: (context) {
        final store = Store.instance;
        final e = store.event(widget.eventId);
        final days = <DateTime>[];
        for (final s in e.sessions) {
          if (!days.any((d) => sameDay(d, s.start))) days.add(DateTime(s.start.year, s.start.month, s.start.day));
        }
        days.sort();
        final day = days.isEmpty ? e.start : days[_day.clamp(0, days.length - 1)];
        final sessions = e.sessions.where((s) => sameDay(s.start, day) && (!_mine || store.savedSessions.contains(s.id))).toList()
          ..sort((a, b) => a.start.compareTo(b.start));

        return SectionScaffold(
          title: 'Agenda',
          subtitle: e.title,
          actions: [
            CircleIconBtn(
              icon: _mine ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 40,
              iconColor: _mine ? AppColors.blue : null,
              onTap: () => setState(() => _mine = !_mine),
            ),
          ],
          body: Column(
            children: [
              if (days.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: ChoiceChips(
                    options: [for (var i = 0; i < days.length; i++) 'Day ${i + 1} · ${days[i].day} ${monthShort(days[i])}'],
                    selected: 'Day ${_day + 1} · ${day.day} ${monthShort(day)}',
                    onSelected: (v) => setState(() => _day = int.parse(v.split(' ')[1]) - 1),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Agenda · ${fmtDateFull(day)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      Text(_mine ? 'My agenda' : '${sessions.length} sessions', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 0), child: _Legend()),
              Expanded(
                child: sessions.isEmpty
                    ? StateView.empty(
                        icon: Icons.bookmark_add_outlined,
                        title: _mine ? 'Your agenda is empty' : 'No sessions',
                        message: _mine ? 'Tap a session and choose “Add to my agenda” to build your personal schedule.' : 'No sessions scheduled for this day.',
                        actionLabel: _mine ? 'Show all sessions' : null,
                        onAction: () => setState(() => _mine = false),
                      )
                    : ListView.builder(
                        key: ValueKey('$_day-$_mine'),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 20, 40),
                        itemCount: sessions.length,
                        itemBuilder: (_, i) => FadeSlideIn(
                          index: i,
                          child: _TimelineItem(session: sessions[i], first: i == 0, last: i == sessions.length - 1),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String t, {bool pulse = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            pulse ? const PulseDot(size: 7) : Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(t, style: context.tt.labelSmall?.copyWith(color: context.pal.textMuted)),
          ],
        );
    return Row(
      children: [
        item(context.pal.textFaint, 'Completed'),
        const SizedBox(width: 14),
        item(AppColors.red, 'Live', pulse: true),
        const SizedBox(width: 14),
        item(AppColors.blue, 'Upcoming'),
      ],
    );
  }
}

Color statusColor(BuildContext context, SessionStatus s) => switch (s) {
      SessionStatus.completed => context.pal.textFaint,
      SessionStatus.live => AppColors.red,
      SessionStatus.upcoming => AppColors.blue,
    };

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.session, required this.first, required this.last});
  final Session session;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final pal = context.pal;
    final store = Store.instance;
    final color = statusColor(context, s.status);
    final speakers = s.speakerIds.map(store.speaker).whereType<Speaker>().toList();
    final done = s.status == SessionStatus.completed;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmtTime(s.start), style: context.tt.labelLarge?.copyWith(fontSize: 13, color: done ? pal.textFaint : pal.text)),
                  Text(fmtTime(s.end), style: context.tt.labelSmall?.copyWith(color: pal.textFaint)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: first ? 20 : 0,
                  bottom: last ? null : 0,
                  height: last ? 20 : null,
                  child: Container(width: 2, color: pal.border),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: s.status == SessionStatus.live
                      ? const PulseDot(size: 11)
                      : Container(
                          margin: const EdgeInsets.all(4.5),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? color : pal.bg,
                            border: Border.all(color: color, width: 2.5),
                          ),
                          child: done ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                color: s.status == SessionStatus.live ? Color.alphaBlend(AppColors.red.withValues(alpha: 0.07), pal.surface) : null,
                onTap: () => showSessionSheet(context, s),
                child: Opacity(
                  opacity: done ? 0.7 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TagChip(label: s.type, small: true, color: color == pal.textFaint ? AppColors.steel : color),
                          const SizedBox(width: 6),
                          if (s.status == SessionStatus.live) const LiveBadge(compact: true),
                          const Spacer(),
                          if (store.savedSessions.contains(s.id)) const Icon(Icons.bookmark_rounded, size: 18, color: AppColors.blue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(s.title, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                      if (speakers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(speakers.map((sp) => '${sp.name}, ${sp.title}').join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(color: AppColors.blue)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.meeting_room_outlined, size: 14, color: pal.textFaint),
                          const SizedBox(width: 4),
                          Text(s.room, style: context.tt.bodySmall),
                          const Spacer(),
                          if (speakers.isNotEmpty)
                            SizedBox(
                              height: 26,
                              width: 26.0 + (speakers.length - 1) * 16,
                              child: Stack(
                                children: [
                                  for (var i = 0; i < speakers.length; i++)
                                    Positioned(left: i * 16.0, child: AppAvatar(name: speakers[i].name, url: speakers[i].photoUrl, size: 26)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showSessionSheet(BuildContext context, Session s) {
  showAppSheet(
    context,
    builder: (ctx) => ListenableBuilder(
      listenable: Store.instance,
      builder: (ctx, _) {
        final store = Store.instance;
        final saved = store.savedSessions.contains(s.id);
        final speakers = s.speakerIds.map(store.speaker).whereType<Speaker>().toList();
        final statusLabel = switch (s.status) {
          SessionStatus.completed => 'Completed',
          SessionStatus.live => 'Live now',
          SessionStatus.upcoming => 'Upcoming',
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TagChip(label: s.type, color: AppColors.blue),
                  const SizedBox(width: 6),
                  if (s.status == SessionStatus.live) const LiveBadge() else TagChip(label: statusLabel, color: statusColor(ctx, s.status) == ctx.pal.textFaint ? AppColors.steel : AppColors.blue),
                ],
              ),
              const SizedBox(height: 12),
              Text(s.title, style: ctx.tt.headlineSmall),
              const SizedBox(height: 10),
              InfoRow(icon: Icons.schedule_rounded, label: fmtDateFull(s.start), value: '${fmtTime12(s.start)} – ${fmtTime12(s.end)}'),
              InfoRow(icon: Icons.meeting_room_rounded, label: 'Room', value: s.room, color: AppColors.blueDeep),
              const SizedBox(height: 8),
              Text(s.description, style: ctx.tt.bodyLarge?.copyWith(color: ctx.pal.textMuted)),
              if (speakers.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Speakers', style: ctx.tt.titleMedium),
                const SizedBox(height: 8),
                for (final sp in speakers)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: AppAvatar(name: sp.name, url: sp.photoUrl, size: 44),
                    title: Text(sp.name, style: ctx.tt.titleSmall),
                    subtitle: Text('${sp.title}, ${sp.company}', style: ctx.tt.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showSpeakerSheet(ctx, sp),
                  ),
              ],
              const SizedBox(height: 14),
              if (s.status != SessionStatus.completed)
                AppButton(
                  label: saved ? 'Remove from my agenda' : 'Add to my agenda',
                  icon: saved ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
                  variant: saved ? ButtonVariant.secondary : ButtonVariant.primary,
                  onPressed: () {
                    store.toggleSavedSession(s.id);
                    toast(ctx, saved ? 'Removed from your agenda' : 'Added to your agenda — we’ll remind you 10 min before');
                  },
                )
              else
                AppButton(label: 'View session resources', icon: Icons.folder_open_rounded, variant: ButtonVariant.secondary, onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        );
      },
    ),
  );
}
