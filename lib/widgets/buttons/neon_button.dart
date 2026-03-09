import 'package:flutter/material.dart';

/// A neon-accent primary CTA button with glow hover effect.
///
/// ```dart
/// NeonButton(
///   label: 'ACCEDI',
///   onTap: () {},
/// )
/// ```
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.accentColor = const Color(0xFFC6FF00),
    this.textColor = Colors.black,
    this.fontSize = 14,
    this.letterSpacing = 4,
    this.verticalPadding = 16,
    this.glowBlur = 20,
    this.glowSpread = 2,
  });

  final String label;
  final VoidCallback? onTap;
  final Color accentColor;
  final Color textColor;
  final double fontSize;
  final double letterSpacing;
  final double verticalPadding;
  final double glowBlur;
  final double glowSpread;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: widget.verticalPadding),
          decoration: BoxDecoration(
            color: widget.accentColor,
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.4),
                      blurRadius: widget.glowBlur,
                      spreadRadius: widget.glowSpread,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: widget.letterSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

