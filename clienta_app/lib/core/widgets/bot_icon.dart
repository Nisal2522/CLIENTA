import 'package:flutter/material.dart';

import '../theme.dart';

/// Support bot: a friendly robot head wearing a headset with a mic.
/// Drawn on a 24×24 grid so it sits like a Material icon at any [size].
class BotIcon extends StatelessWidget {
  const BotIcon({super.key, this.size = 24, this.color = Colors.white, this.faceColor = AppColors.blueDeep});

  /// Head and headset colour.
  final Color color;

  /// Eyes and mouth colour (drawn on top of the head).
  final Color faceColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BotPainter(color: color, faceColor: faceColor)),
    );
  }
}

class _BotPainter extends CustomPainter {
  _BotPainter({required this.color, required this.faceColor});
  final Color color;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;
    canvas.scale(u);

    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Antenna.
    canvas.drawLine(const Offset(12, 7), const Offset(12, 5.4), stroke..strokeWidth = 1.3);
    canvas.drawCircle(const Offset(12, 4.6), 1.1, fill);

    // Headband over the top of the head.
    canvas.drawArc(Rect.fromCircle(center: const Offset(12, 11), radius: 8.2), 3.14159, 3.14159, false, stroke..strokeWidth = 1.6);

    // Ear cups.
    canvas.drawRRect(RRect.fromLTRBR(2.4, 10, 5.2, 15.5, const Radius.circular(1.4)), fill);
    canvas.drawRRect(RRect.fromLTRBR(18.8, 10, 21.6, 15.5, const Radius.circular(1.4)), fill);

    // Mic boom from the right cup to the mouth.
    final boom = Path()
      ..moveTo(20.2, 15.5)
      ..quadraticBezierTo(20.2, 20.3, 15.8, 20.3);
    canvas.drawPath(boom, stroke..strokeWidth = 1.3);
    canvas.drawCircle(const Offset(15, 20.3), 1.2, fill);

    // Head.
    canvas.drawRRect(RRect.fromLTRBR(5.8, 7, 18.2, 18.4, const Radius.circular(4)), fill);

    // Face.
    final face = Paint()..color = faceColor;
    canvas.drawOval(Rect.fromCenter(center: const Offset(9.6, 12), width: 2.4, height: 2.9), face);
    canvas.drawOval(Rect.fromCenter(center: const Offset(14.4, 12), width: 2.4, height: 2.9), face);
    final smile = Path()
      ..moveTo(10.2, 15.2)
      ..quadraticBezierTo(12, 16.6, 13.8, 15.2);
    canvas.drawPath(
      smile,
      Paint()
        ..color = faceColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BotPainter old) => old.color != color || old.faceColor != faceColor;
}
