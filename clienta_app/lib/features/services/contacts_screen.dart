import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../chats/conversation_screen.dart';
import '../chats/schedule_meeting_sheet.dart';
import '../events/section_scaffold.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, this.pickMode = false, this.title = 'Contacts'});
  final bool pickMode;
  final String title;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['people'],
      builder: (context) {
        final store = Store.instance;
        final all = store.people.where((p) {
          final f = switch (_filter) {
            'Online' => p.online,
            'PCU team' => p.company == 'Peterson & Control Union',
            'Clients' => p.company != 'Peterson & Control Union',
            _ => true,
          };
          final q = _query.toLowerCase();
          return f && (q.isEmpty || '${p.name} ${p.company} ${p.title} ${p.country}'.toLowerCase().contains(q));
        }).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        final groups = <String, List<Person>>{};
        for (final p in all) {
          groups.putIfAbsent(p.name[0].toUpperCase(), () => []).add(p);
        }

        return SectionScaffold(
          title: widget.title,
          subtitle: widget.pickMode ? 'Choose who to message' : '${store.people.length} people',
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: SearchField(hint: 'Search by name, company or country', onChanged: (v) => setState(() => _query = v)),
              ),
              ChoiceChips(options: const ['All', 'Online', 'PCU team', 'Clients'], selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(height: 6),
              Expanded(
                child: all.isEmpty
                    ? StateView.empty(icon: Icons.person_search_rounded, title: 'No contacts found', message: 'Try a different name or filter.')
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                        children: [
                          for (final entry in groups.entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
                              child: Text(entry.key, style: context.tt.labelLarge?.copyWith(color: AppColors.blue)),
                            ),
                            for (var i = 0; i < entry.value.length; i++)
                              FadeSlideIn(
                                index: i,
                                child: _ContactRow(
                                  person: entry.value[i],
                                  onTap: () => widget.pickMode ? Navigator.pop(context, entry.value[i]) : showPersonSheet(context, entry.value[i]),
                                ),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.person, required this.onTap});
  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = person;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(name: p.name, url: p.photoUrl, size: 48, online: p.online),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall)),
                    if (p.isOrganizer) ...[const SizedBox(width: 6), const TagChip(label: 'Organiser', color: AppColors.purple, small: true)],
                  ],
                ),
                Text('${p.title} · ${p.company}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
              ],
            ),
          ),
          Text(p.flag, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

/// Participant profile bottom sheet with quick actions.
void showPersonSheet(BuildContext context, Person p) {
  showAppSheet(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(name: p.name, url: p.photoUrl, size: 92, ring: true, online: p.online),
          const SizedBox(height: 12),
          Text(p.name, style: ctx.tt.headlineSmall),
          const SizedBox(height: 2),
          Text(p.title, style: ctx.tt.bodyMedium?.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700)),
          Text('${p.company} · ${p.flag} ${p.country}', style: ctx.tt.bodySmall),
          if (p.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(p.bio, textAlign: TextAlign.center, style: ctx.tt.bodyMedium?.copyWith(color: ctx.pal.textMuted)),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Message',
                  icon: Icons.chat_bubble_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    push(context, ConversationScreen(threadId: Store.instance.threadWith(p.id).id));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Meet',
                  icon: Icons.event_available_rounded,
                  variant: ButtonVariant.secondary,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final invite = await showAppSheet<MeetingInvite>(context, builder: (_) => ScheduleMeetingSheet(withName: p.name));
                    if (invite == null || !context.mounted) return;
                    final t = Store.instance.threadWith(p.id);
                    Store.instance.sendMessage(t.messages, ChatMessage(id: 'm${DateTime.now().microsecondsSinceEpoch}', senderId: 'me', time: DateTime.now(), type: MessageType.meeting, meeting: invite));
                    push(context, ConversationScreen(threadId: t.id));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.mail_outline_rounded,
                  title: p.email,
                  trailing: const Icon(Icons.copy_rounded, size: 18),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: p.email));
                    toast(ctx, 'Email copied');
                  },
                ),
                if (p.phone.isNotEmpty)
                  MenuTile(
                    icon: Icons.phone_outlined,
                    title: p.phone,
                    color: AppColors.green,
                    trailing: const Icon(Icons.copy_rounded, size: 18),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: p.phone));
                      toast(ctx, 'Phone number copied');
                    },
                  ),
                MenuTile(icon: Icons.apartment_rounded, title: p.department, subtitle: 'Department', color: AppColors.purple, trailing: const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
