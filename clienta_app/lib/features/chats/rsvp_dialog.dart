import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';

/// Outlook-style RSVP: shows the invite and asks "Will you attend?".
/// Accepting needs consent to share your details with the other participants.
Future<void> showRsvpDialog(BuildContext context, MeetingInvite meeting, {String? fromId}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => _RsvpDialog(meeting: meeting, fromId: fromId, parent: context),
    transitionBuilder: (_, a, _, child) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

class _RsvpDialog extends StatefulWidget {
  const _RsvpDialog({required this.meeting, required this.fromId, required this.parent});
  final MeetingInvite meeting;
  final String? fromId;

  /// Context of the screen that opened the dialog, for the toast afterwards.
  final BuildContext parent;

  @override
  State<_RsvpDialog> createState() => _RsvpDialogState();
}

class _RsvpDialogState extends State<_RsvpDialog> {
  late bool _agree = widget.meeting.status == MeetingStatus.accepted;

  void _respond(MeetingStatus status) {
    Store.instance.setMeetingStatus(widget.meeting, status);
    Navigator.of(context).pop();
    final parent = widget.parent;
    if (!parent.mounted) return;
    if (status == MeetingStatus.accepted) {
      toast(parent, 'Meeting accepted · added to your calendar', icon: Icons.event_available_rounded, color: AppColors.green);
    } else {
      toast(parent, 'Meeting declined', icon: Icons.event_busy_rounded, color: AppColors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final m = widget.meeting;
    final user = AppState.instance.user;
    final from = widget.fromId == null ? null : Store.instance.person(widget.fromId!);

    final (String? statusText, Color statusColor) = switch (m.status) {
      MeetingStatus.accepted => ('You accepted this meeting', AppColors.green),
      MeetingStatus.declined => ('You declined this meeting', AppColors.red),
      MeetingStatus.pending => (null, AppColors.blue),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Material(
            color: pal.surface,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Title + close ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RSVP', style: context.tt.labelSmall?.copyWith(color: AppColors.blue, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(m.title, style: context.tt.titleLarge),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Pressable(
                        onTap: () => Navigator.of(context).pop(),
                        scale: 0.85,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                  if (from != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        AppAvatar(name: from.name, url: from.photoUrl, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(text: from.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                              const TextSpan(text: ' invited you'),
                            ]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.tt.bodyMedium?.copyWith(color: pal.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // ── Meeting details ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: pal.surfaceAlt, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detail(context, Icons.calendar_today_rounded, fmtDate(m.start)),
                        const SizedBox(height: 8),
                        _detail(context, Icons.schedule_rounded, '${fmtTime12(m.start)} – ${fmtTime12(m.end)}'),
                        const SizedBox(height: 8),
                        _detail(context, Icons.place_outlined, m.location),
                        if (m.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(m.description, style: context.tt.bodySmall?.copyWith(color: pal.textMuted, height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Your details ──
                  _readOnlyField(context, Icons.person_outline_rounded, user?.name ?? 'You'),
                  const SizedBox(height: 10),
                  _readOnlyField(context, Icons.mail_outline_rounded, user?.email ?? ''),
                  const SizedBox(height: 12),

                  // ── Consent ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            'To enhance your networking experience, accepting a meeting shares your name, email, company and designation with the other participants.',
                            style: context.tt.bodySmall?.copyWith(color: pal.text, height: 1.45),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _agree = !_agree),
                          child: Row(
                            children: [
                              Expanded(child: Text('Do you agree to share these details?', style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                              Checkbox(
                                value: _agree,
                                activeColor: AppColors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (v) => setState(() => _agree = v ?? false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Answer ──
                  if (statusText != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m.status == MeetingStatus.accepted ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(statusText, style: context.tt.labelLarge?.copyWith(color: statusColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text('Will you attend?', textAlign: TextAlign.center, style: context.tt.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'No',
                          icon: Icons.close_rounded,
                          height: 48,
                          variant: ButtonVariant.secondary,
                          onPressed: m.status == MeetingStatus.declined ? null : () => _respond(MeetingStatus.declined),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          label: 'Yes',
                          icon: Icons.check_rounded,
                          height: 48,
                          onPressed: !_agree || m.status == MeetingStatus.accepted ? null : () => _respond(MeetingStatus.accepted),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: !_agree && m.status != MeetingStatus.accepted
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Tick the box above to accept.', textAlign: TextAlign.center, style: context.tt.bodySmall?.copyWith(color: pal.textFaint)),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 17, color: AppColors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
        ],
      );

  Widget _readOnlyField(BuildContext context, IconData icon, String value) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: pal.textMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodyMedium)),
        ],
      ),
    );
  }
}
