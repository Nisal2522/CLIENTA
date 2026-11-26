import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../shell/main_shell.dart';
import 'register_screen.dart';
import 'auth_scaffold.dart';

/// Signs the user in and opens the app.
void enterApp(BuildContext context, AppUser user) {
  AppState.instance.signIn(user);
  replaceAll(context, const MainShell());
}

/// Employee single sign-on button. In production this hands off to Microsoft
/// Entra ID (MSAL), so CLIENTA never sees the password. The prototype shows a
/// short loading state and signs in a demo employee.
class EmployeeSignInButton extends StatefulWidget {
  const EmployeeSignInButton({super.key, this.label = 'PCU employee sign-in'});
  final String label;

  @override
  State<EmployeeSignInButton> createState() => _EmployeeSignInButtonState();
}

class _EmployeeSignInButtonState extends State<EmployeeSignInButton> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    enterApp(context, AppState.demoEmployee());
  }

  @override
  Widget build(BuildContext context) => AppButton(
        label: widget.label,
        variant: ButtonVariant.secondary,
        leading: const MicrosoftMark(),
        loading: _loading,
        onPressed: _signIn,
      );
}

class MicrosoftMark extends StatelessWidget {
  const MicrosoftMark({super.key, this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = (size - 2) / 2;
    Widget sq(Color c) => Container(width: s, height: s, color: c);
    return SizedBox.square(
      dimension: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(const Color(0xFFF25022)), sq(const Color(0xFF7FBA00))]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [sq(const Color(0xFF00A4EF)), sq(const Color(0xFFFFB900))]),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final heroH = (size.height * 0.56).clamp(320.0, 540.0);
    final pal = context.pal;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FillScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AuthHeroImage(asset: 'assets/images/welcome.jpg', height: heroH, radius: 42),
                Positioned(
                  left: 24,
                  right: 100,
                  bottom: 34,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        child: GlassCard(
                          radius: 30,
                          blur: 12,
                          tint: Colors.white.withValues(alpha: 0.18),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulseDot(color: AppColors.green, size: 6),
                              Flexible(child: Text('Events · Networking · Insights', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const FadeSlideIn(
                        index: 1,
                        delay: Duration(milliseconds: 150),
                        child: Text(
                          'Let’s explore what’s happening at Control Union',
                          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Full width so the wordmark lines up with the buttons below.
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FadeSlideIn(
                    index: 2,
                    child: Text('CLIENTA', style: TextStyle(color: AppColors.navy900, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 5)),
                  ),
                  const SizedBox(height: 4),
                  FadeSlideIn(
                    index: 3,
                    child: Text('A Smarter Way to Collaborate with Clients', style: TextStyle(color: pal.textMuted, fontSize: 14.5)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Column(
                children: [
                  FadeSlideIn(
                    index: 4,
                    child: AppButton(
                      label: 'Register as Client',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () => push(context, const RegisterScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    index: 5,
                    child: const EmployeeSignInButton(),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    index: 7,
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => showAppSheet(context, builder: (_) => const _SupportSheet()),
                              child: Text('Need support?', style: TextStyle(color: pal.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                            Text('   ·   v2.0.08', style: TextStyle(color: pal.textFaint, fontSize: 11.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need help signing in?', style: context.tt.titleLarge),
          const SizedBox(height: 6),
          Text('Our client support team is available Monday–Friday, 8:30–17:30 (GMT+5:30).', style: context.tt.bodyMedium?.copyWith(color: context.pal.textMuted)),
          const SizedBox(height: 16),
          const InfoRow(icon: Icons.mail_rounded, label: 'Email', value: 'clienta.support@example.com'),
          const InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: '+94 11 555 0000', color: AppColors.blue),
          const InfoRow(icon: Icons.badge_rounded, label: 'PCU employees', value: 'Use “Sign in with Peterson & Control Union”', color: AppColors.blueDeep),
          const SizedBox(height: 16),
          AppButton(label: 'Got it', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
