import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/notification_center_screen.dart';
import 'section_scaffold.dart';

class EventNotificationsScreen extends StatelessWidget {
  const EventNotificationsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final isEmployee = AppState.instance.user?.isEmployee ?? false;
    return AsyncView(
      keys: const ['events', 'notifications'],
      builder: (context) {
        final store = Store.instance;
        final e = store.event(eventId);
        final items = store.notifications.where((n) => n.eventId == eventId).toList();
        return SectionScaffold(
          title: 'Notifications',
          subtitle: e.title,
          floating: isEmployee ? GradientFab(icon: Icons.campaign_rounded, label: 'Send update', onTap: () => _compose(context, e)) : null,
          body: items.isEmpty
              ? StateView.empty(
                  icon: Icons.notifications_off_outlined,
                  title: 'No updates yet',
                  message: isEmployee ? 'Send the first update to all participants.' : 'Organiser announcements for this event will appear here.',
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  itemCount: items.length,
                  itemBuilder: (_, i) => FadeSlideIn(key: ValueKey(items[i].id), index: i, child: NotificationTile(n: items[i])),
                ),
        );
      },
    );
  }

  void _compose(BuildContext context, ClientaEvent e) {
    showAppSheet(context, builder: (_) => _ComposeSheet(event: e));
  }
}

class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({required this.event});
  final ClientaEvent event;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty) {
      toast(context, 'Add a title first', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    Store.instance.addNotification(AppNotification(
      id: 'nf${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      body: _body.text.trim(),
      time: DateTime.now(),
      type: NotificationType.announcement,
      eventId: widget.event.id,
    ));
    Navigator.pop(context);
    toast(context, 'Sent to ${widget.event.attendees} participants', icon: Icons.campaign_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notify participants', style: context.tt.titleLarge),
          Text(widget.event.title, style: context.tt.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            maxLength: 65,
            decoration: const InputDecoration(hintText: 'Title', prefixIcon: Icon(Icons.title_rounded)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _body,
            maxLength: 240,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Description', prefixIcon: Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.notes_rounded))),
          ),
          const SizedBox(height: 8),
          AppButton(label: 'Send to ${widget.event.title}', icon: Icons.send_rounded, loading: _sending, onPressed: _send),
        ],
      ),
    );
  }
}
