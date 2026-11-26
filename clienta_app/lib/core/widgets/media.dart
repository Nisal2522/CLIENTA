import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum ArtTheme { tech, textile, agri, summit, ocean, news }

/// Generative cover artwork — premium event visuals that work fully offline.
class CoverArt extends StatelessWidget {
  const CoverArt({super.key, required this.seed, this.theme = ArtTheme.tech, this.icon, this.iconSize = 54});
  final String seed;
  final ArtTheme theme;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CoverPainter(seed, theme),
        child: icon == null
            ? const SizedBox.expand()
            : Center(child: Icon(icon, size: iconSize, color: Colors.white.withValues(alpha: 0.28))),
      ),
    );
  }

  static List<Color> colorsFor(ArtTheme t) => switch (t) {
        ArtTheme.tech => const [Color(0xFF07122B), Color(0xFF0F3D73), Color(0xFF39C2FF)],
        ArtTheme.textile => const [Color(0xFF062B2A), Color(0xFF15766A), Color(0xFF9BF0CF)],
        ArtTheme.agri => const [Color(0xFF16300E), Color(0xFF4F8A1D), Color(0xFFF7D154)],
        ArtTheme.summit => const [Color(0xFF140F3A), Color(0xFF4B2FA0), Color(0xFFE5B3FF)],
        ArtTheme.ocean => const [Color(0xFF041E33), Color(0xFF0E5DBF), Color(0xFF6CD3FF)],
        ArtTheme.news => const [AppColors.cuDarkBlue, AppColors.darkBlue80, AppColors.cuLightBlue],
      };
}

class _CoverPainter extends CustomPainter {
  _CoverPainter(this.seed, this.theme);
  final String seed;
  final ArtTheme theme;

  int get _seedInt {
    var h = 7;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(_seedInt);
    final cols = CoverArt.colorsFor(theme);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cols[1], cols[0]],
        ).createShader(rect),
    );
    // Soft glow
    final glowCenter = Offset(size.width * (0.55 + rnd.nextDouble() * 0.4), size.height * (0.1 + rnd.nextDouble() * 0.3));
    canvas.drawCircle(
      glowCenter,
      size.longestSide * 0.6,
      Paint()
        ..shader = RadialGradient(colors: [cols[2].withValues(alpha: 0.42), cols[2].withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: glowCenter, radius: size.longestSide * 0.6)),
    );

    final accent = cols[2];
    switch (theme) {
      case ArtTheme.tech:
      case ArtTheme.news:
        final pts = List.generate(46, (_) => Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height));
        final line = Paint()..strokeWidth = 0.9;
        final maxD = size.shortestSide * 0.42;
        for (var i = 0; i < pts.length; i++) {
          for (var j = i + 1; j < pts.length; j++) {
            final d = (pts[i] - pts[j]).distance;
            if (d < maxD) {
              line.color = accent.withValues(alpha: 0.5 * (1 - d / maxD));
              canvas.drawLine(pts[i], pts[j], line);
            }
          }
        }
        for (final p in pts) {
          final r = 1.2 + rnd.nextDouble() * 2.4;
          canvas.drawCircle(p, r * 3, Paint()..color = accent.withValues(alpha: 0.12));
          canvas.drawCircle(p, r, Paint()..color = Colors.white.withValues(alpha: 0.85));
        }
      case ArtTheme.textile:
        for (var i = 0; i < 18; i++) {
          final path = Path();
          final amp = 10 + rnd.nextDouble() * 26;
          final freq = 1.2 + rnd.nextDouble() * 1.6;
          final phase = rnd.nextDouble() * math.pi * 2;
          final yBase = size.height * (i / 18);
          for (double x = 0; x <= size.width; x += 4) {
            final y = yBase + math.sin(x / size.width * math.pi * 2 * freq + phase) * amp;
            x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
          }
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2 + rnd.nextDouble() * 1.6
              ..color = accent.withValues(alpha: 0.15 + rnd.nextDouble() * 0.35),
          );
        }
      case ArtTheme.agri:
        for (var i = 0; i < 14; i++) {
          canvas.save();
          final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          canvas.translate(c.dx, c.dy);
          canvas.rotate(rnd.nextDouble() * math.pi);
          final w = 30 + rnd.nextDouble() * 90;
          final leaf = Path()
            ..moveTo(-w / 2, 0)
            ..quadraticBezierTo(0, -w * 0.45, w / 2, 0)
            ..quadraticBezierTo(0, w * 0.45, -w / 2, 0);
          canvas.drawPath(leaf, Paint()..color = (i.isEven ? accent : cols[1]).withValues(alpha: 0.18 + rnd.nextDouble() * 0.3));
          canvas.drawLine(Offset(-w / 2, 0), Offset(w / 2, 0), Paint()..color = Colors.white.withValues(alpha: 0.2));
          canvas.restore();
        }
      case ArtTheme.summit:
        final c = Offset(size.width * (0.3 + rnd.nextDouble() * 0.4), size.height * 0.55);
        for (var i = 1; i < 16; i++) {
          canvas.drawCircle(
            c,
            i * size.shortestSide * 0.075,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = accent.withValues(alpha: 0.5 - i * 0.028),
          );
        }
        for (var i = 0; i < 60; i++) {
          canvas.drawCircle(
            Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
            rnd.nextDouble() * 1.8,
            Paint()..color = Colors.white.withValues(alpha: 0.6),
          );
        }
      case ArtTheme.ocean:
        for (var i = 0; i < 6; i++) {
          final path = Path()..moveTo(0, size.height);
          final yBase = size.height * (0.35 + i * 0.11);
          final phase = rnd.nextDouble() * math.pi * 2;
          for (double x = 0; x <= size.width; x += 4) {
            path.lineTo(x, yBase + math.sin(x / size.width * math.pi * 2 + phase) * 14);
          }
          path
            ..lineTo(size.width, size.height)
            ..close();
          canvas.drawPath(path, Paint()..color = accent.withValues(alpha: 0.08 + i * 0.03));
        }
    }

    // Bottom vignette for legibility of overlaid text
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          stops: const [0.45, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_CoverPainter old) => old.seed != seed || old.theme != theme;
}

