import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../services/contacts_screen.dart';
import 'chat_widgets.dart';
import 'conversation_screen.dart';
import 'schedule_meeting_sheet.dart';

/// Compose screen: pick one or more people in the "To:" field, type the
/// first message, and send. One person opens a 1:1 chat, several a group.
class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _to = <Person>[];
  final _toCtrl = TextEditingController();
  final _toFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _toFocus.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _toFocus.requestFocus());
  }

  @override
  void dispose() {
    _toCtrl.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  void _add(Person p) {
    setState(() {
      if (!_to.any((x) => x.id == p.id)) _to.add(p);
      _toCtrl.clear();
      _query = '';
    });
  }

  void _remove(Person p) => setState(() => _to.removeWhere((x) => x.id == p.id));

  Future<void> _browse() async {
    final p = await push<Person>(context, const ContactsScreen(pickMode: true, title: 'Add people'));
    if (p != null && mounted) _add(p);
  }

  bool _hasRecipients() {
    if (_to.isNotEmpty) return true;
    toast(context, 'Add at least one person in "To:"', icon: Icons.info_outline_rounded, color: AppColors.orange);
    _toFocus.requestFocus();
    return false;
  }

  ChatThread _thread() {
    final store = Store.instance;
    return _to.length == 1 ? store.threadWith(_to.first.id) : store.groupWith([for (final p in _to) p.id]);
  }

  /// Sends [m] to the chosen people and swaps this screen for the conversation.
  void _deliver(ChatMessage m) {
    if (!_hasRecipients()) return;
    final t = _thread();
    Store.instance.sendMessage(t.messages, m);
    Navigator.of(context).pushReplacement(AppRoute(ConversationScreen(threadId: t.id)));
  }

  String _newId() => 'm${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _schedule() async {
    if (!_hasRecipients()) return;
    final withName = _to.length == 1 ? _to.first.name : _to.map((p) => p.name.split(' ').first).join(', ');
    final invite = await showAppSheet<MeetingInvite>(context, builder: (_) => ScheduleMeetingSheet(withName: withName));
    if (invite == null || !mounted) return;
    _deliver(ChatMessage(id: _newId(), senderId: 'me', time: DateTime.now(), type: MessageType.meeting, meeting: invite));
  }

  /// People matching the "To:" text. With no text: people you already chat
  /// with come first, then everyone else.
  List<Person> _suggestions() {
    final store = Store.instance;
    final q = _query.trim().toLowerCase();
    final picked = {for (final p in _to) p.id};
    final list = store.people.where((p) {
      if (picked.contains(p.id)) return false;
      return q.isEmpty || '${p.name} ${p.email} ${p.company} ${p.title}'.toLowerCase().contains(q);
    }).toList();
    final recent = <String>{
      for (final t in store.threads)
        if (!t.isGroup && t.messages.isNotEmpty) ...t.participantIds,
    };
    list.sort((a, b) {
      if (q.isNotEmpty) {
        final sa = a.name.toLowerCase().startsWith(q) ? 0 : 1;
        final sb = b.name.toLowerCase().startsWith(q) ? 0 : 1;
        if (sa != sb) return sa - sb;
      } else {
        final ra = recent.contains(a.id) ? 0 : 1;
        final rb = recent.contains(b.id) ? 0 : 1;
        if (ra != rb) return ra - rb;
      }
      return a.name.compareTo(b.name);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      body: AsyncView(
        keys: const ['people', 'chats'],
        builder: (context) {
          final showSuggestions = _toFocus.hasFocus && (_query.isNotEmpty || _to.isEmpty);
          return Column(
            children: [
              // ── Header ──
              Container(
                padding: EdgeInsets.fromLTRB(12, MediaQuery.paddingOf(context).top + 8, 12, 10),
                color: pal.surface,
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 12),
                    Expanded(child: Text('New message', style: context.tt.titleLarge)),
                  ],
                ),
              ),
              _ToField(
                people: _to,
                controller: _toCtrl,
                focusNode: _toFocus,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: () {
                  final s = _suggestions();
                  if (_query.isNotEmpty && s.isNotEmpty) _add(s.first);
                },
                onRemove: _remove,
                onBrowse: _browse,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: showSuggestions ? _SuggestionList(key: const ValueKey('s'), people: _suggestions(), query: _query, onPick: _add) : _EmptyCompose(key: ValueKey('e${_to.length}'), to: _to),
                ),
              ),
              ChatInputBar(
                hint: 'Type a message',
                canSend: _hasRecipients,
                onSend: (text) => _deliver(ChatMessage(id: _newId(), senderId: 'me', time: DateTime.now(), text: text)),
                onAttach: (f) => _deliver(ChatMessage(id: _newId(), senderId: 'me', time: DateTime.now(), type: MessageType.attachment, attachmentName: f)),
                onMeeting: _schedule,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The "To:" row: chosen people as chips, followed by a text field.
class _ToField extends StatelessWidget {
  const _ToField({
    required this.people,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onRemove,
    required this.onBrowse,
  });
  final List<Person> people;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final ValueChanged<Person> onRemove;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border(
          top: BorderSide(color: pal.border.withValues(alpha: 0.6)),
          bottom: BorderSide(color: focused ? AppColors.blue : pal.border.withValues(alpha: 0.6), width: focused ? 2 : 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('To:', style: context.tt.titleSmall?.copyWith(color: pal.textMuted)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: focusNode.requestFocus,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final p in people) _PersonChip(person: p, onRemove: () => onRemove(p)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 120, maxWidth: 400),
                      child: IntrinsicWidth(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: onChanged,
                          onSubmitted: (_) {
                            onSubmitted();
                            focusNode.requestFocus();
                          },
                          textInputAction: TextInputAction.next,
                          style: context.tt.bodyMedium,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            hintText: people.isEmpty ? 'Enter name, email or company' : 'Add more people',
                            hintStyle: context.tt.bodyMedium?.copyWith(color: pal.textFaint),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Browse contacts',
            onPressed: onBrowse,
            icon: Icon(Icons.person_add_alt_1_rounded, color: pal.textMuted, size: 22),
          ),
        ],
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({required this.person, required this.onRemove});
  final Person person;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 4, 3),
      decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(name: person.name, url: person.photoUrl, size: 24),
          const SizedBox(width: 6),
          Text(person.name, style: context.tt.labelLarge?.copyWith(color: AppColors.blueDeep)),
          const SizedBox(width: 2),
          Pressable(
            onTap: onRemove,
            scale: 0.8,
            child: const Padding(padding: EdgeInsets.all(3), child: Icon(Icons.close_rounded, size: 16, color: AppColors.blueDeep)),
          ),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({super.key, required this.people, required this.query, required this.onPick});
  final List<Person> people;
  final String query;
  final ValueChanged<Person> onPick;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    if (people.isEmpty) {
      return StateView.empty(icon: Icons.person_search_rounded, title: 'No matches', message: 'No one found for “$query”.');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      itemCount: people.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text(query.isEmpty ? 'Suggested' : 'People', style: context.tt.labelLarge?.copyWith(color: pal.textMuted)),
          );
        }
        final p = people[i - 1];
        return InkWell(
          onTap: () => onPick(p),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            child: Row(
              children: [
                AppAvatar(name: p.name, url: p.photoUrl, size: 40, online: p.online),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                      Text('${p.title} · ${p.company}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                    ],
                  ),
                ),
                Text(p.flag, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shown when no suggestions are open: the illustration and a hint.
class _EmptyCompose extends StatelessWidget {
  const _EmptyCompose({super.key, required this.to});
  final List<Person> to;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final store = Store.instance;
    final existing = to.length == 1
        ? store.threads.where((t) => !t.isGroup && t.participantIds.length == 1 && t.participantIds.first == to.first.id && t.messages.isNotEmpty).firstOrNull
        : null;
    final (title, message) = switch (to.length) {
      0 => ('You\'re starting a new conversation', 'Add people in "To:", then type your first message below.'),
      1 when existing != null => ('You already chat with ${to.first.name.split(' ').first}', 'Your message will be added to that conversation.'),
      1 => ('You\'re starting a new conversation', 'Type your first message to ${to.first.name.split(' ').first} below.'),
      _ => ('You\'re starting a group chat', 'Type your first message to these ${to.length} people below.'),
    };
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FadeSlideIn(child: _ComposeArt(size: 170)),
                const SizedBox(height: 28),
                FadeSlideIn(index: 1, child: Text(title, textAlign: TextAlign.center, style: context.tt.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                const SizedBox(height: 8),
                FadeSlideIn(index: 2, child: Text(message, textAlign: TextAlign.center, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Speech bubble with three dots and a pen, drawn in the app's colours.
class _ComposeArt extends StatelessWidget {
  const _ComposeArt({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(width: size, height: size, child: CustomPaint(painter: _ComposeArtPainter(dark: dark)));
  }
}

class _ComposeArtPainter extends CustomPainter {
  _ComposeArtPainter({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s * 0.52, s * 0.46);
    final r = s * 0.40;

    // Bubble: circle plus a tail at the bottom left.
    final bubbleColors = dark
        ? [const Color(0xFF2A3654), const Color(0xFF3A2F5E)]
        : [const Color(0xFFF1F4F8), const Color(0xFFDCD3F5)];
    final bubbleRect = Rect.fromCircle(center: center, radius: r);
    final bubblePaint = Paint()..shader = LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: bubbleColors).createShader(bubbleRect);
    final tail = Path()
      ..moveTo(center.dx - r * 0.62, center.dy + r * 0.55)
      ..lineTo(center.dx - r * 0.95, center.dy + r * 1.08)
      ..lineTo(center.dx - r * 0.18, center.dy + r * 0.90)
      ..close();
    final bubble = Path()
      ..addOval(bubbleRect)
      ..addPath(tail, Offset.zero);
    canvas.drawShadow(bubble, Colors.black.withValues(alpha: 0.25), 8, false);
    canvas.drawPath(bubble, bubblePaint);

    // Three dots on the left edge.
    const dots = [AppColors.purple, AppColors.green, AppColors.orange];
    final dotR = s * 0.055;
    for (var i = 0; i < dots.length; i++) {
      final c = Offset(center.dx - r * 0.95 + i * dotR * 2.1, center.dy + r * 0.05);
      canvas.drawCircle(c + Offset(0, dotR * 0.5), dotR, Paint()..color = Colors.black.withValues(alpha: 0.12));
      canvas.drawCircle(
        c,
        dotR,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.5),
            colors: [Color.lerp(dots[i], Colors.white, 0.45)!, dots[i], Color.lerp(dots[i], Colors.black, 0.2)!],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: c, radius: dotR)),
      );
    }

    // Pen, tilted across the bubble.
    canvas.save();
    canvas.translate(center.dx + r * 0.30, center.dy - r * 0.10);
    canvas.rotate(math.pi / 4.2);
    final w = s * 0.17;
    final len = s * 0.50;
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(-w / 2, -len / 2, w, len * 0.78),
      topLeft: Radius.circular(w / 2),
      topRight: Radius.circular(w / 2),
    );
    final bodyRect = body.outerRect;
    canvas.drawRRect(body, Paint()..shader = const LinearGradient(colors: [Color(0xFF5BC6F0), AppColors.blue, AppColors.blueDeep], stops: [0, 0.45, 1]).createShader(bodyRect));
    // Cap band.
    canvas.drawRect(Rect.fromLTWH(-w / 2, -len / 2 + w * 0.9, w, w * 0.22), Paint()..color = Colors.white.withValues(alpha: 0.55));
    // Wooden tip and nib.
    final tipTop = bodyRect.bottom;
    final tip = Path()
      ..moveTo(-w / 2, tipTop)
      ..lineTo(w / 2, tipTop)
      ..lineTo(0, tipTop + len * 0.26)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFFF4D7A8));
    final nib = Path()
      ..moveTo(-w * 0.17, tipTop + len * 0.17)
      ..lineTo(w * 0.17, tipTop + len * 0.17)
      ..lineTo(0, tipTop + len * 0.26)
      ..close();
    canvas.drawPath(nib, Paint()..color = AppColors.navy700);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ComposeArtPainter old) => old.dark != dark;
}
