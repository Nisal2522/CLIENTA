import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../events/section_scaffold.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key, this.eventTitle = 'FutureTech Connect 2026'});
  final String eventTitle;

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: 'My Badge',
      subtitle: eventTitle,
      body: _Badge(eventTitle: eventTitle),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.eventTitle});
  final String eventTitle;

  @override
  Widget build(BuildContext context) {
    final u = AppState.instance.user!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      children: [
        FadeSlideIn(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: AppColors.navyGradient,
              boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 18))],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                  child: Row(
                    children: [
                      const ClientaLogo(size: 30),
                      const SizedBox(width: 8),
                      const Text('CLIENTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 3)),
                      const Spacer(),
                      TagChip(label: u.isEmployee ? 'PCU' : 'CLIENT', color: u.isEmployee ? AppColors.blueDeep : AppColors.blue, solid: true),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                AppAvatar(name: u.name, url: u.photoUrl, size: 84, ring: true),
                const SizedBox(height: 12),
                Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${u.title} · ${u.company}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: QrCodeView(data: '${u.email}|$eventTitle', size: 200),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Text(eventTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text('Show this code at registration and session doors', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(child: Text('Tip: turn up screen brightness for faster scanning', style: context.tt.bodySmall)),
      ],
    );
  }
}
