import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../auth/onboarding_screen.dart';
import '../auth/welcome_screen.dart';
import '../common/permission_screen.dart';
import '../events/section_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SectionScaffold(
      title: 'Settings',
      body: ListenableBuilder(
        listenable: Listenable.merge([app, ThemeController.instance]),
        builder: (context, _) => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            MenuGroup(
              title: 'Appearance',
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      for (final (mode, icon, label) in [
                        (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
                        (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
                        (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Pressable(
                              onTap: () => ThemeController.instance.value = mode,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: ThemeController.instance.value == mode ? AppColors.brandGradient : null,
                                  color: ThemeController.instance.value == mode ? null : context.pal.surfaceAlt,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(icon, color: ThemeController.instance.value == mode ? Colors.white : context.pal.textMuted),
                                    const SizedBox(height: 6),
                                    Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: ThemeController.instance.value == mode ? Colors.white : context.pal.text)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            MenuGroup(
              title: 'Notifications',
              children: [
                for (final e in app.notificationPrefs.entries)
                  MenuTile(
                    icon: Icons.notifications_rounded,
                    title: e.key,
                    color: AppColors.blue,
                    trailing: Switch.adaptive(value: e.value, onChanged: (v) => app.update(() => app.notificationPrefs[e.key] = v)),
                    onTap: () => app.update(() => app.notificationPrefs[e.key] = !e.value),
                  ),
              ],
            ),
            MenuGroup(
              title: 'General',
              children: [
                MenuTile(icon: Icons.language_rounded, title: 'Language', subtitle: app.language, color: AppColors.blue, onTap: () => push(context, const LanguageScreen())),
                MenuTile(icon: Icons.shield_rounded, title: 'Privacy settings', color: AppColors.blueDeep, onTap: () => push(context, const PrivacySettingsScreen())),
                MenuTile(icon: Icons.manage_accounts_rounded, title: 'Account management', color: AppColors.steel, onTap: () => push(context, const AccountManagementScreen())),
                MenuTile(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Clear cache',
                  subtitle: '48.2 MB of images and documents',
                  color: AppColors.darkGrey,
                  onTap: () => toast(context, 'Cache cleared'),
                ),
              ],
            ),
            MenuGroup(
              title: 'Prototype tools',
              children: [
                MenuTile(
                  icon: Icons.wifi_off_rounded,
                  title: 'Simulate offline',
                  subtitle: 'Shows offline banner & states',
                  color: AppColors.steel,
                  trailing: Switch.adaptive(value: app.offline, onChanged: (v) => app.update(() => app.offline = v)),
                  onTap: () => app.update(() => app.offline = !app.offline),
                ),
                MenuTile(
                  icon: Icons.error_outline_rounded,
                  title: 'Simulate server errors',
                  subtitle: 'New requests fail with an error state',
                  color: AppColors.darkBlue80,
                  trailing: Switch.adaptive(value: app.simulateErrors, onChanged: (v) => app.update(() => app.simulateErrors = v)),
                  onTap: () => app.update(() => app.simulateErrors = !app.simulateErrors),
                ),
                MenuTile(icon: Icons.widgets_rounded, title: 'UI states gallery', subtitle: 'Loading, empty, error, offline, permissions', color: AppColors.blueDeep, onTap: () => push(context, const StatesDemoScreen())),
                MenuTile(icon: Icons.slideshow_rounded, title: 'Replay onboarding', color: AppColors.blue, onTap: () => push(context, const OnboardingScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _langs = [
    ('English', 'English', '🇬🇧'),
    ('සිංහල', 'Sinhala', '🇱🇰'),
    ('தமிழ்', 'Tamil', '🇱🇰'),
    ('Nederlands', 'Dutch', '🇳🇱'),
    ('中文', 'Chinese', '🇨🇳'),
    ('हिन्दी', 'Hindi', '🇮🇳'),
    ('বাংলা', 'Bengali', '🇧🇩'),
    ('Italiano', 'Italian', '🇮🇹'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SectionScaffold(
      title: 'Language',
      subtitle: 'Choose your app language',
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            for (var i = 0; i < _langs.length; i++)
              FadeSlideIn(
                index: i,
                child: AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: app.language == _langs[i].$2 ? AppColors.blue.withValues(alpha: 0.1) : null,
                  onTap: () {
                    app.update(() => app.language = _langs[i].$2);
                    toast(context, 'Language set to ${_langs[i].$2}${_langs[i].$2 == 'English' ? '' : ' (preview, translations coming soon)'}');
                  },
                  child: Row(
                    children: [
                      Text(_langs[i].$3, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_langs[i].$1, style: context.tt.titleSmall?.copyWith(fontSize: 15)),
                            Text(_langs[i].$2, style: context.tt.bodySmall),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: app.language == _langs[i].$2
                            ? const Icon(Icons.check_circle_rounded, key: ValueKey('y'), color: AppColors.blue)
                            : Icon(Icons.circle_outlined, key: const ValueKey('n'), color: context.pal.textFaint),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    return SectionScaffold(
      title: 'Privacy',
      subtitle: 'Control what others can see',
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            MenuGroup(
              title: 'Visibility & data',
              children: [
                for (final e in app.privacyPrefs.entries)
                  MenuTile(
                    icon: Icons.visibility_rounded,
                    title: e.key,
                    color: AppColors.blueDeep,
                    trailing: Switch.adaptive(value: e.value, onChanged: (v) => app.update(() => app.privacyPrefs[e.key] = v)),
                    onTap: () => app.update(() => app.privacyPrefs[e.key] = !e.value),
                  ),
              ],
            ),
            MenuGroup(
              title: 'Device permissions',
              children: [
                for (final (kind, icon, label) in [
                  (PermissionKind.notifications, Icons.notifications_rounded, 'Notifications'),
                  (PermissionKind.camera, Icons.camera_alt_rounded, 'Camera'),
                  (PermissionKind.location, Icons.location_on_rounded, 'Location'),
                ])
                  MenuTile(
                    icon: icon,
                    title: label,
                    subtitle: app.grantedPermissions.contains(kind.name) ? 'Allowed' : 'Not allowed',
                    color: app.grantedPermissions.contains(kind.name) ? AppColors.green : AppColors.steel,
                    onTap: () => push(context, PermissionScreen(kind: kind, onDone: (ctx, _) {
                      Navigator.pop(ctx);
                      app.update(() {});
                    })),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('We never sell your data. Read the Privacy Policy for details on how CLIENTA uses your information.', style: context.tt.bodySmall),
          ],
        ),
      ),
    );
  }
}

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = AppState.instance.user!;
    return SectionScaffold(
      title: 'Account',
      subtitle: u.email,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          MenuGroup(
            title: 'Sign-in & security',
            children: [
              if (u.isEmployee)
                const MenuTile(icon: Icons.badge_rounded, title: 'Microsoft organisation account', subtitle: 'Single sign-on enabled', color: AppColors.blue, trailing: Icon(Icons.verified_rounded, color: AppColors.green))
              else ...[
                MenuTile(icon: Icons.password_rounded, title: 'Change password', subtitle: 'Last changed 3 months ago', onTap: () => showAppSheet(context, builder: (_) => const _ChangePasswordSheet())),
                MenuTile(icon: Icons.alternate_email_rounded, title: 'Change email', color: AppColors.blueDeep, onTap: () => toast(context, 'Verification email sent', icon: Icons.mark_email_read_rounded)),
              ],
              MenuTile(icon: Icons.phonelink_lock_rounded, title: 'Two-step verification', subtitle: 'On · Authenticator app', color: AppColors.blue, onTap: () {}),
              MenuTile(icon: Icons.devices_rounded, title: 'Active sessions', subtitle: 'This phone · Chrome on Windows', color: AppColors.steel, onTap: () => toast(context, 'Signed out of other sessions')),
            ],
          ),
          MenuGroup(
            title: 'Your data',
            children: [
              MenuTile(icon: Icons.download_rounded, title: 'Download my data', subtitle: 'Profile, notes, messages (JSON)', color: AppColors.darkGrey, onTap: () => toast(context, 'We’ll email your data export within 24 hours', icon: Icons.mark_email_read_rounded)),
            ],
          ),
          MenuGroup(
            title: 'Danger zone',
            children: [
              MenuTile(
                icon: Icons.delete_forever_rounded,
                title: 'Delete account',
                subtitle: 'Permanently remove your account and data',
                destructive: true,
                onTap: () async {
                  final ok = await confirmDialog(context, title: 'Delete account?', message: 'This permanently removes your profile, notes and messages. This cannot be undone.', confirmLabel: 'Delete', destructive: true);
                  if (!ok || !context.mounted) return;
                  AppState.instance.signOut();
                  replaceAll(context, const WelcomeScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change password', style: context.tt.titleLarge),
          const SizedBox(height: 16),
          const TextField(obscureText: true, decoration: InputDecoration(hintText: 'Current password', prefixIcon: Icon(Icons.lock_outline_rounded))),
          const SizedBox(height: 10),
          const TextField(obscureText: true, decoration: InputDecoration(hintText: 'New password', prefixIcon: Icon(Icons.lock_reset_rounded))),
          const SizedBox(height: 16),
          AppButton(
            label: 'Update password',
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              await Future.delayed(const Duration(milliseconds: 900));
              if (!context.mounted) return;
              Navigator.pop(context);
              toast(context, 'Password updated');
            },
          ),
        ],
      ),
    );
  }
}

/// Showcases every system state used across the app.
class StatesDemoScreen extends StatefulWidget {
  const StatesDemoScreen({super.key});

  @override
  State<StatesDemoScreen> createState() => _StatesDemoScreenState();
}

class _StatesDemoScreenState extends State<StatesDemoScreen> {
  String _state = 'Loading';

  @override
  Widget build(BuildContext context) {
    final body = switch (_state) {
      'Loading' => const SkeletonList(withHero: true),
      'Empty' => StateView.empty(icon: Icons.event_busy_rounded, title: 'No events yet', message: 'When you register for events they will appear here.', actionLabel: 'Browse events', onAction: () {}),
      'Error' => StateView.error(onRetry: () => toast(context, 'Retrying…', icon: Icons.refresh_rounded)),
      'Offline' => StateView.offline(onRetry: () => toast(context, 'Still offline', icon: Icons.wifi_off_rounded, color: AppColors.orange)),
      'Success' => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedCheck(key: UniqueKey(), size: 120),
              const SizedBox(height: 16),
              Text('Submitted!', style: context.tt.headlineSmall),
            ],
          ),
        ),
      _ => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final (k, label) in [(PermissionKind.notifications, 'Notifications'), (PermissionKind.camera, 'Camera'), (PermissionKind.location, 'Location')])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppButton(
                  label: '$label permission screen',
                  variant: ButtonVariant.secondary,
                  onPressed: () => push(context, PermissionScreen(kind: k, onDone: (ctx, _) => Navigator.pop(ctx))),
                ),
              ),
          ],
        ),
    };
    return SectionScaffold(
      title: 'UI States',
      subtitle: 'System states used across CLIENTA',
      body: Column(
        children: [
          ChoiceChips(options: const ['Loading', 'Empty', 'Error', 'Offline', 'Success', 'Permissions'], selected: _state, onSelected: (v) => setState(() => _state = v)),
          Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: KeyedSubtree(key: ValueKey(_state), child: body))),
        ],
      ),
    );
  }
}
