import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import 'auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _sent ? _sentView(context) : _formView(),
      ),
    );
  }

  Widget _formView() => Form(
        key: _form,
        child: AuthScaffold(
          key: const ValueKey('form'),
          title: 'Forgot password?',
          subtitle: 'Enter the email linked to your client account and we’ll send you a secure reset link.',
          icon: Icons.key_rounded,
          image: 'assets/images/forgot.jpg',
          children: [
            LabeledField(label: 'Email', controller: _email, hint: 'you@company.com', icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress, validator: emailField, textInputAction: TextInputAction.done),
            const SizedBox(height: 8),
            AppButton(label: 'Send reset link', icon: Icons.send_rounded, loading: _loading, onPressed: _send),
          ],
        ),
      );

  Widget _sentView(BuildContext context) => Scaffold(
        key: const ValueKey('sent'),
        body: SafeArea(
          child: FillScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                const AnimatedCheck(size: 120),
                const SizedBox(height: 28),
                Text('Check your inbox', style: context.tt.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  'If an account exists for ${_email.text.trim()}, you’ll receive a reset link within a few minutes. The link expires in 30 minutes.',
                  textAlign: TextAlign.center,
                  style: context.tt.bodyLarge?.copyWith(color: context.pal.textMuted),
                ),
                const Spacer(),
                AppButton(label: 'Back to sign in', onPressed: () => Navigator.pop(context)),
                const SizedBox(height: 10),
                AppButton(label: 'Resend email', variant: ButtonVariant.ghost, onPressed: () => toast(context, 'Reset link sent again')),
              ],
            ),
          ),
        ),
      );
}
