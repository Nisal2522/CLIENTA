import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import 'auth_scaffold.dart';
import 'terms_screen.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _forms = List.generate(3, (_) => GlobalKey<FormState>());
  int _step = 0;
  bool _loading = false;
  bool _done = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _title = TextEditingController();
  final _clientId = TextEditingController();
  final _password = TextEditingController();
  String _country = 'Sri Lanka';
  String _industry = 'Textiles & Apparel';
  bool _terms = false;
  bool _updates = true;
  bool _hide = true;

  static const _countries = {'Sri Lanka': '🇱🇰', 'India': '🇮🇳', 'Bangladesh': '🇧🇩', 'China': '🇨🇳', 'Netherlands': '🇳🇱', 'Other': '🌍'};
  static const _industries = ['Textiles & Apparel', 'Agriculture & Food', 'Forestry', 'Energy', 'Retail & Brands', 'Other'];
  static const _steps = ['Personal', 'Company', 'Account'];

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _company, _title, _clientId, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (!_forms[_step].currentState!.validate()) return;
    if (_step == 2 && !_terms) {
      toast(context, 'Please accept the Terms & Privacy Policy', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _done = true);
  }

  void _finish() {
    enterApp(
      context,
      AppUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        company: _company.text.trim(),
        title: _title.text.trim().isEmpty ? 'Client' : _title.text.trim(),
        country: _country,
        flag: _countries[_country]!,
        phone: _phone.text.trim(),
        role: UserRole.client,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _success(context);
    final pal = context.pal;
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: AuthScaffold(
        title: 'Register as Client',
        subtitle: 'Create your CLIENTA account in three quick steps.',
        icon: Icons.person_add_alt_1_rounded,
        image: 'assets/images/register.jpg',
        imageCaption: 'Join clients worldwide collaborating with Peterson & Control Union.',
        bottom: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(child: AppButton(label: 'Back', variant: ButtonVariant.secondary, onPressed: () => setState(() => _step--))),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: AppButton(label: _step == 2 ? 'Create account' : 'Continue', loading: _loading, onPressed: _next),
              ),
            ],
          ),
        ),
        children: [
          Row(
            children: List.generate(3, (i) {
              final active = i <= _step;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.brandGradient : null,
                          color: active ? null : pal.surfaceAlt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${i + 1}. ${_steps[i]}', style: context.tt.labelMedium?.copyWith(color: active ? AppColors.blue : pal.textFaint)),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(a), child: c),
            ),
            child: KeyedSubtree(key: ValueKey(_step), child: _stepBody(context)),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(BuildContext context) {
    switch (_step) {
      case 0:
        return Form(
          key: _forms[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(label: 'Full name', controller: _name, hint: 'e.g. Induwara Perera', icon: Icons.person_outline_rounded, validator: requiredField),
              LabeledField(label: 'Work email', controller: _email, hint: 'you@company.com', icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress, validator: emailField),
              LabeledField(label: 'Mobile number', controller: _phone, hint: '+94 7X XXX XXXX', icon: Icons.phone_iphone_rounded, keyboard: TextInputType.phone, validator: requiredField),
              _label(context, 'Country'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _countries.entries.map((e) => _choice(e.key, '${e.value}  ${e.key}', _country, (v) => setState(() => _country = v))).toList(),
              ),
            ],
          ),
        );
      case 1:
        return Form(
          key: _forms[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(label: 'Company name', controller: _company, hint: 'e.g. Crystal Apparel (Pvt) Ltd', icon: Icons.apartment_rounded, validator: requiredField),
              LabeledField(label: 'Job title', controller: _title, hint: 'e.g. Sustainability Manager', icon: Icons.work_outline_rounded),
              LabeledField(label: 'Client ID (optional)', controller: _clientId, hint: 'Found on your certificate or invoice', icon: Icons.badge_outlined),
              _label(context, 'Industry'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _industries.map((e) => _choice(e, e, _industry, (v) => setState(() => _industry = v))).toList(),
              ),
            ],
          ),
        );
      default:
        return Form(
          key: _forms[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(
                label: 'Create password',
                controller: _password,
                hint: 'At least 8 characters',
                icon: Icons.lock_outline_rounded,
                obscure: _hide,
                validator: passwordField,
                onChanged: (_) => setState(() {}),
                suffix: IconButton(icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded), onPressed: () => setState(() => _hide = !_hide)),
              ),
              _StrengthMeter(password: _password.text),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Confirm password',
                hint: 'Re-enter password',
                icon: Icons.lock_reset_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              ),
              _check(
                context,
                _terms,
                (v) => setState(() => _terms = v),
                Text.rich(TextSpan(children: [
                  const TextSpan(text: 'I agree to the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => push(context, const TermsScreen()),
                      child: const Text('Terms & Privacy Policy', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ])),
              ),
              _check(context, _updates, (v) => setState(() => _updates = v), const Text('Send me PCU news and event invitations')),
            ],
          ),
        );
    }
  }

  Widget _label(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
        child: Text(t, style: context.tt.labelMedium?.copyWith(color: context.pal.textMuted)),
      );

  Widget _choice(String value, String label, String selected, ValueChanged<String> onTap) {
    final sel = value == selected;
    final pal = context.pal;
    return Pressable(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? AppColors.blue.withValues(alpha: 0.14) : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.blue : Colors.transparent, width: 1.4),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: sel ? AppColors.blue : pal.text, fontSize: 13.5)),
      ),
    );
  }

  Widget _check(BuildContext context, bool value, ValueChanged<bool> onChanged, Widget label) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
              Expanded(child: DefaultTextStyle.merge(style: context.tt.bodyMedium, child: label)),
            ],
          ),
        ),
      );

  Widget _success(BuildContext context) => Scaffold(
        body: SafeArea(
          child: FillScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                const AnimatedCheck(size: 130),
                const SizedBox(height: 28),
                FadeSlideIn(child: Text('Welcome to CLIENTA, ${_name.text.trim().split(' ').first}!', textAlign: TextAlign.center, style: context.tt.headlineSmall)),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    'Your client account is ready. We’ve sent a verification email to ${_email.text.trim()}.',
                    textAlign: TextAlign.center,
                    style: context.tt.bodyLarge?.copyWith(color: context.pal.textMuted),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(index: 2, child: AppButton(label: 'Explore CLIENTA', icon: Icons.arrow_forward_rounded, onPressed: _finish)),
              ],
            ),
          ),
        ),
      );
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    const labels = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = [AppColors.red, AppColors.red, AppColors.orange, AppColors.blue, AppColors.green];
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: i < score ? colors[score] : context.pal.surfaceAlt,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        SizedBox(width: 64, child: Text(labels[score], textAlign: TextAlign.end, style: TextStyle(color: colors[score], fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }
}
