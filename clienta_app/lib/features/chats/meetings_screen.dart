import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../events/section_scaffold.dart';
import '../services/contacts_screen.dart';
import 'chats_screen.dart';
import 'conversation_screen.dart';
import 'rsvp_dialog.dart';
import 'schedule_meeting_sheet.dart';

/// All meeting invitations (sent and received) with their status.
class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  String _filter = 'All';

  Future<void> _newMeeting() async {
    final p = await push<Person>(context, const ContactsScreen(pickMode: true, title: 'Meet with…'));
    if (p == null || !mounted) return;
    final invite = await showAppSheet<MeetingInvite>(context, builder: (_) => ScheduleMeetingSheet(withName: p.name));
    if (invite == null || !mounted) return;
    final store = Store.instance;
    final t = store.threadWith(p.id);
    store.sendMessage(t.messages, ChatMessage(id: 'm${DateTime.now().microsecondsSinceEpoch}', senderId: 'me', time: DateTime.now(), type: MessageType.meeting, meeting: invite));
    setState(() => _filter = 'All');
    toast(context, 'Invitation sent to ${p.name}', icon: Icons.event_available_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: 'Meetings',
      subtitle: 'Invitations you sent and received',
      actions: [
        Pressable(
          onTap: () => push(context, const ChatsScreen(standalone: true)),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Chats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
      floating: Pressable(
        onTap: _newMeeting,
        scale: 0.9,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: AsyncView(
        keys: const ['chats'],
        builder: (context) {
          final store = Store.instance;
          final all = [
            for (final t in store.threads)
              for (final m in t.messages.where((m) => m.type == MessageType.meeting && m.meeting != null)) (t, m),
          ]..sort((a, b) => b.$2.time.compareTo(a.$2.time));
          final items = all.where((x) {
            final st = x.$2.meeting!.status;
            return switch (_filter) {
              'Pending' => st == MeetingStatus.pending,
              'Accepted' => st == MeetingStatus.accepted,
              'Rejected' => st == MeetingStatus.declined,
              _ => true,
            };
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 10),
                child: ChoiceChips(
                  options: const ['All', 'Pending', 'Accepted', 'Rejected'],
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? StateView.empty(
                        icon: Icons.event_busy_rounded,
                        title: _filter == 'All' ? 'No meetings yet' : 'No ${_filter.toLowerCase()} meetings',
                        message: 'Schedule a meeting with a participant using the + button.',
                        actionLabel: 'Schedule meeting',
                        onAction: _newMeeting,
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        itemCount: items.length,
                        itemBuilder: (_, i) => FadeSlideIn(
                          key: ValueKey('$_filter${items[i].$2.id}${items[i].$1.id}'),
                          index: i,
                          child: _MeetingCard(thread: items[i].$1, message: items[i].$2),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeetingCard extends StatefulWidget {
  const _MeetingCard({required this.thread, required this.message});
  final ChatThread thread;
  final ChatMessage message;

  @override
  State<_MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<_MeetingCard> {
  bool _showPeople = false;

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final pal = context.pal;
    final t = widget.thread;
    final m = widget.message.meeting!;
    final mine = widget.message.senderId == 'me';
    final sender = mine ? null : store.person(widget.message.senderId);
    final counterpart = t.isGroup ? null : store.person(t.participantIds.first);
    final who = mine ? (counterpart?.email ?? t.title) : (sender?.email ?? t.title);
    final accent = switch (m.status) {
      MeetingStatus.accepted => AppColors.green,
      MeetingStatus.declined => AppColors.steel,
      MeetingStatus.pending => mine ? AppColors.orange : AppColors.blue,
    };
    final people = <(String, String?, String)>[
      (AppState.instance.user?.name ?? 'You', AppState.instance.user?.photoUrl, 'You'),
      for (final id in t.participantIds)
        if (store.person(id) case final p?) (p.name, p.photoUrl, p.email),
    ];

    Widget pill(Widget child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: pal.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: child,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pal.border.withValues(alpha: 0.8)),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 22, offset: const Offset(0, 10), spreadRadius: -8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(duration: const Duration(milliseconds: 300), width: 5, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Who sent / received it.
                    Pressable(
                      onTap: () => push(context, ConversationScreen(threadId: t.id)),
                      scale: 0.98,
                      child: pill(Row(
                        children: [
                          Expanded(
                            child: Text(
                              mine ? 'To  $who' : who,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                          Icon(mine ? Icons.north_east_rounded : Icons.south_west_rounded, size: 17, color: AppColors.blue),
                        ],
                      )),
                    ),
                    const SizedBox(height: 8),
                    // When.
                    pill(Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 17, color: AppColors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${fmtDate(m.start)}  ·  ${fmtTime(m.start)} – ${fmtTime(m.end)}',
                            style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 12),
                    Text(m.title, style: context.tt.titleMedium),
                    if (m.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(m.description, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 15, color: pal.textMuted),
                        const SizedBox(width: 4),
                        Expanded(child: Text(m.location, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status + calendar.
                    Row(
                      children: [
                        Expanded(child: _StatusArea(meeting: m, mine: mine, fromId: widget.message.senderId)),
                        const SizedBox(width: 10),
                        CircleIconBtn(
                          icon: Icons.calendar_month_rounded,
                          size: 44,
                          color: pal.surfaceAlt,
                          iconColor: m.status == MeetingStatus.accepted ? AppColors.blue : pal.textFaint,
                          onTap: () => m.status == MeetingStatus.accepted
                              ? toast(context, 'Added to your calendar', icon: Icons.calendar_month_rounded)
                              : toast(context, 'Only accepted meetings can be added to your calendar', icon: Icons.info_rounded, color: AppColors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: pal.border.withValues(alpha: 0.7)),
                    // Participants.
                    Pressable(
                      onTap: () => setState(() => _showPeople = !_showPeople),
                      scale: 0.99,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 32,
                              width: 32.0 + (people.length - 1) * 22,
                              child: Stack(
                                children: [
                                  for (var i = 0; i < people.length; i++)
                                    Positioned(
                                      left: i * 22.0,
                                      child: Container(
                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: pal.surface, width: 2)),
                                        child: AppAvatar(name: people[i].$1, url: people[i].$2, size: 28),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text('${people.length} participants', style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                            AnimatedRotation(
                              turns: _showPeople ? 0.5 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: pal.surfaceAlt, shape: BoxShape.circle),
                                child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: pal.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _showPeople
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                children: [
                                  for (final (name, url, sub) in people)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          AppAvatar(name: name, url: url, size: 30),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(name, style: context.tt.titleSmall),
                                                Text(sub, style: context.tt.bodySmall),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
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

class _StatusArea extends StatelessWidget {
  const _StatusArea({required this.meeting, required this.mine, this.fromId});
  final MeetingInvite meeting;
  final bool mine;
  final String? fromId;

  @override
  Widget build(BuildContext context) {
    final m = meeting;
    final Widget child = switch (m.status) {
      MeetingStatus.pending when !mine => _Pill(
          key: const ValueKey('rsvp'),
          label: 'RSVP',
          icon: Icons.event_available_rounded,
          color: AppColors.blue,
          filled: true,
          onTap: () => showRsvpDialog(context, m, fromId: fromId),
        ),
      MeetingStatus.pending => const _Pill(key: ValueKey('wait'), label: 'Awaiting response', icon: Icons.hourglass_top_rounded, color: AppColors.orange),
      MeetingStatus.accepted => const _Pill(key: ValueKey('ok'), label: 'Accepted', icon: Icons.check_circle_rounded, color: AppColors.green),
      MeetingStatus.declined => const _Pill(key: ValueKey('no'), label: 'Rejected', icon: Icons.cancel_rounded, color: AppColors.steel, filled: true),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(a), child: c)),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.label, required this.icon, required this.color, this.filled = false, this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: filled ? Colors.white : color, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
