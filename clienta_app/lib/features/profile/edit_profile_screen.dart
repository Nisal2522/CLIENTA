import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../auth/auth_scaffold.dart';
import '../events/section_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final u = AppState.instance.user!;
  late final _name = TextEditingController(text: u.name);
  late final _title = TextEditingController(text: u.title);
  late final _company = TextEditingController(text: u.company);
  late final _phone = TextEditingController(text: u.phone);
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _title, _company, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    AppState.instance.update(() {
      u.name = _name.text.trim();
      u.title = _title.text.trim();
      u.company = _company.text.trim();
      u.phone = _phone.text.trim();
    });
    Navigator.pop(context);
    toast(context, 'Profile updated');
  }

  void _photoSheet() {
    showAppSheet(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuTile(icon: Icons.photo_library_rounded, title: 'Choose from library', onTap: () {
              Navigator.pop(ctx);
              AppState.instance.update(() => u.photoUrl = 'assets/images/profile/${u.isEmployee ? 'dilini' : 'induwara'}.jpg');
              setState(() {});
            }),
            MenuTile(icon: Icons.camera_alt_rounded, title: 'Take a photo', color: AppColors.blueDeep, onTap: () {
              Navigator.pop(ctx);
              toast(context, 'Camera opened (prototype)', icon: Icons.camera_alt_rounded);
            }),
            MenuTile(icon: Icons.delete_outline_rounded, title: 'Remove photo', destructive: true, onTap: () {
              Navigator.pop(ctx);
              AppState.instance.update(() => u.photoUrl = null);
              setState(() {});
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: 'Edit Profile',
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Center(
              child: Pressable(
                onTap: _photoSheet,
                child: Stack(
                  children: [
                    Hero(tag: 'profile-avatar', child: AppAvatar(name: u.name, url: u.photoUrl, size: 110, ring: true)),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle, border: Border.all(color: context.pal.bg, width: 3)),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            LabeledField(label: 'Full name', controller: _name, icon: Icons.person_outline_rounded, validator: requiredField),
            LabeledField(label: 'Job title', controller: _title, icon: Icons.work_outline_rounded),
            LabeledField(label: 'Company', controller: _company, icon: Icons.apartment_rounded, validator: requiredField),
            LabeledField(label: 'Mobile number', controller: _phone, icon: Icons.phone_iphone_rounded, keyboard: TextInputType.phone),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const IconBadge(icon: Icons.mail_lock_rounded, color: AppColors.steel),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.email, style: context.tt.titleSmall),
                          Text(u.isEmployee ? 'Managed by your organisation' : 'Change email in Account management', style: context.tt.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppButton(label: 'Save changes', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
