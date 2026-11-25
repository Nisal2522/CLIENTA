import 'package:flutter/material.dart';

import '../../data/api.dart';
import '../../data/store.dart';
import '../theme.dart';
import 'animations.dart';
import 'buttons.dart';

/// Shimmer effect wrapper for skeleton placeholders.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final hi = pal.dark ? const Color(0xFF2A3956) : const Color(0xFFF7F9FC);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [pal.skeleton, hi, pal.skeleton],
          stops: const [0.25, 0.5, 0.75],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: _Slide(_c.value * 2.4 - 1.2),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.p);
  final double p;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * p, 0, 0);
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 10, this.circle = false});
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
        width: circle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: context.pal.skeleton,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// Generic list skeleton (avatar + two lines).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.withHero = false});
  final int count;
  final bool withHero;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          if (withHero) ...[
            const SkeletonBox(height: 190, radius: 26),
            const SizedBox(height: 22),
          ],
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  const SkeletonBox(height: 54, radius: 16, width: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120 + (i % 3) * 40.0, height: 14),
                        const SizedBox(height: 10),
                        const SkeletonBox(height: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum StateKind { empty, error, offline, permission }

/// Illustrated empty / error / offline state with an optional action.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.blue,
    this.compact = false,
  });

  factory StateView.empty({String title = 'Nothing here yet', String message = 'When there is something to show, it will appear here.', IconData icon = Icons.inbox_rounded, String? actionLabel, VoidCallback? onAction}) =>
      StateView(icon: icon, title: title, message: message, actionLabel: actionLabel, onAction: onAction);

  factory StateView.error({VoidCallback? onRetry, String? message}) => StateView(
        icon: Icons.cloud_off_rounded,
        color: AppColors.red,
        title: 'Something went wrong',
        message: message ?? 'We couldn’t load this content. Please try again in a moment.',
        actionLabel: 'Try again',
        onAction: onRetry,
      );

  factory StateView.offline({VoidCallback? onRetry}) => StateView(
        icon: Icons.wifi_off_rounded,
        color: AppColors.orange,
        title: 'You’re offline',
        message: 'Check your internet connection. Saved notes and downloaded resources are still available.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Floating(
                child: SizedBox(
                  width: compact ? 110 : 150,
                  height: compact ? 110 : 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)]),
                        ),
                      ),
                      Container(
                        width: compact ? 70 : 92,
                        height: compact ? 70 : 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pal.surface,
                          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 12))],
                        ),
                        child: Icon(icon, size: compact ? 32 : 42, color: color),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: context.tt.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
              if (actionLabel != null) ...[
                const SizedBox(height: 24),
                AppButton(label: actionLabel!, onPressed: onAction, expanded: false, height: 48),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loads one or more [Store] collections, showing a skeleton, then the content,
/// or an error / offline state with retry. Rebuilds when the store changes.
class AsyncView extends StatefulWidget {
  const AsyncView({super.key, required this.keys, required this.builder, this.skeleton});
  final List<String> keys;
  final WidgetBuilder builder;
  final Widget? skeleton;

  @override
  State<AsyncView> createState() => _AsyncViewState();
}

class _AsyncViewState extends State<AsyncView> {
  Future<void>? _future;

  @override
  void initState() {
    super.initState();
    if (!Store.instance.isLoaded(widget.keys)) _future = _start();
  }

  Future<void> _start() => Future.wait(widget.keys.map((k) => Store.instance.ensure(k)));

  void _load() {
    setState(() {
      _future = _start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      return ListenableBuilder(listenable: Store.instance, builder: (c, _) => widget.builder(c));
    }
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snap) {
        Widget child;
        if (snap.connectionState != ConnectionState.done) {
          child = KeyedSubtree(key: const ValueKey('loading'), child: widget.skeleton ?? const SkeletonList());
        } else if (snap.hasError) {
          child = KeyedSubtree(
            key: const ValueKey('error'),
            child: snap.error is OfflineException ? StateView.offline(onRetry: _load) : StateView.error(onRetry: _load),
          );
        } else {
          child = KeyedSubtree(
            key: const ValueKey('done'),
            child: ListenableBuilder(listenable: Store.instance, builder: (c, _) => widget.builder(c)),
          );
        }
        return AnimatedSwitcher(duration: const Duration(milliseconds: 380), child: child);
      },
    );
  }
}
