import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../chats/meetings_screen.dart';
import '../common/qr_screen.dart';
import '../services/contacts_screen.dart';
import 'about_event_screen.dart';
import 'agenda_screen.dart';
import 'certificates_screen.dart';
import 'contact_us_screen.dart';
import 'evaluations_screen.dart';
import 'event_card.dart';
import 'event_notifications_screen.dart';
import 'gallery_screen.dart';
import 'groups_screen.dart';
import 'live_chat_screen.dart';
import 'location_screen.dart';
import 'notes_screen.dart';
import 'resources_screen.dart';
import 'speakers_screen.dart';
import 'tips_screen.dart';

class EventDashboardScreen extends StatelessWidget {
  const EventDashboardScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView(
        keys: const ['events'],
        builder: (context) => _Dashboard(event: Store.instance.event(eventId)),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.event});
  final ClientaEvent event;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final store = Store.instance;
    final pal = context.pal;
    final registered = store.isRegistered(e.id);
    final live = e.sessions.where((s) => s.status == SessionStatus.live).firstOrNull;
    final topPad = MediaQuery.paddingOf(context).top;

    // The "Event experience" tiles keep their own colourful icons on purpose
    // (the rest of the app uses the brand palette).
    const steel = Color(0xFF5E7A86), green = Color(0xFF22B573), pink = Color(0xFFDB2FA0), orange = Color(0xFFFF8A3D);
    const indigo = Color(0xFF3B48D8), purple = Color(0xFF8B5CF6), yellow = Color(0xFFF5B400), lime = Color(0xFF7CB342);
    const red = Color(0xFFEF4444), blue = Color(0xFF29A9E1), teal = Color(0xFF14B8A6), sky = Color(0xFF29B6F6);
    final features = <(IconData, String, Color, Widget, String?)>[
      (Icons.description_rounded, 'About Event', steel, AboutEventScreen(eventId: e.id), null),
      (Icons.lightbulb_rounded, 'Tips', green, TipsScreen(eventId: e.id), null),
      (Icons.view_timeline_rounded, 'Agenda', pink, AgendaScreen(eventId: e.id), live != null ? 'LIVE' : null),
      (Icons.record_voice_over_rounded, 'Speakers', orange, SpeakersScreen(eventId: e.id), null),
      (Icons.near_me_rounded, 'Location', indigo, LocationScreen(eventId: e.id), null),
      (Icons.photo_library_rounded, 'Gallery', purple, GalleryScreen(eventId: e.id), null),
      (Icons.workspace_premium_rounded, 'Certificate', yellow, CertificatesScreen(eventId: e.id), null),
      (Icons.fact_check_rounded, 'Evaluations', lime, EvaluationsScreen(eventId: e.id), null),
      (Icons.sensors_rounded, 'Live Chat', red, LiveChatScreen(eventId: e.id), null),
      (Icons.event_note_rounded, 'Meetings', blue, const MeetingsScreen(), null),
      (Icons.groups_rounded, 'Groups', teal, GroupsScreen(eventId: e.id), null),
      (Icons.edit_note_rounded, 'My Notes', sky, NotesScreen(eventId: e.id), null),
      (Icons.contact_mail_rounded, 'Contact Us', green, ContactUsScreen(eventId: e.id), null),
      (Icons.folder_copy_rounded, 'Resources', orange, ResourcesScreen(eventId: e.id), null),
      (Icons.campaign_rounded, 'Notifications', pink, EventNotificationsScreen(eventId: e.id), null),
      (Icons.people_alt_rounded, 'Participants', indigo, const ContactsScreen(title: 'Participants'), null),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 310,
          pinned: true,
          stretch: true,
          backgroundColor: pal.bg,
          leading: const Padding(padding: EdgeInsets.all(8), child: BackBtn(light: true)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleIconBtn(
                icon: Icons.ios_share_rounded,
                size: 40,
                color: Colors.black.withValues(alpha: 0.28),
                iconColor: Colors.white,
                onTap: () => toast(context, 'Event link copied to clipboard', icon: Icons.link_rounded),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(tag: eventHeroTag(e.id), child: EventImage(event: e)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent, pal.bg],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 250),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (e.inviteOnly) const TagChip(label: 'PCU only', solid: true, color: AppColors.blueDeep, icon: Icons.lock_rounded),
                            if (e.isLive) const LiveBadge(solid: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 320),
                        child: Text(e.title, style: context.tt.headlineMedium?.copyWith(color: pal.dark ? Colors.white : pal.text)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          title: _CollapsingTitle(title: e.title),
          centerTitle: true,
          collapsedHeight: kToolbarHeight + 4,
          toolbarHeight: kToolbarHeight + 4,
          primary: true,
          automaticallyImplyLeading: false,
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 40 + topPad * 0),
          sliver: SliverList.list(
            children: [
              FadeSlideIn(
                index: 1,
                child: Text(e.tagline, style: context.tt.bodyLarge?.copyWith(color: pal.textMuted)),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                index: 2,
                child: AppCard(
                  child: Column(
                    children: [
                      InfoRow(icon: Icons.calendar_month_rounded, label: 'Date', value: fmtRange(e.start, e.end), solid: true),
                      InfoRow(icon: Icons.schedule_rounded, label: 'Starts', value: '${fmtTime12(e.start)} · ${countdown(e.start)}', color: AppColors.darkBlue80, solid: true),
                      InfoRow(
                        icon: Icons.place_rounded,
                        label: 'Venue',
                        value: '${e.venue.name}, ${e.venue.city} ${e.venue.flag}',
                        color: AppColors.blueDeep,
                        solid: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.directions_rounded, color: AppColors.blue),
                          onPressed: () => push(context, LocationScreen(eventId: e.id)),
                        ),
                      ),
                      InfoRow(icon: Icons.groups_rounded, label: 'Attendees', value: '${e.attendees} registered', color: AppColors.steel, solid: true),
                    ],
                  ),
                ),
              ),
              // Once registered, the Registered / My badge row is not shown.
              if (!registered || e.isPast) ...[
                const SizedBox(height: 14),
                FadeSlideIn(index: 3, child: _RegistrationBar(event: e, registered: registered)),
              ],
              if (live != null) ...[
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 4,
                  child: AppCard(
                    gradient: LinearGradient(colors: [Color.alphaBlend(AppColors.red.withValues(alpha: 0.12), pal.surface), Color.alphaBlend(AppColors.red.withValues(alpha: 0.03), pal.surface)]),
                    onTap: () => push(context, AgendaScreen(eventId: e.id)),
                    child: Row(
                      children: [
                        const PulseDot(size: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HAPPENING NOW · ${live.room.toUpperCase()}', style: context.tt.labelSmall?.copyWith(color: AppColors.red, letterSpacing: 0.8)),
                              const SizedBox(height: 4),
                              Text(live.title, style: context.tt.titleSmall),
                              Text('${fmtTime(live.start)}–${fmtTime(live.end)}', style: context.tt.bodySmall),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Text('Event experience', style: context.tt.titleLarge),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 66),
                itemCount: features.length,
                itemBuilder: (_, i) {
                  final f = features[i];
                  return FadeSlideIn(
                    index: 5 + i,
                    stagger: 35,
                    child: FeatureTile(icon: f.$1, label: f.$2, color: f.$3, badge: f.$5, onTap: () => push(context, f.$4)),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fades the toolbar title in only once the cover has collapsed.
class _CollapsingTitle extends StatelessWidget {
  const _CollapsingTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    var t = 1.0;
    if (settings != null && settings.maxExtent > settings.minExtent) {
      t = ((settings.maxExtent - settings.currentExtent) / (settings.maxExtent - settings.minExtent)).clamp(0.0, 1.0);
    }
    return Opacity(
      opacity: ((t - 0.75) / 0.25).clamp(0.0, 1.0),
      child: Text(title, style: context.tt.titleMedium),
    );
  }
}

class _RegistrationBar extends StatefulWidget {
  const _RegistrationBar({required this.event, required this.registered});
  final ClientaEvent event;
  final bool registered;

  @override
  State<_RegistrationBar> createState() => _RegistrationBarState();
}

class _RegistrationBarState extends State<_RegistrationBar> {
  bool _loading = false;

  Future<void> _toggle() async {
    final e = widget.event;
    if (widget.registered) {
      final ok = await confirmDialog(context, title: 'Cancel registration?', message: 'You will lose your seat for ${e.title}.', confirmLabel: 'Cancel registration', destructive: true);
      if (!ok) return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Store.instance.toggleRegistration(e.id);
    setState(() => _loading = false);
    if (!widget.registered) showRegisteredDialog(context, e);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    if (e.isPast) {
      return AppCard(
        child: Row(
          children: [
            const IconBadge(icon: Icons.history_rounded, color: AppColors.steel),
            const SizedBox(width: 12),
            Expanded(child: Text('This event has ended. Photos, resources and certificates remain available.', style: context.tt.bodyMedium)),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: widget.registered ? 'Registered' : (e.inviteOnly ? 'Request invitation' : 'Register now'),
            icon: widget.registered ? Icons.check_circle_rounded : Icons.how_to_reg_rounded,
            variant: widget.registered ? ButtonVariant.secondary : ButtonVariant.primary,
            loading: _loading,
            onPressed: _toggle,
          ),
        ),
        if (widget.registered) ...[
          const SizedBox(width: 10),
          AppButton(
            label: 'My badge',
            icon: Icons.qr_code_2_rounded,
            expanded: false,
            onPressed: () => push(context, QrScreen(eventTitle: e.title)),
          ),
        ],
      ],
    );
  }
}

/// Success pop-up after registering (or requesting an invitation) for [e].
/// Used by the event page and by the Register button on event cards.
Future<void> showRegisteredDialog(BuildContext context, ClientaEvent e) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedCheck(size: 80),
            const SizedBox(height: 16),
            Text(e.inviteOnly ? 'Request sent!' : 'You’re registered!', style: ctx.tt.titleLarge),
            const SizedBox(height: 8),
            Text(
              e.inviteOnly ? 'The organisers will confirm your invitation shortly.' : 'Your digital badge is ready. Show the QR code at the entrance.',
              textAlign: TextAlign.center,
              style: ctx.tt.bodyMedium?.copyWith(color: ctx.pal.textMuted),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Done', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}
