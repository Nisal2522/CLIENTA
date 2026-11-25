import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../../data/store.dart';
import '../common/permission_screen.dart';
import 'section_scaffold.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const _mapSize = Size(900, 900);
  static const _pin = Offset(470, 400);
  static const _me = Offset(360, 560);
  final _tc = TransformationController();
  bool _centered = false;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Size _viewport = Size.zero;

  void _center(Size viewport, {Offset target = _pin}) {
    _tc.value = Matrix4.translationValues(viewport.width / 2 - target.dx, viewport.height / 2 - target.dy - 60, 0);
  }

  void _zoom(double s) {
    final c = Offset(_viewport.width / 2, _viewport.height / 2);
    _tc.value = Matrix4.translationValues(c.dx, c.dy, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1))
      ..multiply(Matrix4.translationValues(-c.dx, -c.dy, 0))
      ..multiply(_tc.value);
  }

  Future<void> _locateMe() async {
    final app = AppState.instance;
    if (!app.grantedPermissions.contains('location')) {
      await Navigator.of(context).push(AppRoute(PermissionScreen(kind: PermissionKind.location, onDone: (ctx, _) => Navigator.pop(ctx))));
      if (!mounted) return;
      setState(() {});
    }
    if (app.grantedPermissions.contains('location')) toast(context, 'Showing your position', icon: Icons.my_location_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final e = Store.instance.event(widget.eventId);
    final pal = context.pal;
    final showMe = AppState.instance.grantedPermissions.contains('location');
    return SectionScaffold(
      title: 'Location',
      subtitle: e.title,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(builder: (context, c) {
              _viewport = c.biggest;
              if (!_centered) {
                _centered = true;
                _center(c.biggest);
              }
              return ClipRect(
                child: InteractiveViewer(
                  transformationController: _tc,
                  constrained: false,
                  minScale: 0.6,
                  maxScale: 3,
                  boundaryMargin: const EdgeInsets.all(200),
                  child: SizedBox.fromSize(
                    size: _mapSize,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: VenueMapPainter(dark: pal.dark, labels: [
                              ('Bauddhaloka Mawatha', const Offset(0.47, 0.08)),
                              ('Independence Square', const Offset(0.62, 0.36)),
                              ('Beira Lake', const Offset(0.16, 0.24)),
                              ('Viharamahadevi Park', const Offset(0.17, 0.66)),
                              ('Thummulla', const Offset(0.8, 0.76)),
                              ('Havelock Town', const Offset(0.3, 0.9)),
                            ]),
                          ),
                        ),
                        Positioned(left: _pin.dx - 90, top: _pin.dy - 120, child: _VenuePin(name: e.venue.name)),
                        if (showMe)
                          Positioned(
                            left: _me.dx - 22,
                            top: _me.dy - 22,
                            child: const SizedBox(width: 44, height: 44, child: Center(child: PulseDot(color: AppColors.blue, size: 14))),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            right: 16,
            top: 12,
            child: Column(
              children: [
                CircleIconBtn(icon: Icons.my_location_rounded, onTap: _locateMe),
                const SizedBox(height: 10),
                CircleIconBtn(icon: Icons.add_rounded, onTap: () => _zoom(1.25)),
                const SizedBox(height: 10),
                CircleIconBtn(icon: Icons.remove_rounded, onTap: () => _zoom(0.8)),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: FadeSlideIn(
              offset: const Offset(0, 0.3),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const IconBadge(icon: Icons.place_rounded, color: AppColors.red, size: 46, solid: true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.venue.name, style: context.tt.titleMedium),
                              Text('${e.venue.address}, ${e.venue.city} ${e.venue.flag}', style: context.tt.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (e.venue.directions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(e.venue.directions, style: context.tt.bodySmall?.copyWith(color: pal.textMuted, height: 1.45)),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Directions',
                            icon: Icons.directions_rounded,
                            height: 48,
                            onPressed: () => toast(context, 'Opening directions in Maps…', icon: Icons.map_rounded),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          label: 'Copy',
                          icon: Icons.copy_rounded,
                          height: 48,
                          expanded: false,
                          variant: ButtonVariant.secondary,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${e.venue.name}, ${e.venue.address}, ${e.venue.city}'));
                            toast(context, 'Address copied');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenuePin extends StatelessWidget {
  const _VenuePin({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 130,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.navy900,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.blue, size: 16),
                const SizedBox(width: 4),
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Floating(
            distance: 6,
            child: Icon(Icons.location_on_rounded, color: AppColors.red, size: 54, shadows: [Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))]),
          ),
          const PulseDot(color: AppColors.red, size: 8),
        ],
      ),
    );
  }
}
