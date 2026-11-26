import 'package:flutter/material.dart';

import '../theme.dart';
import 'animations.dart';

enum ButtonVariant { primary, secondary, ghost, danger, light }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.loading = false,
    this.variant = ButtonVariant.primary,
    this.expanded = true,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool loading;
  final ButtonVariant variant;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final disabled = onPressed == null && !loading;
    final (Gradient? gradient, Color? bg, Color fg, Color? borderColor) = switch (variant) {
      ButtonVariant.primary => (AppColors.brandGradient, null, Colors.white, null),
      ButtonVariant.secondary => (null, pal.surfaceAlt, pal.text, pal.border),
      ButtonVariant.ghost => (null, Colors.transparent, AppColors.blue, AppColors.blue.withValues(alpha: 0.5)),
      ButtonVariant.danger => (null, AppColors.red, Colors.white, null),
      ButtonVariant.light => (null, Colors.white, AppColors.navy900, null),
    };

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: a, child: c)),
      child: loading
          ? SizedBox(
              key: const ValueKey('l'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('c'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 9)],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.1),
                  ),
                ),
              ],
            ),
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Pressable(
        onTap: loading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: gradient,
            color: bg,
            borderRadius: BorderRadius.circular(height * 0.32),
            border: borderColor != null ? Border.all(color: borderColor, width: 1.2) : null,
            boxShadow: variant == ButtonVariant.primary && !disabled
                ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.38), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4)]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Circular icon button with optional animated badge.
class CircleIconBtn extends StatelessWidget {
  const CircleIconBtn({super.key, required this.icon, this.onTap, this.badge = 0, this.size = 42, this.child, this.color, this.iconColor});
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;
  final double size;
  final Widget? child;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color ?? pal.surface,
                shape: BoxShape.circle,
                border: Border.all(color: pal.border.withValues(alpha: 0.8)),
              ),
              child: Center(child: child ?? Icon(icon, size: size * 0.47, color: iconColor ?? pal.text)),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                child: badge > 0
                    ? Container(
                        key: ValueKey(badge),
                        constraints: const BoxConstraints(minWidth: 19),
                        height: 19,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: pal.bg, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(badge > 9 ? '9+' : '$badge', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                      )
                    : const SizedBox.shrink(key: ValueKey(0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back button used in custom headers.
class BackBtn extends StatelessWidget {
  const BackBtn({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return CircleIconBtn(
      icon: Icons.arrow_back_ios_new_rounded,
      size: 40,
      color: light ? Colors.black.withValues(alpha: 0.28) : null,
      iconColor: light ? Colors.white : null,
      onTap: () => Navigator.of(context).maybePop(),
    );
  }
}
