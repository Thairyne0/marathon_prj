import 'package:flutter/material.dart';

/// A sharp-edged square box containing a centered icon.
///
/// Designed for HUD-style decorative elements with an electric
/// violet accent (#470BF6) or any custom color.
///
/// ```dart
/// CyberIconBox(
///   icon: Icons.add,
///   size: 40,
///   color: Color(0xFF470BF6),
/// )
/// ```
class CyberIconBox extends StatefulWidget {
  const CyberIconBox({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize,
    this.color = const Color(0xFF470BF6),
    this.iconColor,
    this.backgroundColor = Colors.transparent,
    this.borderWidth = 1.5,
    this.filled = false,
    this.glowOnHover = true,
    this.glowIntensity = 0.4,
    this.onTap,
  });

  /// The icon to display centered inside the box.
  final IconData icon;

  /// Overall box size (width & height).
  final double size;

  /// Icon size. Defaults to size * 0.5.
  final double? iconSize;

  /// Border / accent color.
  final Color color;

  /// Icon color. Defaults to [color].
  final Color? iconColor;

  /// Background color of the box.
  final Color backgroundColor;

  /// Border width.
  final double borderWidth;

  /// If true, the box is filled with [color] and icon uses black.
  final bool filled;

  /// Whether to show a glow effect on hover.
  final bool glowOnHover;

  /// Glow alpha intensity on hover (0.0 – 1.0).
  final double glowIntensity;

  /// Optional tap callback.
  final VoidCallback? onTap;

  @override
  State<CyberIconBox> createState() => _CyberIconBoxState();
}

class _CyberIconBoxState extends State<CyberIconBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = widget.iconSize ?? widget.size * 0.5;
    final effectiveIconColor = widget.filled
        ? Colors.black
        : (widget.iconColor ?? widget.color);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.filled ? widget.color : widget.backgroundColor,
            border: Border.all(
              color: _hovering
                  ? widget.color
                  : widget.color.withValues(alpha: 0.6),
              width: widget.borderWidth,
            ),
            boxShadow: (_hovering && widget.glowOnHover)
                ? [
                    BoxShadow(
                      color: widget.color
                          .withValues(alpha: widget.glowIntensity),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: effectiveIconSize,
              color: _hovering
                  ? effectiveIconColor
                  : effectiveIconColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

