import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'rsvp_dialog.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.showSender = false, this.animate = true, this.onReply, this.onLongPress});
  final ChatMessage message;
  final bool showSender;
  final bool animate;

  /// Enables swipe-right-to-reply when set.
  final ValueChanged<ChatMessage>? onReply;

  /// Called on long-press with the bubble's own context (for positioning menus).
  final void Function(BuildContext bubbleContext, ChatMessage message)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final pal = context.pal;
    final mine = m.senderId == 'me';
    final sender = mine ? null : Store.instance.person(m.senderId);

    if (m.type == MessageType.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: pal.surfaceAlt, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign_rounded, size: 16, color: AppColors.blue),
                const SizedBox(width: 6),
                Flexible(child: Text.rich(emojiSpan(m.text, style: context.tt.bodySmall), textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      );
    }

    Widget content;
    if (m.type == MessageType.meeting && m.meeting != null) {
      content = MeetingCard(meeting: m.meeting!, mine: mine, fromId: m.senderId);
    } else if (m.type == MessageType.attachment) {
      content = _bubble(
        context,
        mine,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_rounded, color: mine ? Colors.white : AppColors.blue),
            const SizedBox(width: 8),
            Flexible(child: Text(m.attachmentName ?? 'File', style: TextStyle(fontWeight: FontWeight.w700, color: mine ? Colors.white : pal.text))),
          ],
        ),
      );
    } else {
      content = _bubble(context, mine, Text.rich(emojiSpan(m.text, style: TextStyle(color: mine ? Colors.white : pal.text, height: 1.42, fontSize: 14.5))));
    }

    if (onLongPress != null) {
      final inner = content;
      content = Builder(builder: (bubbleCtx) => GestureDetector(onLongPress: () => onLongPress!(bubbleCtx, m), child: inner));
    }
    if (m.reactions.isNotEmpty) {
      content = Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 16), child: content),
          Positioned(
            bottom: 0,
            left: mine ? null : 10,
            right: mine ? 10 : null,
            child: ReactionPill(message: m),
          ),
        ],
      );
    }

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            AppAvatar(name: sender?.name ?? '?', url: sender?.photoUrl, size: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Column(
                crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (showSender && sender != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        sender.isOrganizer ? '${sender.name} · Organiser' : sender.name,
                        style: context.tt.labelSmall?.copyWith(color: sender.isOrganizer ? AppColors.blueDeep : AppColors.blue),
                      ),
                    ),
                  content,
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(fmtTime(m.time), style: context.tt.labelSmall?.copyWith(color: pal.textFaint, fontWeight: FontWeight.w500)),
                        if (mine) ...[const SizedBox(width: 4), const Icon(Icons.done_all_rounded, size: 14, color: AppColors.blue)],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final Widget swipeable = onReply == null ? row : SwipeToReply(onReply: () => onReply!(m), child: row);
    if (!animate) return swipeable;
    return FadeSlideIn(offset: Offset(mine ? 0.15 : -0.15, 0.1), duration: const Duration(milliseconds: 420), child: swipeable);
  }

  Widget _bubble(BuildContext context, bool mine, Widget child) {
    final pal = context.pal;
    final reply = message.replyTo;
    if (reply != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [QuotedMessage(message: reply, onDark: mine), const SizedBox(height: 6), child],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: mine ? AppColors.brandGradient : null,
        color: mine ? null : pal.surface,
        border: mine ? null : Border.all(color: pal.border.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(mine ? 20 : 6),
          bottomRight: Radius.circular(mine ? 6 : 20),
        ),
      ),
      child: child,
    );
  }
}

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key, required this.meeting, required this.mine, this.fromId});
  final MeetingInvite meeting;
  final bool mine;

  /// Who sent the invite; shown in the RSVP pop-up.
  final String? fromId;

  @override
  Widget build(BuildContext context) {
    final m = meeting;
    final pal = context.pal;
    final (label, color) = switch (m.status) {
      MeetingStatus.pending => ('Pending', AppColors.orange),
      MeetingStatus.accepted => ('Accepted', AppColors.green),
      MeetingStatus.declined => ('Declined', AppColors.red),
    };
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.5), width: 1.3),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(weekdayShort(m.start), style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      Text('${m.start.day}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1)),
                      Text(monthShort(m.start), style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 14, color: AppColors.blue),
                          const SizedBox(width: 4),
                          Flexible(child: Text('MEETING INVITE', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelSmall?.copyWith(color: AppColors.blue, letterSpacing: 0.6))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                      Text(m.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 15, color: pal.textMuted),
                const SizedBox(width: 4),
                Flexible(flex: 3, child: Text('${fmtTime12(m.start)} – ${fmtTime12(m.end)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                const SizedBox(width: 10),
                Icon(Icons.place_outlined, size: 15, color: pal.textMuted),
                const SizedBox(width: 2),
                Expanded(flex: 2, child: Text(m.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: pal.surfaceAlt.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: (!mine && m.status == MeetingStatus.pending)
                  ? Row(
                      key: const ValueKey('actions'),
                      children: [
                        Expanded(child: _pill('RSVP', Icons.event_available_rounded, AppColors.blue, () => showRsvpDialog(context, m, fromId: fromId))),
                      ],
                    )
                  : Row(
                      key: ValueKey(m.status),
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Flexible(child: Text(mine && m.status == MeetingStatus.pending ? 'Awaiting response' : label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium?.copyWith(color: color))),
                        const Spacer(),
                        if (m.status == MeetingStatus.accepted)
                          GestureDetector(
                            onTap: () => toast(context, 'Added to your calendar', icon: Icons.calendar_month_rounded),
                            child: const Row(children: [Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.blue), SizedBox(width: 4), Text('Calendar', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 12))]),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, IconData icon, Color color, VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        ),
      );
}

/// Message composer with attachment and optional meeting button.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.onAttach, this.onMeeting, this.hint = 'Type your message here…', this.replyTo, this.onCancelReply, this.canSend});
  final ValueChanged<String> onSend;

  /// Checked before sending; when it returns false the typed text is kept.
  final bool Function()? canSend;
  final ValueChanged<String>? onAttach;
  final VoidCallback? onMeeting;
  final String hint;

  /// When set, a "replying to" preview is shown above the field.
  final ChatMessage? replyTo;
  final VoidCallback? onCancelReply;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void didUpdateWidget(covariant ChatInputBar old) {
    super.didUpdateWidget(old);
    if (widget.replyTo != null && widget.replyTo != old.replyTo) _focus.requestFocus();
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    if (widget.canSend?.call() == false) return;
    widget.onSend(t);
    _c.clear();
    setState(() => _hasText = false);
  }

  void _attach() {
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share', style: ctx.tt.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (icon, label, color, file) in [
                  (Icons.photo_rounded, 'Photo', AppColors.blue, 'Photo_2026.jpg'),
                  (Icons.camera_alt_rounded, 'Camera', AppColors.blueDeep, 'Camera_capture.jpg'),
                  (Icons.description_rounded, 'Document', AppColors.darkBlue80, 'Proposal_v2.pdf'),
                  (Icons.location_on_rounded, 'Location', AppColors.steel, 'My location · BMICH'),
                ])
                  Pressable(
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onAttach?.call(file);
                    },
                    child: Column(
                      children: [
                        IconBadge(icon: icon, color: color, size: 58, circle: true, solid: true),
                        const SizedBox(height: 8),
                        Text(label, style: ctx.tt.labelMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.paddingOf(context).bottom + 10),
      decoration: BoxDecoration(
        color: pal.surface,
        border: Border(top: BorderSide(color: pal.border.withValues(alpha: 0.6))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: widget.replyTo == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.reply_rounded, color: AppColors.blue, size: 22)),
                        Expanded(child: QuotedMessage(message: widget.replyTo!, expand: true)),
                        IconButton(
                          tooltip: 'Cancel reply',
                          icon: Icon(Icons.close_rounded, color: pal.textMuted, size: 20),
                          onPressed: widget.onCancelReply,
                        ),
                      ],
                    ),
                  ),
          ),
          Row(
        children: [
          if (widget.onAttach != null)
            IconButton(icon: Icon(Icons.attach_file_rounded, color: pal.textMuted), onPressed: _attach),
          if (widget.onMeeting != null)
            IconButton(
              tooltip: 'Schedule meeting',
              icon: const Icon(Icons.add_circle_rounded, color: AppColors.blue),
              onPressed: widget.onMeeting,
            ),
          Expanded(
            child: TextField(
              controller: _c,
              focusNode: _focus,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              onChanged: (v) {
                if (_hasText != v.trim().isNotEmpty) setState(() => _hasText = v.trim().isNotEmpty);
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.blue)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedScale(
            scale: _hasText ? 1 : 0.85,
            duration: const Duration(milliseconds: 200),
            child: Pressable(
              onTap: _send,
              scale: 0.85,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: _hasText ? AppColors.brandGradient : null,
                  color: _hasText ? null : pal.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: _hasText ? Colors.white : pal.textFaint, size: 20),
              ),
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key, required this.name, this.url});
  final String name;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return FadeSlideIn(
      offset: const Offset(-0.1, 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AppAvatar(name: name, url: url, size: 32),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: pal.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: pal.border.withValues(alpha: 0.7))),
              child: const TypingDots(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds the message list with date dividers.
List<Widget> buildMessageList(
  BuildContext context,
  List<ChatMessage> messages, {
  bool showSender = false,
  ValueChanged<ChatMessage>? onReply,
  void Function(BuildContext bubbleContext, ChatMessage message)? onLongPress,
}) {
  final out = <Widget>[];
  DateTime? last;
  for (final m in messages) {
    if (last == null || !sameDay(last, m.time)) {
      out.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            sameDay(m.time, DateTime.now()) ? 'Today' : fmtDate(m.time),
            style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint),
          ),
        ),
      ));
    }
    last = m.time;
    out.add(MessageBubble(key: ValueKey(m.id), message: m, showSender: showSender, onReply: onReply, onLongPress: onLongPress));
  }
  return out;
}

