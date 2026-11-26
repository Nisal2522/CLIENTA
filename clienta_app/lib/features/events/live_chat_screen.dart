import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../chats/chat_widgets.dart';
import 'event_card.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  Person? _typing;
  final _rnd = math.Random();

  static const _replies = [
    'Great point! 👏',
    'Totally agree — the panel is packed right now.',
    'Does anyone know if this session is recorded?',
    'See you at the networking break ☕',
    'Thanks for sharing!',
  ];

  List<ChatMessage> get _messages =>
      Store.instance.liveChats.putIfAbsent(widget.eventId, () => []);

  void _send(String text, {MessageType type = MessageType.text, String? file}) {
    Store.instance.sendMessage(
      _messages,
      ChatMessage(
        id: 'lc${DateTime.now().microsecondsSinceEpoch}',
        senderId: 'me',
        time: DateTime.now(),
        text: text,
        type: type,
        attachmentName: file,
      ),
    );
    _simulateReply();
  }

  Future<void> _simulateReply() async {
    final people = Store.instance.participants;
    if (people.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final p = people[_rnd.nextInt(people.length)];
    setState(() => _typing = p);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() => _typing = null);
    Store.instance.sendMessage(
      _messages,
      ChatMessage(
        id: 'lr${DateTime.now().microsecondsSinceEpoch}',
        senderId: p.id,
        time: DateTime.now(),
        text: _replies[_rnd.nextInt(_replies.length)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView(
        keys: const ['events', 'chats'],
        builder: (context) {
          final e = Store.instance.event(widget.eventId);
          final pal = context.pal;
          final items = buildMessageList(
            context,
            _messages,
            showSender: true,
          ).reversed.toList();
          return Column(
            children: [
              SizedBox(
                height: 180 + MediaQuery.paddingOf(context).top,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EventImage(event: e),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black26,
                            pal.bg.withValues(alpha: 0.2),
                            pal.bg,
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: MediaQuery.paddingOf(context).top + 8,
                      child: const BackBtn(light: true),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const LiveBadge(),
                                const SizedBox(height: 6),
                                Text(
                                  'Live Chat',
                                  style: context.tt.headlineSmall?.copyWith(
                                    color: pal.dark ? Colors.white : pal.text,
                                  ),
                                ),
                                Text(e.title, style: context.tt.bodySmall),
                              ],
                            ),
                          ),
                          GlassCard(
                            radius: 16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const PulseDot(color: AppColors.green, size: 7),
                                Text(
                                  '${86 + _messages.length} online',
                                  style: context.tt.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  children: [
                    if (_typing != null)
                      TypingBubble(name: _typing!.name, url: _typing!.photoUrl),
                    ...items,
                  ],
                ),
              ),
              ChatInputBar(
                hint: 'Message everyone…',
                onSend: _send,
                onAttach: (f) =>
                    _send('', type: MessageType.attachment, file: f),
              ),
            ],
          );
        },
      ),
    );
  }
}
