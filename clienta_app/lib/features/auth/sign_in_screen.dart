import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import 'auth_scaffold.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'induwara.perera@example.com');
  final _password = TextEditingController();
  bool _hide = true;
  bool _remember = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    final user = AppState.demoClient()..email = _email.text.trim();
    enterApp(context, user);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Form(
      key: _form,
      child: AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Sign in to your CLIENTA client account to continue.',
        icon: Icons.login_rounded,
        image: 'assets/images/signin.jpg',
        imageCaption: 'Your events, contacts and certificates — all in one place.',
        children: [
          LabeledField(label: 'Email', controller: _email, hint: 'you@company.com', icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress, validator: emailField),
          LabeledField(
            label: 'Password',
            controller: _password,
            hint: 'At least 8 characters (demo: any)',
            icon: Icons.lock_outline_rounded,
            obscure: _hide,
            validator: passwordField,
            textInputAction: TextInputAction.done,
            suffix: IconButton(
              icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              onPressed: () => setState(() => _hide = !_hide),
            ),
          ),
          Row(
            children: [
              Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
              Text('Remember me', style: context.tt.bodyMedium),
              const Spacer(),
              TextButton(
                onPressed: () => push(context, const ForgotPasswordScreen()),
                child: const Text('Forgot password?', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Sign in', loading: _loading, onPressed: _submit),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Divider(color: pal.border)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: context.tt.bodySmall)),
              Expanded(child: Divider(color: pal.border)),
            ],
          ),
          const SizedBox(height: 22),
          const EmployeeSignInButton(label: 'Peterson & Control Union employee'),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(AppRoute(const RegisterScreen())),
              child: Text.rich(TextSpan(
                style: TextStyle(color: pal.textMuted),
                children: const [
                  TextSpan(text: 'New to CLIENTA?  '),
                  TextSpan(text: 'Register as Client', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800)),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
