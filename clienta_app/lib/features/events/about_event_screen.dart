import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'event_card.dart';
import 'section_scaffold.dart';

class AboutEventScreen extends StatelessWidget {
  const AboutEventScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final e = Store.instance.event(eventId);
    final pal = context.pal;
    return SectionScaffold(
      title: 'About Event',
      subtitle: e.title,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          FadeSlideIn(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EventImage(event: e),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xB30B1120)],
                          stops: [0.3, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            TagChip(label: e.category, color: Colors.white, icon: categoryIcon(e.category)),
                            if (e.inviteOnly) const TagChip(label: 'PCU only', color: AppColors.yellow, icon: Icons.lock_rounded),
                          ]),
                          const SizedBox(height: 8),
                          Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(index: 1, child: Text(e.description, style: context.tt.bodyLarge)),
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 2,
            child: AppCard(
              child: Column(
                children: [
                  InfoRow(icon: Icons.calendar_month_rounded, label: 'Date', value: fmtRange(e.start, e.end)),
                  InfoRow(icon: Icons.schedule_rounded, label: 'Time', value: '${fmtTime12(e.start)} – ${fmtTime12(e.end)}', color: AppColors.orange),
                  InfoRow(icon: Icons.place_rounded, label: 'Venue', value: '${e.venue.name}, ${e.venue.address}', color: AppColors.green),
                  InfoRow(icon: Icons.checkroom_rounded, label: 'Dress code', value: e.dressCode, color: AppColors.purple),
                ],
              ),
            ),
          ),
          if (e.disclaimers.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text('Disclaimers', style: context.tt.titleLarge),
            const SizedBox(height: 10),
            for (var i = 0; i < e.disclaimers.length; i++)
              FadeSlideIn(
                index: 3 + i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.yellow, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.disclaimers[i], style: context.tt.bodyMedium)),
                    ],
                  ),
                ),
              ),
          ],
          if (e.sponsors.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text('Main Sponsors', style: context.tt.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: e.sponsors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => FadeSlideIn(index: i, offset: const Offset(0.2, 0), child: _SponsorCard(sponsor: e.sponsors[i])),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text('Hosted by', style: context.tt.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                const ClientaLogo(size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Peterson & Control Union', style: context.tt.titleSmall),
                      Text('Event organiser', style: context.tt.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: pal.dark ? AppColors.blue : AppColors.blueDeep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorCard extends StatelessWidget {
  const _SponsorCard({required this.sponsor});
  final Sponsor sponsor;

  @override
  Widget build(BuildContext context) {
    final s = sponsor;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: context.pal.shadow, blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(s.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
              ),
              const Spacer(),
              TagChip(label: s.tier, color: s.color, small: true),
            ],
          ),
          const Spacer(),
          Text(s.name.toUpperCase(), style: TextStyle(color: s.color, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2)),
          const SizedBox(height: 3),
          Text(s.tagline, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF5B6B7F), fontSize: 11.5)),
        ],
      ),
    );
  }
}
