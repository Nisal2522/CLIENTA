import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../services/contacts_screen.dart';
import 'call_screen.dart';
import 'chat_widgets.dart';
import 'schedule_meeting_sheet.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.threadId});
  final String threadId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  bool _typing = false;
  ChatMessage? _replyTo;
  final _rnd = math.Random();

  static const _replies = [
    'Sounds good, thanks!',
    'Let me check and get back to you shortly.',
    'Great, I’ll bring the documents.',
    'Perfect 👍',
    'Thanks for reaching out!',
  ];

  ChatThread get _thread => Store.instance.threads.firstWhere((t) => t.id == widget.threadId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Store.instance.isLoaded(['chats'])) Store.instance.markThreadRead(_thread);
    });
  }

  String get _otherId => _thread.participantIds.first;

  void _send(ChatMessage m) {
    Store.instance.sendMessage(_thread.messages, m);
    _simulateReply(m);
  }

  Future<void> _simulateReply(ChatMessage sent) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _typing = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _typing = false);
    final t = _thread;
    final from = t.isGroup ? t.participantIds[_rnd.nextInt(t.participantIds.length)] : _otherId;
    // Sometimes the other side also reacts to what you sent.
    if (_rnd.nextDouble() < 0.35) Store.instance.react(sent, ['👍', '❤️', '😂'][_rnd.nextInt(3)], by: from);
    if (sent.type == MessageType.meeting && sent.meeting != null) {
      Store.instance.setMeetingStatus(sent.meeting!, MeetingStatus.accepted);
      Store.instance.sendMessage(t.messages, ChatMessage(id: 'r${DateTime.now().microsecondsSinceEpoch}', senderId: from, time: DateTime.now(), text: 'Accepted! See you then.'));
    } else {
      Store.instance.sendMessage(t.messages, ChatMessage(id: 'r${DateTime.now().microsecondsSinceEpoch}', senderId: from, time: DateTime.now(), text: _replies[_rnd.nextInt(_replies.length)]));
    }
  }

  String _newId() => 'm${DateTime.now().microsecondsSinceEpoch}';

  void _startReply(ChatMessage m) {
    if (m.type == MessageType.system) return;
    setState(() => _replyTo = m);
  }

  void _sendWithReply(ChatMessage Function(ChatMessage? replyTo) build) {
    final reply = _replyTo;
    setState(() => _replyTo = null);
    _send(build(reply));
  }

  void _messageActions(BuildContext bubbleCtx, ChatMessage m) {
    if (m.type == MessageType.system) return;
    showMessageActions(
      context,
      anchor: bubbleCtx,
      message: m,
      onReply: () => _startReply(m),
      onReact: (e) => Store.instance.react(m, e),
    );
  }

  void _call() {
    final t = _thread;
    final p = t.isGroup ? null : Store.instance.person(_otherId);
    push(context, CallScreen(title: t.title, photoUrl: p?.photoUrl, isGroup: t.isGroup));
  }

  Future<void> _schedule() async {
    final p = Store.instance.person(_otherId);
    final invite = await showAppSheet<MeetingInvite>(context, builder: (_) => ScheduleMeetingSheet(withName: _thread.isGroup ? _thread.title : (p?.name ?? 'participant')));
    if (invite == null || !mounted) return;
    _send(ChatMessage(id: 'm${DateTime.now().microsecondsSinceEpoch}', senderId: 'me', time: DateTime.now(), type: MessageType.meeting, meeting: invite));
    toast(context, 'Invitation sent', icon: Icons.event_available_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView(
        keys: const ['chats'],
        builder: (context) {
          final t = _thread;
          final pal = context.pal;
          final other = t.isGroup ? null : Store.instance.person(_otherId);
          final items = buildMessageList(context, t.messages, showSender: t.isGroup, onReply: _startReply, onLongPress: _messageActions).reversed.toList();
          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12, MediaQuery.paddingOf(context).top + 8, 12, 10),
                decoration: BoxDecoration(color: pal.surface, border: Border(bottom: BorderSide(color: pal.border.withValues(alpha: 0.6)))),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Pressable(
                        onTap: other == null ? null : () => showPersonSheet(context, other),
                        child: Row(
                          children: [
                            if (t.isGroup)
                              const IconBadge(icon: Icons.groups_rounded, size: 42, circle: true, solid: true, color: AppColors.darkGrey)
                            else
                              AppAvatar(name: t.title, url: other?.photoUrl, size: 42, online: other?.online ?? false),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      _typing ? 'typing…' : (t.isGroup ? '${t.participantIds.length + 1} members' : (other?.online ?? false ? 'Online' : (other?.title ?? ''))),
                                      key: ValueKey(_typing),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.tt.bodySmall?.copyWith(color: _typing || (other?.online ?? false) ? AppColors.green : null),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CircleIconBtn(icon: Icons.call_rounded, size: 40, iconColor: AppColors.blue, onTap: _call),
                  ],
                ),
              ),
              Expanded(
                child: t.messages.isEmpty && !_typing
                    ? StateView.empty(
                        icon: Icons.waving_hand_rounded,
                        title: 'Say hello 👋',
                        message: 'Start the conversation or schedule a meeting with ${t.title.split(' ').first}.',
                        actionLabel: 'Schedule meeting',
                        onAction: _schedule,
                      )
                    : ListView(
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        children: [
                          if (_typing) TypingBubble(name: other?.name ?? t.title, url: other?.photoUrl),
                          ...items,
                        ],
                      ),
              ),
              ChatInputBar(
                replyTo: _replyTo,
                onCancelReply: () => setState(() => _replyTo = null),
                onSend: (text) => _sendWithReply((r) => ChatMessage(id: _newId(), senderId: 'me', time: DateTime.now(), text: text, replyTo: r)),
                onAttach: (f) => _sendWithReply((r) => ChatMessage(id: _newId(), senderId: 'me', time: DateTime.now(), type: MessageType.attachment, attachmentName: f, replyTo: r)),
                onMeeting: _schedule,
              ),
            ],
          );
        },
      ),
    );
  }
}
