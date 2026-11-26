import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../auth/welcome_screen.dart';
import '../common/qr_screen.dart';
import '../events/certificates_screen.dart';
import '../events/notes_screen.dart';
import '../shell/main_shell.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'certificates', 'notes', 'chats'],
      builder: (context) => ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => const _ProfileBody(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(context, title: 'Log out?', message: 'You’ll need to sign in again to access your events and messages.', confirmLabel: 'Log out', destructive: true);
    if (!ok || !context.mounted) return;
    AppState.instance.signOut();
    replaceAll(context, const WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final u = AppState.instance.user!;
    final store = Store.instance;
    final pal = context.pal;
    final meetings = store.threads.expand((t) => t.messages).where((m) => m.type == MessageType.meeting && m.meeting?.status == MeetingStatus.accepted).length;
    final stats = [
      (store.registeredEvents.length, 'Events'),
      (store.certificates.length, 'Certificates'),
      (store.notes.length, 'Notes'),
      (meetings, 'Meetings'),
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 20, kNavBarSpace),
      children: [
        // Same header style as the other sub-screens (e.g. Knowledge Hub).
        FadeSlideIn(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Your account & activity', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
                  ],
                ),
              ),
              CircleIconBtn(icon: Icons.settings_rounded, size: 44, onTap: () => push(context, const SettingsScreen())),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          index: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.navyGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: AppColors.navy900.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -6)],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(right: -40, top: -50, child: Opacity(opacity: 0.18, child: const ClientaLogo(size: 180))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(tag: 'profile-avatar', child: AppAvatar(name: u.name, url: u.photoUrl, size: 74, ring: true, online: true)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(u.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  TagChip(label: u.isEmployee ? 'PCU Employee' : 'Client', color: u.isEmployee ? AppColors.blueDeep : AppColors.blue, solid: true, small: true),
                                  TagChip(label: '${u.flag} ${u.country}', color: Colors.white, small: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, color: Colors.white60, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.company, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded, color: Colors.white60, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(u.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppButton(label: 'Edit profile', icon: Icons.edit_rounded, variant: ButtonVariant.light, height: 46, onPressed: () => push(context, const EditProfileScreen()))),
                        const SizedBox(width: 10),
                        Pressable(
                          onTap: () => push(context, const QrScreen()),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)),
                            child: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          index: 2,
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  Expanded(
                    child: Column(
                      children: [
                        CountUp(value: stats[i].$1, style: context.tt.headlineSmall?.copyWith(color: AppColors.blue)),
                        Text(stats[i].$2, style: context.tt.bodySmall),
                      ],
                    ),
                  ),
                  if (i < stats.length - 1) Container(width: 1, height: 34, color: pal.border),
                ],
              ],
            ),
          ),
        ),
        FadeSlideIn(
          index: 3,
          child: MenuGroup(
            title: 'My activity',
            children: [
              MenuTile(icon: Icons.event_available_rounded, title: 'My events', subtitle: '${store.registeredEvents.length} registered', onTap: () => ShellScope.maybeOf(context)?.goTo(1)),
              MenuTile(icon: Icons.workspace_premium_rounded, title: 'My certificates', color: AppColors.darkBlue80, onTap: () => push(context, const CertificatesScreen())),
              MenuTile(icon: Icons.edit_note_rounded, title: 'My notes', color: AppColors.blue, onTap: () => push(context, const NotesScreen())),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          index: 4,
          child: Center(
            child: TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: const Text('Log out'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
