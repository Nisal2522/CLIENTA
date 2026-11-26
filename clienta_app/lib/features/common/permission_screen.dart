import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';

enum PermissionKind { notifications, camera, location }

/// Friendly pre-permission screen shown before the OS prompt.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key, required this.kind, required this.onDone});
  final PermissionKind kind;
  final void Function(BuildContext context, bool granted) onDone;

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _asking = false;

  (IconData, Color, String, String, List<(IconData, String)>) get _content => switch (widget.kind) {
        PermissionKind.notifications => (
            Icons.notifications_active_rounded,
            AppColors.blue,
            'Stay in the loop',
            'Allow notifications so you never miss live sessions, meeting invitations and important announcements from organisers.',
            [(Icons.campaign_rounded, 'Organiser announcements'), (Icons.sensors_rounded, 'Sessions going live'), (Icons.event_available_rounded, 'Meeting invitations & replies')],
          ),
        PermissionKind.camera => (
            Icons.qr_code_scanner_rounded,
            AppColors.blueDeep,
            'Scan QR codes',
            'CLIENTA needs camera access to scan event badges, session check-in codes and participant QR codes.',
            [(Icons.how_to_reg_rounded, 'Fast check-in at sessions'), (Icons.contacts_rounded, 'Swap contacts instantly'), (Icons.lock_rounded, 'The camera is only used while scanning')],
          ),
        PermissionKind.location => (
            Icons.near_me_rounded,
            AppColors.blue,
            'Find your way',
            'Allow location access to show where you are on the venue map and get directions to the event.',
            [(Icons.map_rounded, 'Live position on venue map'), (Icons.directions_rounded, 'Directions to the venue'), (Icons.lock_rounded, 'Only used while the app is open')],
          ),
      };

  Future<void> _allow() async {
    setState(() => _asking = true);
    await Future.delayed(const Duration(milliseconds: 700));
    AppState.instance.grantedPermissions.add(widget.kind.name);
    if (mounted) widget.onDone(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, body, points) = _content;
    final pal = context.pal;
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Column(
            children: [
              const Spacer(),
              Floating(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final (s, a) in [(200.0, 0.08), (150.0, 0.14)])
                        Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: a))),
                      IconBadge(icon: icon, color: color, size: 100, circle: true, solid: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeSlideIn(child: Text(title, style: context.tt.headlineMedium, textAlign: TextAlign.center)),
              const SizedBox(height: 10),
              FadeSlideIn(index: 1, child: Text(body, textAlign: TextAlign.center, style: context.tt.bodyLarge?.copyWith(color: pal.textMuted))),
              const SizedBox(height: 24),
              for (var i = 0; i < points.length; i++)
                FadeSlideIn(
                  index: 2 + i,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(points[i].$1, color: color, size: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Text(points[i].$2, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ),
              const Spacer(flex: 2),
              AppButton(label: 'Allow access', loading: _asking, onPressed: _allow),
              const SizedBox(height: 8),
              AppButton(label: 'Not now', variant: ButtonVariant.ghost, onPressed: () => widget.onDone(context, false)),
            ],
          ),
        ),
      ),
    );
  }
}
