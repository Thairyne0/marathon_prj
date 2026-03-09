import 'package:flutter/material.dart';

/// A small corner bracket decoration for HUD-style overlays.
///
/// Place four of these in the corners of a Stack, flipping as needed:
/// ```dart
/// Positioned(top: 20, left: 20, child: HudCorner()),
/// Positioned(top: 20, right: 20, child: HudCorner(flipX: true)),
/// Positioned(bottom: 20, left: 20, child: HudCorner(flipY: true)),
/// Positioned(bottom: 20, right: 20, child: HudCorner(flipX: true, flipY: true)),
/// ```
class HudCorner extends StatelessWidget {
  const HudCorner({
    super.key,
    this.size = 30,
    this.color,
    this.strokeWidth = 1.0,
    this.flipX = false,
    this.flipY = false,
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? const Color(0xFFC6FF00).withValues(alpha: 0.3);

    Widget corner = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HudCornerPainter(
          color: effectiveColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );

    if (flipX || flipY) {
      corner = Transform.flip(flipX: flipX, flipY: flipY, child: corner);
    }

    return corner;
  }
}

class _HudCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HudCornerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.4, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HudCornerPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