/// Network image with skeleton-free fade in and an offline-safe generative fallback.
class SmartImage extends StatelessWidget {
  const SmartImage({super.key, required this.url, required this.seed, this.theme = ArtTheme.tech, this.fit = BoxFit.cover});
  final String? url;
  final String seed;
  final ArtTheme theme;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = CoverArt(seed: seed, theme: theme);
    if (url == null) return fallback;
    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        Image.network(
          url!,
          fit: fit,
          frameBuilder: (_, child, frame, sync) => sync
              ? child
              : AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  child: child,
                ),
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Circular avatar with photo, initials fallback and optional online dot.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.url, this.size = 44, this.online = false, this.ring = false});
  final String name;
  final String? url;
  final double size;
  final bool online;
  final bool ring;

  static const _gradients = [
    [AppColors.lightBlue80, AppColors.cuLightBlue],
    [AppColors.darkBlue80, AppColors.cuDarkBlue],
    [AppColors.cuLightGrey, AppColors.cuDarkGrey],
    [AppColors.cuLightBlue, AppColors.darkBlue80],
    [AppColors.darkBlue60, AppColors.darkBlue80],
    [AppColors.lightGrey80, AppColors.cuLightGrey],
  ];

  String get initials {
    final parts = name.replaceAll(RegExp(r'^(Mr|Mrs|Ms|Dr)\.\s*'), '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final g = _gradients[name.length % _gradients.length];
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36)),
      ),
    );
    Widget avatar = ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? fallback
            : Stack(
                fit: StackFit.expand,
                children: [
                  fallback,
                  if (url!.startsWith('assets/'))
                    Image.asset(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
                  else
                    Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                ],
              ),
      ),
    );
    if (ring) {
      avatar = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.brandGradient),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.pal.bg),
          child: avatar,
        ),
      );
    }
    if (!online) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: ring ? 3 : 0,
          bottom: ring ? 3 : 0,
          child: Container(
            width: size * 0.27,
            height: size * 0.27,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              border: Border.all(color: context.pal.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// The official CLIENTA logo mark. [progress] (0–1) drives the entrance:
/// the mark fades in while rotating and scaling into place.
class ClientaLogo extends StatelessWidget {
  const ClientaLogo({super.key, this.size = 120, this.progress = 1});
  final double size;
  final double progress;

  static const asset = 'assets/images/clienta_logo.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, width: size, height: size, fit: BoxFit.contain, filterQuality: FilterQuality.medium);
    if (progress >= 1) return image;
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    return Opacity(
      opacity: t,
      child: Transform.rotate(
        angle: -0.9 * (1 - t),
        child: Transform.scale(scale: 0.75 + 0.25 * t, child: image),
      ),
    );
  }
}

/// Deterministic QR-style matrix for the demo badge (not a scannable code).
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, this.size = 220, this.color = AppColors.navy900});
  final String data;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _QrPainter(data, color));
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data, this.color);
  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 29;
    final cell = size.width / n;
    var h = 17;
    for (final c in data.codeUnits) {
      h = (h * 131 + c) & 0x7fffffff;
    }
    final rnd = math.Random(h);
    final paint = Paint()..color = color;
    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) || (x >= n - 8 && y < 8) || (x < 8 && y >= n - 8);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        if (rnd.nextDouble() < 0.48) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x * cell, y * cell, cell, cell).deflate(0.4), Radius.circular(cell * 0.25)),
            paint,
          );
        }
      }
    }
    void finder(double x, double y) {
      final o = Rect.fromLTWH(x * cell, y * cell, cell * 7, cell * 7);
      canvas.drawRRect(RRect.fromRectAndRadius(o, Radius.circular(cell * 1.6)), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(o.deflate(cell), Radius.circular(cell * 1.1)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(o.deflate(cell * 2), Radius.circular(cell * 0.8)), paint);
    }

    finder(0, 0);
    finder(n - 7.0, 0);
    finder(0, n - 7.0);
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data;
}

