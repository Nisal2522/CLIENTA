import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'animations.dart';

/// Fills the viewport (so Spacers work) but scrolls on short screens.
class FillScrollView extends StatelessWidget {
  const FillScrollView({super.key, required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: (box.maxHeight - padding.vertical).clamp(0, double.infinity)),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

/// Solid rounded card with soft shadow (fast; use in long lists).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.onTap,
    this.color,
    this.gradient,
    this.border = true,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final bool border;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? pal.surface) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          border: border ? Border.all(color: pal.border.withValues(alpha: pal.dark ? 0.7 : 1)) : null,
          boxShadow: [
            BoxShadow(color: pal.shadow, blurRadius: 22, offset: const Offset(0, 10), spreadRadius: -8),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Frosted glass card for overlays on imagery and gradients.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.onTap,
    this.tint,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? pal.glass,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: pal.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.padding = const EdgeInsets.fromLTRB(20, 26, 12, 12)});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.tt.titleLarge)),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: AppColors.blue, textStyle: const TextStyle(fontWeight: FontWeight.w700)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(action!), const SizedBox(width: 2), const Icon(Icons.chevron_right_rounded, size: 18)],
              ),
            ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.color = AppColors.blue, this.icon, this.solid = false, this.small = false});
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3.5 : 5),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 11 : 13, color: solid ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: solid ? Colors.white : color,
                fontSize: small ? 10.5 : 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value, this.color = AppColors.blue, this.trailing, this.solid = false});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Widget? trailing;

  /// Solid round icon (as on the event feature tiles) instead of a tinted square.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: solid ? 40 : 42, circle: solid, solid: solid),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.tt.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: context.tt.titleSmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded tinted square with an icon.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.color = AppColors.blue, this.size = 44, this.circle = false, this.solid = false});
  final IconData icon;
  final Color color;
  final double size;
  final bool circle;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? null : color.withValues(alpha: 0.14),
        gradient: solid
            ? LinearGradient(colors: [Color.lerp(color, Colors.white, 0.15)!, color], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.32),
        boxShadow: solid ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))] : null,
      ),
      child: Icon(icon, color: solid ? Colors.white : color, size: size * 0.48),
    );
  }
}

/// Event feature tile (About, Agenda, Speakers …) — coloured circular icon + label.
class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.icon, required this.label, required this.color, this.onTap, this.badge});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: pal.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            IconBadge(icon: icon, color: color, size: 40, circle: true, solid: true),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 13.5)),
            ),
            if (badge != null) TagChip(label: badge!, color: AppColors.red, small: true, solid: true),
          ],
        ),
      ),
    );
  }
}

/// Segmented filter chip row with an animated selection.
class ChoiceChips extends StatelessWidget {
  const ChoiceChips({super.key, required this.options, required this.selected, required this.onSelected, this.padding = const EdgeInsets.symmetric(horizontal: 20)});
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i];
          final sel = o == selected;
          return Pressable(
            onTap: () => onSelected(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: sel ? AppColors.brandGradient : null,
                color: sel ? null : pal.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? Colors.transparent : pal.border),
                boxShadow: sel ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
              ),
              child: Text(
                o,
                style: TextStyle(
                  color: sel ? Colors.white : pal.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Search field with consistent styling.
class SearchField extends StatelessWidget {
  const SearchField({super.key, this.hint = 'Search', this.onChanged, this.controller, this.onTap, this.readOnly = false, this.trailing, this.autofocus = false});
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? trailing;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: pal.surface,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: trailing,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: pal.border)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

/// Settings-style row.
class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.icon, required this.title, this.subtitle, this.color = AppColors.blue, this.onTap, this.trailing, this.destructive = false});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            IconBadge(icon: icon, color: destructive ? AppColors.red : color, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.tt.titleSmall?.copyWith(color: destructive ? AppColors.red : pal.text, fontSize: 14.5)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: context.tt.bodySmall),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: pal.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Groups MenuTiles in a card.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children, this.title});
  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 18, 8, 10),
            child: Text(title!.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: pal.textFaint, letterSpacing: 1.1)),
          ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) Divider(height: 1, indent: 70, endIndent: 16, color: pal.border.withValues(alpha: 0.6)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