// ── Replies & reactions ──

/// One-line description of a message, for reply quotes.
String messageSnippet(ChatMessage m) => switch (m.type) {
      MessageType.meeting => '📅 Meeting: ${m.meeting?.title ?? ''}',
      MessageType.attachment => '📎 ${m.attachmentName ?? 'File'}',
      _ => m.text,
    };

String messageSenderName(ChatMessage m) => m.senderId == 'me' ? 'You' : (Store.instance.person(m.senderId)?.name ?? 'Unknown');

/// Quoted original message, shown inside a reply bubble and above the composer.
class QuotedMessage extends StatelessWidget {
  const QuotedMessage({super.key, required this.message, this.onDark = false, this.expand = false});
  final ChatMessage message;

  /// True when drawn on the blue (own) bubble.
  final bool onDark;

  /// Fill the available width (composer preview).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final accent = onDark ? Colors.white : (message.senderId == 'me' ? AppColors.blue : AppColors.blueDeep);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withValues(alpha: 0.18) : accent.withValues(alpha: 0.08),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(messageSenderName(message), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text.rich(
              emojiSpan(messageSnippet(message), style: TextStyle(color: onDark ? Colors.white.withValues(alpha: 0.85) : pal.textMuted, fontSize: 13, height: 1.3)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small emoji pill under a bubble. Tap to see who reacted.
class ReactionPill extends StatelessWidget {
  const ReactionPill({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final r = message.reactions;
    final emojis = r.values.toSet().take(3).join();
    final mineReacted = r.containsKey('me');
    return Pressable(
      scale: 0.9,
      onTap: () => _showReactions(context, message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: mineReacted ? Color.alphaBlend(AppColors.blue.withValues(alpha: 0.12), pal.surface) : pal.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pal.border.withValues(alpha: 0.8)),
          boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emojis, style: const TextStyle(fontSize: 14, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
            if (r.length > 1) ...[const SizedBox(width: 3), Text('${r.length}', style: context.tt.labelSmall?.copyWith(color: pal.textMuted))],
          ],
        ),
      ),
    );
  }

  static void _showReactions(BuildContext context, ChatMessage m) {
    final me = AppState.instance.user;
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reactions', style: ctx.tt.titleLarge),
            const SizedBox(height: 8),
            for (final e in m.reactions.entries)
              Builder(builder: (_) {
                final mine = e.key == 'me';
                final p = mine ? null : Store.instance.person(e.key);
                final name = mine ? 'You' : (p?.name ?? 'Unknown');
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: AppAvatar(name: mine ? (me?.name ?? 'You') : name, url: mine ? me?.photoUrl : p?.photoUrl, size: 40),
                  title: Text(name, style: ctx.tt.titleSmall),
                  subtitle: mine ? const Text('Tap to remove') : null,
                  trailing: Text(e.value, style: const TextStyle(fontSize: 24, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                  onTap: mine
                      ? () {
                          Navigator.pop(ctx);
                          Store.instance.react(m, e.value);
                        }
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// WhatsApp-style swipe right to reply.
class SwipeToReply extends StatefulWidget {
  const SwipeToReply({super.key, required this.child, required this.onReply});
  final Widget child;
  final VoidCallback onReply;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  static const _threshold = 64.0;
  static const _max = 90.0;
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))
    ..addListener(() => setState(() => _dx = _from * (1 - Curves.easeOutCubic.transform(_back.value))));
  double _dx = 0;
  double _from = 0;
  bool _armed = false;

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    setState(() => _dx = (_dx + d.delta.dx).clamp(0.0, _max));
    if (!_armed && _dx >= _threshold) {
      _armed = true;
      HapticFeedback.lightImpact();
    } else if (_armed && _dx < _threshold) {
      _armed = false;
    }
  }

  void _end() {
    if (_armed) widget.onReply();
    _armed = false;
    _from = _dx;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = (_dx / _threshold).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _back.stop(),
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: (_) => _end(),
      onHorizontalDragCancel: _end,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 2,
            child: Opacity(
              opacity: t,
              child: Transform.scale(
                scale: 0.6 + 0.4 * t,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: context.pal.surfaceAlt, shape: BoxShape.circle),
                  child: const Icon(Icons.reply_rounded, size: 20, color: AppColors.blue),
                ),
              ),
            ),
          ),
          Transform.translate(offset: Offset(_dx, 0), child: widget.child),
        ],
      ),
    );
  }
}

const kQuickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// Long-press menu: emoji bar + Reply / Copy, anchored to the pressed bubble.
Future<void> showMessageActions(
  BuildContext context, {
  required BuildContext anchor,
  required ChatMessage message,
  required VoidCallback onReply,
  required ValueChanged<String> onReact,
}) {
  final box = anchor.findRenderObject() as RenderBox;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  HapticFeedback.mediumImpact();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Message actions',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, _) => _MessageActions(rect: rect, message: message, onReply: onReply, onReact: onReact),
    transitionBuilder: (ctx, a, _, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: child),
    ),
  );
}

class _MessageActions extends StatelessWidget {
  const _MessageActions({required this.rect, required this.message, required this.onReply, required this.onReact});
  final Rect rect;
  final ChatMessage message;
  final VoidCallback onReply;
  final ValueChanged<String> onReact;

  static const _barH = 52.0;
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final mine = message.senderId == 'me';
    final canCopy = message.type == MessageType.text && message.text.isNotEmpty;
    final menuH = canCopy ? 104.0 : 52.0;
    final minTop = pad.top + _gap;
    final maxBottom = size.height - pad.bottom - _gap;

    // Emoji bar above the bubble if there is room, else below it.
    final barAbove = rect.top - _barH - _gap >= minTop;
    final barTop = (barAbove ? rect.top - _barH - _gap : rect.bottom + _gap).clamp(minTop, maxBottom - _barH);
    // Menu below the bubble if there is room, else next to the emoji bar.
    final menuBelow = barAbove && rect.bottom + _gap + menuH <= maxBottom;
    final menuTop = (menuBelow ? rect.bottom + _gap : (barAbove ? barTop - _gap - menuH : barTop + _barH + _gap)).clamp(minTop, maxBottom - menuH);
    final current = message.reactions['me'];

    void act(VoidCallback f) {
      Navigator.pop(context);
      f();
    }

    Widget menuItem(IconData icon, String label, VoidCallback onTap) => InkWell(
          onTap: () => act(onTap),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(child: Text(label, style: context.tt.titleSmall)),
                Icon(icon, size: 20, color: pal.textMuted),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );

    return Stack(
      children: [
        Positioned(
          top: barTop,
          left: mine ? null : 14,
          right: mine ? 14 : null,
          child: Material(
            color: pal.surface,
            elevation: 8,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final e in kQuickReactions)
                    Pressable(
                      scale: 0.8,
                      onTap: () => act(() => onReact(e)),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: current == e ? pal.surfaceAlt : null),
                        child: Text(e, style: const TextStyle(fontSize: 26, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: menuTop,
          left: mine ? null : 14,
          right: mine ? 14 : null,
          width: 200,
          child: Material(
            color: pal.surface,
            elevation: 8,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                menuItem(Icons.reply_rounded, 'Reply', onReply),
                if (canCopy)
                  menuItem(Icons.copy_rounded, 'Copy', () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    toast(context, 'Message copied', icon: Icons.copy_rounded);
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
