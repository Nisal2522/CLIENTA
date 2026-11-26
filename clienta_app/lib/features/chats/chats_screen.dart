import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../events/event_card.dart';
import '../events/live_chat_screen.dart';
import '../events/section_scaffold.dart';
import '../shell/main_shell.dart';
import 'conversation_screen.dart';
import 'meetings_screen.dart';
import 'new_message_screen.dart';
import 'rsvp_dialog.dart';

/// Chat list. Used as a bottom-nav tab and (with [standalone]) from an event.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, this.standalone = false});
  final bool standalone;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _filter = 'All';
  String _query = '';

  void _newChat() => push(context, const NewMessageScreen());

  @override
  Widget build(BuildContext context) {
    final body = AsyncView(
      keys: const ['events', 'chats'],
      builder: (context) {
        final store = Store.instance;
        final threads = store.threads.where((t) {
          final f = switch (_filter) {
            'Unread' => t.unread > 0,
            'Groups' => t.isGroup,
            _ => true,
          };
          return f && (_query.isEmpty || t.title.toLowerCase().contains(_query.toLowerCase()));
        }).toList()
          ..sort((a, b) {
            // Pinned chats stay on top, then newest first.
            final pin = (store.isPinned(b) ? 1 : 0) - (store.isPinned(a) ? 1 : 0);
            if (pin != 0) return pin;
            return (b.last?.time ?? DateTime(0)).compareTo(a.last?.time ?? DateTime(0));
          });
        final meetings = [
          for (final t in store.threads)
            for (final m in t.messages.where((m) => m.type == MessageType.meeting && m.meeting != null && m.meeting!.status != MeetingStatus.declined)) (t, m),
        ]..sort((a, b) => a.$2.meeting!.start.compareTo(b.$2.meeting!.start));
        final live = store.events.where((e) => store.isRegistered(e.id) && !e.isPast).firstOrNull;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (!widget.standalone)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 20, 0),
                  child: FadeSlideIn(
                    child: Row(
                      children: [
                        Expanded(child: Text('Chats', style: context.tt.headlineMedium)),
                        CircleIconBtn(icon: Icons.edit_square, onTap: _newChat),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: SearchField(hint: 'Search conversations', onChanged: (v) => setState(() => _query = v)),
              ),
            ),
            if (meetings.isNotEmpty && _query.isEmpty) ...[
              SliverToBoxAdapter(child: SectionHeader(title: 'Meetings', action: 'See all', onAction: () => push(context, const MeetingsScreen()), padding: const EdgeInsets.fromLTRB(20, 20, 12, 10))),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 92,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: meetings.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => FadeSlideIn(index: i, offset: const Offset(0.2, 0), child: _MeetingChip(thread: meetings[i].$1, message: meetings[i].$2)),
                  ),
                ),
              ),
            ],
            if (live != null && _query.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: FadeSlideIn(
                    index: 1,
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      gradient: LinearGradient(colors: [AppColors.blue.withValues(alpha: 0.16), AppColors.blueDeep.withValues(alpha: 0.06)]),
                      onTap: () => push(context, LiveChatScreen(eventId: live.id)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: ClipRRect(borderRadius: BorderRadius.circular(14), child: EventImage(event: live, icon: Icons.sensors_rounded, iconSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Flexible(child: Text('${live.title} · Live Chat', overflow: TextOverflow.ellipsis, style: context.tt.titleSmall)), const SizedBox(width: 6), const LiveBadge(compact: true)]),
                                const SizedBox(height: 3),
                                Text(store.liveChats[live.id]?.lastOrNull?.text ?? 'Join the conversation', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: ChoiceChips(options: const ['All', 'Unread', 'Groups'], selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              ),
            ),
            if (threads.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StateView.empty(
                  icon: Icons.forum_outlined,
                  title: _filter == 'Unread' ? 'All caught up!' : 'No conversations',
                  message: _filter == 'Unread' ? 'You have no unread messages.' : 'Start a conversation with event participants.',
                  actionLabel: 'New message',
                  onAction: _newChat,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, widget.standalone ? 40 : kNavBarSpace),
                sliver: SliverList.builder(
                  itemCount: threads.length,
                  itemBuilder: (_, i) => FadeSlideIn(key: ValueKey(threads[i].id), index: i, child: _ThreadTile(thread: threads[i])),
                ),
              ),
          ],
        );
      },
    );

    if (!widget.standalone) return body;
    return SectionScaffold(
      title: 'Chats & Meetings',
      subtitle: 'Message participants or schedule a meeting',
      floating: GradientFab(icon: Icons.edit_square, label: 'New', onTap: _newChat),
      body: body,
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread});
  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final t = thread;
    final pal = context.pal;
    final store = Store.instance;
    final other = t.isGroup ? null : store.person(t.participantIds.first);
    final last = t.last;
    final preview = switch (last?.type) {
      MessageType.meeting => '📅 Meeting: ${last!.meeting?.title ?? ''}',
      MessageType.attachment => '📎 ${last!.attachmentName}',
      null => 'No messages yet',
      _ => last!.text,
    };
    final prefix = last?.senderId == 'me' ? 'You: ' : '';
    final pinned = store.isPinned(t);
    return Pressable(
      scale: 0.98,
      onTap: () => push(context, ConversationScreen(threadId: t.id)),
      onLongPress: () => _options(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            if (t.isGroup)
              const IconBadge(icon: Icons.groups_rounded, size: 54, circle: true, solid: true, color: AppColors.darkGrey)
            else
              AppAvatar(name: t.title, url: other?.photoUrl, size: 54, online: other?.online ?? false),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 15))),
                      Text(last == null ? '' : chatStamp(last.time), style: context.tt.bodySmall?.copyWith(color: t.unread > 0 ? AppColors.blue : pal.textFaint, fontWeight: t.unread > 0 ? FontWeight.w700 : null)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$prefix$preview',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.tt.bodySmall?.copyWith(color: t.unread > 0 ? pal.text : pal.textMuted, fontWeight: t.unread > 0 ? FontWeight.w600 : null),
                        ),
                      ),
                      if (pinned)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Transform.rotate(angle: 0.6, child: Icon(Icons.push_pin_rounded, size: 16, color: pal.textFaint)),
                        ),
                      if (t.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(10)),
                          child: Text('${t.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on _ThreadTile {
  void _options(BuildContext context) {
    final store = Store.instance;
    final t = thread;
    final pinned = store.isPinned(t);
    final other = t.isGroup ? null : store.person(t.participantIds.first);
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (t.isGroup)
                  const IconBadge(icon: Icons.groups_rounded, size: 42, circle: true, solid: true, color: AppColors.darkGrey)
                else
                  AppAvatar(name: t.title, url: other?.photoUrl, size: 42),
                const SizedBox(width: 12),
                Expanded(child: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ctx.tt.titleLarge)),
              ],
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(pinned ? Icons.push_pin_outlined : Icons.push_pin_rounded, color: AppColors.blue),
              title: Text(pinned ? 'Unpin chat' : 'Pin chat', style: ctx.tt.titleSmall),
              onTap: () {
                Navigator.pop(ctx);
                if (store.togglePin(t)) {
                  toast(context, pinned ? 'Chat unpinned' : 'Chat pinned', icon: Icons.push_pin_rounded);
                } else {
                  toast(context, 'You can only pin up to ${Store.maxPinnedThreads} chats', icon: Icons.info_outline_rounded);
                }
              },
            ),
            if (t.unread > 0)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.mark_chat_read_rounded, color: AppColors.blue),
                title: Text('Mark as read', style: ctx.tt.titleSmall),
                onTap: () {
                  Navigator.pop(ctx);
                  store.markThreadRead(t);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MeetingChip extends StatelessWidget {
  const _MeetingChip({required this.thread, required this.message});
  final ChatThread thread;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final m = message.meeting!;
    // An invite someone sent you that you haven't answered yet needs an RSVP.
    final needsRsvp = message.senderId != 'me' && m.status == MeetingStatus.pending;
    final (label, color) = switch (m.status) {
      MeetingStatus.pending when needsRsvp => ('RSVP', AppColors.blue),
      MeetingStatus.pending => ('Pending', AppColors.orange),
      MeetingStatus.accepted => ('Confirmed', AppColors.green),
      MeetingStatus.declined => ('Declined', AppColors.red),
    };
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => needsRsvp ? showRsvpDialog(context, m, fromId: message.senderId) : push(context, ConversationScreen(threadId: thread.id)),
      child: SizedBox(
        width: 210,
        child: Row(
          children: [
            Container(
              width: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('${m.start.day}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, height: 1.1)),
                  Text(monthShort(m.start).toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                  Text('${fmtTime12(m.start)} · ${thread.title.split(' ').first}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                  if (needsRsvp) ...[
                    const SizedBox(height: 5),
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text('RSVP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.6)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 3),
                    Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: context.tt.labelSmall?.copyWith(color: color))]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