/// Stylised city map used for the venue screen (pan & zoom inside InteractiveViewer).
class VenueMapPainter extends CustomPainter {
  VenueMapPainter({required this.dark, required this.labels});
  final bool dark;
  final List<(String, Offset)> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final land = dark ? const Color(0xFF16213A) : const Color(0xFFEEF1F4);
    final block = dark ? const Color(0xFF1C2944) : const Color(0xFFE2E7EC);
    final park = dark ? const Color(0xFF173B33) : const Color(0xFFCDE9D3);
    final water = dark ? const Color(0xFF0E3557) : const Color(0xFFB9DDF5);
    final road = dark ? const Color(0xFF2E3D5C) : Colors.white;
    final major = dark ? const Color(0xFF51618A) : const Color(0xFFF7D58B);

    canvas.drawRect(Offset.zero & size, Paint()..color = land);
    final rnd = math.Random(42);
    // City blocks
    for (double y = 10; y < size.height; y += 46) {
      for (double x = 10; x < size.width; x += 58) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x + rnd.nextDouble() * 4, y + rnd.nextDouble() * 4, 44, 32), const Radius.circular(4)),
          Paint()..color = block,
        );
      }
    }
    // Parks
    for (final r in [
      Rect.fromLTWH(size.width * 0.52, size.height * 0.30, size.width * 0.20, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.62, size.width * 0.18, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.70, size.width * 0.16, size.height * 0.14),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(18)), Paint()..color = park);
    }
    // Lake
    final lake = Path()
      ..moveTo(size.width * 0.05, size.height * 0.18)
      ..cubicTo(size.width * 0.22, size.height * 0.05, size.width * 0.35, size.height * 0.28, size.width * 0.28, size.height * 0.36)
      ..cubicTo(size.width * 0.20, size.height * 0.45, size.width * 0.02, size.height * 0.38, size.width * 0.05, size.height * 0.18);
    canvas.drawPath(lake, Paint()..color = water);
    // Minor roads
    final minor = Paint()
      ..color = road
      ..strokeWidth = 6;
    for (double y = 5; y < size.height; y += 46) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (double x = 5; x < size.width; x += 58) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    // Major roads
    final majorPaint = Paint()
      ..color = major
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.42), majorPaint);
    canvas.drawLine(Offset(size.width * 0.42, 0), Offset(size.width * 0.5, size.height), majorPaint);
    canvas.drawLine(Offset(size.width * 0.1, size.height), Offset(size.width * 0.95, size.height * 0.1), majorPaint..strokeWidth = 9);

    for (final (text, pos) in labels) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: dark ? const Color(0xFFA3B1C6) : const Color(0xFF55657A),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 140);
      tp.paint(canvas, Offset(pos.dx * size.width - tp.width / 2, pos.dy * size.height));
    }
  }

  @override
  bool shouldRepaint(VenueMapPainter old) => old.dark != dark;
}
