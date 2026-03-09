import 'package:flutter/material.dart';

/// A dotted pixel-style horizontal separator line.
///
/// ```dart
/// const PixelSeparator()
/// ```
class PixelSeparator extends StatelessWidget {
  const PixelSeparator({
    super.key,
    this.dotSize = 2,
    this.gap = 2,
    this.color,
    this.skipEvery = 3,
    this.height = 2,
  });

  /// Size of each dot (width & height).
  final double dotSize;

  /// Gap between dots.
  final double gap;

  /// Dot color. Defaults to accent green at 0.3 alpha.
  final Color? color;

  /// Show a dot every N-th position, others are transparent.
  final int skipEvery;

  /// Overall widget height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final dotColor =
        color ?? const Color(0xFFC6FF00).withValues(alpha: 0.3);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / (dotSize + gap)).floor();
          return Row(
            children: List.generate(count, (i) {
              return Container(
                width: dotSize,
                height: dotSize,
                margin: EdgeInsets.only(right: gap),
                color: i % skipEvery == 0 ? dotColor : Colors.transparent,
              );
            }),
          );
        },
      ),
    );
  }
}

