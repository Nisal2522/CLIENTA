import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../data/store.dart';
import '../chats/chat_widgets.dart';

class _AiMessage {
  _AiMessage(this.text, {required this.fromAi, this.error = false}) : time = DateTime.now();
  final String text;
  final bool fromAi;
  final bool error;
  final DateTime time;
}

class _Conversation {
  _Conversation(this.title, this.messages);
  String title;
  final List<_AiMessage> messages;
}

class SupportAiScreen extends StatefulWidget {
  const SupportAiScreen({super.key});

  @override
  State<SupportAiScreen> createState() => _SupportAiScreenState();
}

class _SupportAiScreenState extends State<SupportAiScreen> {
  final _history = <_Conversation>[
    _Conversation('Certificate download', [
      _AiMessage('How do I download my certificate?', fromAi: false),
      _AiMessage(SampleData.aiAnswer('certificate'), fromAi: true),
    ]),
    _Conversation('Venue directions', [
      _AiMessage('Where is the venue?', fromAi: false),
      _AiMessage(SampleData.aiAnswer('venue'), fromAi: true),
    ]),
  ];
  late _Conversation _current = _Conversation('New chat', []);
  bool _thinking = false;
  final _scaffold = GlobalKey<ScaffoldState>();

  Future<void> _ask(String q) async {
    final convo = _current;
    setState(() {
      if (convo.messages.isEmpty) {
        convo.title = q.length > 28 ? '${q.substring(0, 28)}…' : q;
        _history.insert(0, convo);
      }
      convo.messages.add(_AiMessage(q, fromAi: false));
      _thinking = true;
    });
    try {
      final answer = await Store.instance.api.askSupportAi(q);
      if (!mounted) return;
      setState(() => convo.messages.add(_AiMessage(answer, fromAi: true)));
    } catch (e) {
      if (!mounted) return;
      setState(() => convo.messages.add(_AiMessage(
            e is OfflineException ? 'I can’t reach the server while you’re offline. Please reconnect and try again.' : 'Sorry, something went wrong. Please try again.',
            fromAi: true,
            error: true,
          )));
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final msgs = _current.messages;
    return Scaffold(
      key: _scaffold,
      endDrawer: _HistoryDrawer(
        history: _history,
        onSelect: (c) {
          Navigator.pop(context);
          setState(() => _current = c);
        },
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(12, MediaQuery.paddingOf(context).top + 8, 12, 10),
            child: Row(
              children: [
                const BackBtn(),
                const SizedBox(width: 10),
                const _AiOrb(size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Support AI', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleMedium),
                      Row(children: [const PulseDot(color: AppColors.green, size: 6), Flexible(child: Text('Online · replies instantly', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall))]),
                    ],
                  ),
                ),
                CircleIconBtn(icon: Icons.add_comment_rounded, size: 40, onTap: () => setState(() => _current = _Conversation('New chat', []))),
                const SizedBox(width: 8),
                CircleIconBtn(icon: Icons.history_rounded, size: 40, onTap: () => _scaffold.currentState?.openEndDrawer()),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: msgs.isEmpty
                  ? _Welcome(key: const ValueKey('w'), onAsk: _ask)
                  : ListView(
                      key: ValueKey(_current),
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      children: [
                        if (_thinking)
                          const FadeSlideIn(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [_AiOrb(size: 32), SizedBox(width: 8), _Bubble(child: TypingDots())]),
                            ),
                          ),
                        for (final m in msgs.reversed) _AiBubble(key: ObjectKey(m), message: m, animate: identical(m, msgs.last) && m.fromAi),
                      ],
                    ),
            ),
          ),
          if (msgs.isNotEmpty && !_thinking)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  for (final s in SampleData.aiSuggestions.where((s) => !msgs.any((m) => m.text == s)))
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 6),
                      child: ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        onPressed: () => _ask(s),
                        backgroundColor: pal.surface,
                        side: BorderSide(color: pal.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          ChatInputBar(hint: 'Ask CLIENTA anything…', onSend: _ask),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({super.key, required this.onAsk});
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      children: [
        const Center(child: Floating(child: _AiOrb(size: 110))),
        const SizedBox(height: 22),
        FadeSlideIn(child: Text('How can I help you today?', textAlign: TextAlign.center, style: context.tt.headlineSmall)),
        const SizedBox(height: 8),
        FadeSlideIn(
          index: 1,
          child: Text('Ask about events, certificates, meetings, standards or your account.', textAlign: TextAlign.center, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < SampleData.aiSuggestions.length; i++)
          FadeSlideIn(
            index: 2 + i,
            child: AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => onAsk(SampleData.aiSuggestions[i]),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(SampleData.aiSuggestions[i], style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                  Icon(Icons.north_east_rounded, size: 18, color: pal.textFaint),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Center(child: Text('AI answers may be incomplete. Prototype uses sample responses.', textAlign: TextAlign.center, style: context.tt.bodySmall)),
      ],
    );
  }
}

class _AiBubble extends StatefulWidget {
  const _AiBubble({super.key, required this.message, required this.animate});
  final _AiMessage message;
  final bool animate;

  @override
  State<_AiBubble> createState() => _AiBubbleState();
}

class _AiBubbleState extends State<_AiBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.message.text.length * 12).clamp(300, 2200)),
  );

  @override
  void initState() {
    super.initState();
    widget.animate ? _c.forward() : _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final pal = context.pal;
    if (!m.fromAi) {
      return MessageBubble(
        message: ChatMessage(id: 'ai-user-${m.time.microsecondsSinceEpoch}', senderId: 'me', time: m.time, text: m.text),
        animate: true,
      );
    }
    return FadeSlideIn(
      offset: const Offset(-0.1, 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const _AiOrb(size: 32),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bubble(
                    error: m.error,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (_, _) {
                        final n = (m.text.length * _c.value).round();
                        return Text.rich(_rich(m.text.substring(0, n), pal.text), style: TextStyle(height: 1.5, fontSize: 14.5, color: pal.text));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(fmtTime(m.time), style: context.tt.labelSmall?.copyWith(color: pal.textFaint)),
                        const SizedBox(width: 10),
                        GestureDetector(onTap: () => toast(context, 'Thanks for the feedback!', icon: Icons.thumb_up_rounded), child: Icon(Icons.thumb_up_alt_outlined, size: 15, color: pal.textFaint)),
                        const SizedBox(width: 8),
                        GestureDetector(onTap: () => toast(context, 'We’ll use this to improve answers', icon: Icons.thumb_down_rounded), child: Icon(Icons.thumb_down_alt_outlined, size: 15, color: pal.textFaint)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Minimal **bold** markdown support.
  TextSpan _rich(String s, Color color) {
    final parts = s.split('**');
    return TextSpan(children: [
      for (var i = 0; i < parts.length; i++)
        TextSpan(text: parts[i], style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w800) : null),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.child, this.error = false});
  final Widget child;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: error ? AppColors.red.withValues(alpha: 0.1) : pal.surface,
        border: Border.all(color: error ? AppColors.red.withValues(alpha: 0.4) : pal.border.withValues(alpha: 0.7)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(6)),
      ),
      child: child,
    );
  }
}

class _AiOrb extends StatelessWidget {
  const _AiOrb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35), blurRadius: size * 0.4)],
      ),
      alignment: Alignment.center,
      child: BotIcon(size: size * 0.62),
    );
  }
}

class _HistoryDrawer extends StatelessWidget {
  const _HistoryDrawer({required this.history, required this.onSelect});
  final List<_Conversation> history;
  final ValueChanged<_Conversation> onSelect;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Drawer(
      backgroundColor: pal.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Chat history', style: context.tt.titleLarge),
            ),
            Expanded(
              child: history.isEmpty
                  ? StateView.empty(icon: Icons.history_rounded, title: 'No history', message: 'Your conversations will appear here.')
                  : ListView(
                      children: [
                        for (final c in history)
                          ListTile(
                            leading: const IconBadge(icon: Icons.chat_bubble_outline_rounded, size: 38),
                            title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                            subtitle: Text('${c.messages.length} messages', style: context.tt.bodySmall),
                            onTap: () => onSelect(c),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Contact support',
                icon: Icons.support_agent_rounded,
                variant: ButtonVariant.secondary,
                onPressed: () => toast(context, 'Support ticket created. We’ll email you shortly', icon: Icons.mark_email_read_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
