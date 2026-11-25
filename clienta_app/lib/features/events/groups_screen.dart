import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../chats/conversation_screen.dart';
import '../services/contacts_screen.dart';
import 'section_scaffold.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'groups', 'people'],
      builder: (context) {
        final store = Store.instance;
        final e = store.event(eventId);
        final groups = store.groups.where((g) => g.eventId == eventId).toList();
        return SectionScaffold(
          title: 'Groups',
          subtitle: e.title,
          body: groups.isEmpty
              ? StateView.empty(icon: Icons.groups_outlined, title: 'No groups yet', message: 'Organisers will assign breakout groups closer to the event.')
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => FadeSlideIn(index: i, child: _GroupCard(group: groups[i])),
                ),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final g = group;
    final store = Store.instance;
    final ids = g.membersByDate.values.expand((x) => x).toSet().toList();
    final mine = ids.contains('me');
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => push(context, GroupDetailScreen(group: g)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.groups_rounded, color: g.color, size: 46, solid: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GROUP ${g.number}', style: context.tt.labelSmall?.copyWith(color: g.color, letterSpacing: 0.8)),
                    Text(g.name, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                  ],
                ),
              ),
              if (mine) const TagChip(label: 'Your group', color: AppColors.green, small: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.meeting_room_outlined, size: 16, color: context.pal.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(g.room, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              SizedBox(
                height: 30,
                width: 30.0 + (ids.length.clamp(1, 5) - 1) * 18,
                child: Stack(
                  children: [
                    for (var i = 0; i < ids.length && i < 5; i++)
                      Positioned(
                        left: i * 18.0,
                        child: Builder(builder: (context) {
                          final p = ids[i] == 'me' ? null : store.person(ids[i]);
                          return Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.pal.surface, width: 2)),
                            child: AppAvatar(name: p?.name ?? 'You', url: p?.photoUrl, size: 26),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.group});
  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final g = group;
    final store = Store.instance;
    final dates = g.membersByDate.keys.toList()..sort();
    return SectionScaffold(
      title: 'Group Members',
      subtitle: 'Group ${g.number}',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          FadeSlideIn(
            child: AppCard(
              gradient: LinearGradient(colors: [g.color, Color.lerp(g.color, AppColors.navy900, 0.5)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GROUP ${g.number}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(g.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(g.topic, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(g.room, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (final d in dates) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(fmtDateFull(d), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < g.membersByDate[d]!.length; i++)
              Builder(builder: (context) {
                final id = g.membersByDate[d]![i];
                final p = id == 'me' ? null : store.person(id);
                return FadeSlideIn(
                  index: i,
                  child: AppCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    onTap: p == null ? null : () => showPersonSheet(context, p),
                    child: Row(
                      children: [
                        AppAvatar(name: p?.name ?? 'You', url: p?.photoUrl, size: 42, online: p?.online ?? true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p?.name ?? 'You', style: context.tt.titleSmall),
                              Text(p == null ? 'Group member' : '${p.email} (${p.country})', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                            ],
                          ),
                        ),
                        if (p != null)
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.blue),
                            onPressed: () => push(context, ConversationScreen(threadId: store.threadWith(p.id).id)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}
