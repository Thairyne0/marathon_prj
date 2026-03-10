import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Direction of the pixel transition (color).
enum PixelTransitionDirection {
  /// Green → Black (intro / "in")
  greenToBlack,

  /// Black → Green (outro / "out")
  blackToGreen,
}

/// Spatial sweep direction for how pixels propagate across the screen.
enum PixelSweepDirection {
  /// Pixels flip from top rows to bottom rows.
  topToBottom,

  /// Pixels flip from bottom rows to top rows.
  bottomToTop,
}

/// A fullscreen pixel-dissolve transition overlay.
///
/// Usage:
/// ```dart
/// PixelTransition(
///   direction: PixelTransitionDirection.greenToBlack,
///   autoStart: true,
///   startDelay: Duration(milliseconds: 2000),
///   onPhaseComplete: () { /* pixel grid fully resolved */ },
///   onTransitionPercent: (pct) { /* 0.0 → 1.0 progress */ },
/// )
/// ```
class PixelTransition extends StatefulWidget {
  const PixelTransition({
    super.key,
    this.direction = PixelTransitionDirection.greenToBlack,
    this.sweepDirection,
    this.autoStart = true,
    this.startDelay = const Duration(milliseconds: 0),
    this.pixelInterval = const Duration(milliseconds: 6),
    this.batchSize = 4,
    this.cols = 24,
    this.rows = 40,
    this.accentColor = const Color(0xFFC6FF00),
    this.onPhaseComplete,
    this.onTransitionPercent,
  });

  /// Whether the transition is green→black or black→green.
  final PixelTransitionDirection direction;

  /// Spatial sweep direction. If null, defaults to:
  ///  - topToBottom for greenToBlack
  ///  - bottomToTop for blackToGreen
  final PixelSweepDirection? sweepDirection;

  /// Whether to start automatically on mount.
  final bool autoStart;

  /// Delay before the pixel animation begins.
  final Duration startDelay;

  /// Interval between each batch of pixel flips.
  final Duration pixelInterval;

  /// Number of cells flipped per tick.
  final int batchSize;

  /// Grid columns.
  final int cols;

  /// Grid rows.
  final int rows;

  /// The neon accent color (default: #C6FF00).
  final Color accentColor;

  /// Called when all pixels have been resolved.
  final VoidCallback? onPhaseComplete;

  /// Called on each tick with the current progress (0.0 → 1.0).
  final ValueChanged<double>? onTransitionPercent;

  @override
  State<PixelTransition> createState() => PixelTransitionState();
}

class PixelTransitionState extends State<PixelTransition> {
  late int _totalCells;
  late List<bool> _pixelState;
  late List<int> _shuffledIndices;
  int _currentPixelIndex = 0;
  Timer? _pixelTimer;
  bool _started = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _totalCells = widget.cols * widget.rows;
    _pixelState = List.filled(_totalCells, false);
    _shuffledIndices = List.generate(_totalCells, (i) => i);
    _buildShuffledIndices();

    if (widget.autoStart) {
      if (widget.startDelay == Duration.zero) {
        // Use post-frame callback to start after first build
        WidgetsBinding.instance.addPostFrameCallback((_) => start());
      } else {
        Future.delayed(widget.startDelay, () {
          if (mounted) start();
        });
      }
    }
  }

  void _buildShuffledIndices() {
    final random = Random(42);
    // Resolve effective sweep: explicit or default based on color direction
    final sweep = widget.sweepDirection ??
        (widget.direction == PixelTransitionDirection.greenToBlack
            ? PixelSweepDirection.topToBottom
            : PixelSweepDirection.bottomToTop);

    final isTopDown = sweep == PixelSweepDirection.topToBottom;

    _shuffledIndices.sort((a, b) {
      final rowA = a ~/ widget.cols;
      final rowB = b ~/ widget.cols;
      if (isTopDown) {
        return (rowA + random.nextInt(8)) - (rowB + random.nextInt(8));
      } else {
        return (rowB + random.nextInt(8)) - (rowA + random.nextInt(8));
      }
    });
  }

  /// Programmatically start the pixel transition.
  void start() {
    if (_started || !mounted) return;
    setState(() => _started = true);

    _pixelTimer = Timer.periodic(widget.pixelInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int i = 0; i < widget.batchSize; i++) {
          if (_currentPixelIndex < _totalCells) {
            _pixelState[_shuffledIndices[_currentPixelIndex]] = true;
            _currentPixelIndex++;
          }
        }
      });

      final progress = _currentPixelIndex / _totalCells;
      widget.onTransitionPercent?.call(progress);

      if (_currentPixelIndex >= _totalCells) {
        timer.cancel();
        if (!_completed) {
          _completed = true;
          widget.onPhaseComplete?.call();
        }
      }
    });
  }

  /// Reset the transition to its initial state.
  void reset() {
    _pixelTimer?.cancel();
    setState(() {
      _pixelState = List.filled(_totalCells, false);
      _currentPixelIndex = 0;
      _started = false;
      _completed = false;
    });
    _buildShuffledIndices();
  }

  /// Current progress from 0.0 to 1.0.
  double get progress => _currentPixelIndex / _totalCells;

  /// Whether the transition has completed.
  bool get isCompleted => _completed;

  /// Whether the transition has started.
  bool get isStarted => _started;

  @override
  void dispose() {
    _pixelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellW = constraints.maxWidth / widget.cols;
          final cellH = constraints.maxHeight / widget.rows;

          return CustomPaint(
            painter: _PixelGridPainter(
              cols: widget.cols,
              rows: widget.rows,
              cellWidth: cellW,
              cellHeight: cellH,
              pixelState: _pixelState,
              started: _started,
              direction: widget.direction,
              accentColor: widget.accentColor,
            ),
          );
        },
      ),
    );
  }
}

class _PixelGridPainter extends CustomPainter {
  final int cols;
  final int rows;
  final double cellWidth;
  final double cellHeight;
  final List<bool> pixelState;
  final bool started;
  final PixelTransitionDirection direction;
  final Color accentColor;

  _PixelGridPainter({
    required this.cols,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
    required this.pixelState,
    required this.started,
    required this.direction,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isGreenToBlack =
        direction == PixelTransitionDirection.greenToBlack;

    if (!started) {
      // Initial state: solid base color
      final baseColor = isGreenToBlack ? accentColor : Colors.black;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = baseColor,
      );
      return;
    }

    if (isGreenToBlack) {
      // Green→Black used as dissolving overlay:
      // Draw only the cells that have NOT been flipped yet (still green).
      // Flipped cells are left transparent → content underneath shows through.
      final greenPaint = Paint()..color = accentColor;
      for (int i = 0; i < pixelState.length; i++) {
        if (!pixelState[i]) {
          final col = i % cols;
          final row = i ~/ cols;
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellWidth,
              row * cellHeight,
              cellWidth + 0.5,
              cellHeight + 0.5,
            ),
            greenPaint,
          );
        }
      }
    } else {
      // Black→Green: pixels appear as green overlay on top of content.
      // Draw base black, then paint flipped cells as green.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black,
      );

      final overlayPaint = Paint()..color = accentColor;
      for (int i = 0; i < pixelState.length; i++) {
        if (pixelState[i]) {
          final col = i % cols;
          final row = i ~/ cols;
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellWidth,
              row * cellHeight,
              cellWidth + 0.5,
              cellHeight + 0.5,
            ),
            overlayPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelGridPainter oldDelegate) => true;
}

