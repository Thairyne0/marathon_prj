import 'package:flutter/material.dart';

/// A ghost/outline button for secondary actions (social login, etc).
///
/// ```dart
/// CyberOutlineButton(
///   label: 'CONTINUA CON GOOGLE',
///   icon: Icons.g_mobiledata,
///   onTap: () {},
/// )
/// ```
class CyberOutlineButton extends StatefulWidget {
  const CyberOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.fontSize = 11,
    this.letterSpacing = 2,
    this.verticalPadding = 14,
    this.iconSize = 18,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final double fontSize;
  final double letterSpacing;
  final double verticalPadding;
  final double iconSize;

  @override
  State<CyberOutlineButton> createState() => _CyberOutlineButtonState();
}

class _CyberOutlineButtonState extends State<CyberOutlineButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? Colors.white.withValues(alpha: 0.1);
    final text = widget.textColor ?? Colors.white.withValues(alpha: 0.6);
    final icon = widget.iconColor ?? Colors.white.withValues(alpha: 0.5);

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
            color: _hovering
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.transparent,
            border: Border.all(
              color: _hovering
                  ? border.withValues(alpha: 0.25)
                  : border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: icon, size: widget.iconSize),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: text,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: widget.letterSpacing,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

