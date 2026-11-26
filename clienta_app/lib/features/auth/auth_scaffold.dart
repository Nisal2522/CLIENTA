import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Shared layout for authentication screens: a full-bleed photo header,
/// large title, subtitle and a scrollable form. Always rendered on white.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.icon = Icons.lock_rounded,
    this.image,
    this.imageCaption,
    this.bottom,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  final IconData icon;
  final String? image;
  final String? imageCaption;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return ForceLight(builder: (context) {
      final pal = context.pal;
      final top = MediaQuery.paddingOf(context).top;
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (image != null)
                        AuthHeroImage(asset: image!, height: 210 + top, caption: imageCaption, icon: icon)
                      else
                        SizedBox(height: top + 70),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeSlideIn(index: 1, child: Text(title, style: context.tt.headlineMedium?.copyWith(color: AppColors.navy900))),
                            const SizedBox(height: 8),
                            FadeSlideIn(index: 2, child: Text(subtitle, style: context.tt.bodyLarge?.copyWith(color: pal.textMuted))),
                            const SizedBox(height: 18),
                            for (var i = 0; i < children.length; i++) FadeSlideIn(index: 3 + i, child: children[i]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (bottom != null) SafeArea(top: false, child: bottom!),
              ],
            ),
            Positioned(
              top: top + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  BackBtn(light: image != null),
                  const Spacer(),
                  if (image == null) const ClientaLogo(size: 34),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Full-bleed photo with a slow Ken Burns zoom, rounded bottom corners,
/// a soft top shade for the status bar and a floating brand badge.
class AuthHeroImage extends StatefulWidget {
  const AuthHeroImage({super.key, required this.asset, required this.height, this.caption, this.icon, this.radius = 36});
  final String asset;
  final double height;
  final String? caption;
  final IconData? icon;
  final double radius;

  @override
  State<AuthHeroImage> createState() => _AuthHeroImageState();
}

class _AuthHeroImageState extends State<AuthHeroImage> with SingleTickerProviderStateMixin {
  late final AnimationController _zoom = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(widget.radius)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _zoom,
                    builder: (_, child) => Transform.scale(scale: 1 + 0.08 * Curves.easeInOut.transform(_zoom.value), child: child),
                    child: Image.asset(widget.asset, fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0x8C0D1424)],
                        stops: [0, 0.32, 0.55, 1],
                      ),
                    ),
                  ),
                  if (widget.caption != null)
                    Positioned(
                      left: 24,
                      bottom: 26,
                      right: 110,
                      child: Text(widget.caption!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.35)),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -26,
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              offset: const Offset(0, 0.4),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.navy900.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: widget.icon == null ? const ClientaLogo(size: 52) : IconBadge(icon: widget.icon!, size: 52, circle: true, solid: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled text field used in forms.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard,
    this.validator,
    this.suffix,
    this.maxLines = 1,
    this.initialValue,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final int maxLines;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: context.tt.labelMedium?.copyWith(color: context.pal.textMuted)),
          ),
          TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: obscure,
            keyboardType: keyboard,
            validator: validator,
            maxLines: maxLines,
            onChanged: onChanged,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon, size: 21),
              suffixIcon: suffix,
            ),
          ),
        ],
      ),
    );
  }
}

String? requiredField(String? v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null;

String? emailField(String? v) {
  if (v == null || v.trim().isEmpty) return 'Please enter your email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email address';
  return null;
}

String? passwordField(String? v) {
  if (v == null || v.isEmpty) return 'Please enter a password';
  if (v.length < 8) return 'Use at least 8 characters';
  return null;
}
