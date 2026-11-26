import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../chats/conversation_screen.dart';
import 'section_scaffold.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'people'],
      builder: (context) {
        final store = Store.instance;
        final organizers = store.organizers;
        return SectionScaffold(
          title: 'Contact Us',
          subtitle: store.event(eventId).title,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              FadeSlideIn(
                child: AppCard(
                  gradient: AppColors.brandGradient,
                  border: false,
                  child: const Row(
                    children: [
                      Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Questions about the event? Our organising team is here to help and usually replies within an hour during the event.',
                          style: TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < organizers.length; i++) FadeSlideIn(index: i + 1, child: _OrganizerCard(person: organizers[i])),
            ],
          ),
        );
      },
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  const _OrganizerCard({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final p = person;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AppAvatar(name: p.name, url: p.photoUrl, size: 54, online: p.online),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                Text(p.title, style: context.tt.bodySmall?.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Department: ${p.department}', style: context.tt.bodySmall),
              ],
            ),
          ),
          Pressable(
            onTap: () => _contactSheet(context, p),
            child: const IconBadge(icon: Icons.mail_rounded, size: 44, circle: true, solid: true),
          ),
        ],
      ),
    );
  }

  void _contactSheet(BuildContext context, Person p) {
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(name: p.name, url: p.photoUrl, size: 70, ring: true),
            const SizedBox(height: 10),
            Text(p.name, style: ctx.tt.titleLarge),
            Text('${p.title} · ${p.department}', style: ctx.tt.bodySmall),
            const SizedBox(height: 16),
            MenuTile(
              icon: Icons.mail_rounded,
              title: 'Send email',
              subtitle: p.email,
              onTap: () {
                Navigator.pop(ctx);
                toast(context, 'Opening your mail app…', icon: Icons.mail_rounded);
              },
            ),
            MenuTile(
              icon: Icons.chat_bubble_rounded,
              title: 'Message in CLIENTA',
              color: AppColors.blueDeep,
              onTap: () {
                Navigator.pop(ctx);
                push(context, ConversationScreen(threadId: Store.instance.threadWith(p.id).id));
              },
            ),
            MenuTile(
              icon: Icons.copy_rounded,
              title: 'Copy email address',
              color: AppColors.steel,
              onTap: () {
                Clipboard.setData(ClipboardData(text: p.email));
                Navigator.pop(ctx);
                toast(context, 'Email copied');
              },
            ),
          ],
        ),
      ),
    );
  }
}
