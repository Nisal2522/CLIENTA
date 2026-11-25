import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'evaluations_screen.dart';
import 'resources_screen.dart';
import 'section_scaffold.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final e = Store.instance.event(eventId);
    return SectionScaffold(
      title: 'Event Tips',
      subtitle: e.title,
      body: e.tips.isEmpty
          ? StateView.empty(icon: Icons.lightbulb_outline_rounded, title: 'No tips yet', message: 'Organisers will share helpful tips closer to the event.')
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                for (var i = 0; i < e.tips.length; i++)
                  FadeSlideIn(index: i, child: _TipCard(tip: e.tips[i], initiallyOpen: i == 0)),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: e.tips.length,
                  child: Row(
                    children: [
                      Expanded(child: AppButton(label: 'Resources', icon: Icons.folder_copy_rounded, variant: ButtonVariant.secondary, onPressed: () => push(context, ResourcesScreen(eventId: eventId)))),
                      const SizedBox(width: 10),
                      Expanded(child: AppButton(label: 'Give feedback', icon: Icons.rate_review_rounded, onPressed: () => push(context, EvaluationsScreen(eventId: eventId)))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _TipCard extends StatefulWidget {
  const _TipCard({required this.tip, this.initiallyOpen = false});
  final EventTip tip;
  final bool initiallyOpen;

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final t = widget.tip;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => setState(() => _open = !_open),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(icon: t.icon, color: t.color, size: 44, solid: true),
                const SizedBox(width: 14),
                Expanded(child: Text(t.title, style: context.tt.titleSmall?.copyWith(fontSize: 15))),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: context.pal.textMuted),
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 12),
              Text(t.body, style: context.tt.bodyMedium?.copyWith(color: context.pal.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
