import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../events/event_dashboard_screen.dart';
import '../events/section_scaffold.dart';

(IconData, Color) notificationStyle(NotificationType t) => switch (t) {
      NotificationType.announcement => (Icons.campaign_rounded, AppColors.blue),
      NotificationType.agenda => (Icons.sensors_rounded, AppColors.red),
      NotificationType.news => (Icons.newspaper_rounded, AppColors.purple),
      NotificationType.chat => (Icons.chat_bubble_rounded, AppColors.teal),
      NotificationType.meeting => (Icons.event_available_rounded, AppColors.orange),
      NotificationType.certificate => (Icons.workspace_premium_rounded, AppColors.yellow),
      NotificationType.system => (Icons.info_rounded, AppColors.steel),
    };

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.n});
  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notificationStyle(n.type);
    final pal = context.pal;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      color: n.read ? null : Color.alphaBlend(AppColors.blue.withValues(alpha: pal.dark ? 0.08 : 0.05), pal.surface),
      onTap: () {
        Store.instance.markRead(n);
        if (n.eventId != null) push(context, EventDashboardScreen(eventId: n.eventId!));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(n.title, style: context.tt.titleSmall?.copyWith(fontWeight: n.read ? FontWeight.w600 : FontWeight.w800))),
                    const SizedBox(width: 8),
                    Text(timeAgo(n.time), style: context.tt.bodySmall?.copyWith(color: pal.textFaint)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(color: pal.textMuted, height: 1.45)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(left: 8, top: 4),
            width: n.read ? 0 : 9,
            height: 9,
            decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _tab = 'All';

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['notifications'],
      builder: (context) {
        final store = Store.instance;
        final items = store.notifications.where((n) => _tab == 'All' || !n.read).toList();
        final today = items.where((n) => sameDay(n.time, DateTime.now())).toList();
        final earlier = items.where((n) => !sameDay(n.time, DateTime.now())).toList();
        var idx = 0;
        Widget tile(AppNotification n) => FadeSlideIn(
              key: ValueKey(n.id),
              index: idx++,
              child: Dismissible(
                key: ValueKey('d${n.id}'),
                background: _swipeBg(Alignment.centerLeft, AppColors.blue, n.read ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded),
                secondaryBackground: _swipeBg(Alignment.centerRight, AppColors.red, Icons.delete_rounded),
                confirmDismiss: (dir) async {
                  if (dir == DismissDirection.startToEnd) {
                    store.markRead(n, !n.read);
                    return false;
                  }
                  return true;
                },
                onDismissed: (_) {
                  store.removeNotification(n);
                  toast(context, 'Notification removed', icon: Icons.delete_rounded);
                },
                child: NotificationTile(n: n),
              ),
            );
        return SectionScaffold(
          title: 'Notifications',
          subtitle: '${store.unreadNotifications} unread',
          actions: [
            TextButton(
              onPressed: store.unreadNotifications == 0
                  ? null
                  : () {
                      store.markAllRead();
                      toast(context, 'All notifications marked as read');
                    },
              child: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: ChoiceChips(options: const ['All', 'Unread'], selected: _tab, onSelected: (v) => setState(() => _tab = v)),
              ),
              Expanded(
                child: items.isEmpty
                    ? StateView.empty(icon: Icons.notifications_off_rounded, title: 'You’re all caught up', message: 'New announcements, meeting invites and live updates will appear here.')
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                        children: [
                          if (today.isNotEmpty) ...[_label('Today'), ...today.map(tile)],
                          if (earlier.isNotEmpty) ...[_label('Earlier'), ...earlier.map(tile)],
                          const SizedBox(height: 8),
                          Center(child: Text('Swipe right to toggle read · left to remove', style: context.tt.bodySmall)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
        child: Text(t.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint, letterSpacing: 1.1)),
      );

  Widget _swipeBg(Alignment a, Color c, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: a,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(22)),
        child: Icon(icon, color: Colors.white),
      );
}
