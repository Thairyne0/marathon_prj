import 'package:flutter/material.dart';

/// A cyberpunk-styled text field with dark background, border, prefix icon
/// and optional password visibility toggle.
///
/// ```dart
/// CyberTextField(
///   controller: _ctrl,
///   hintText: 'user@bugboard.io',
///   prefixIcon: Icons.alternate_email,
/// )
/// ```
class CyberTextField extends StatefulWidget {
  const CyberTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.prefixIcon,
    this.isPassword = false,
    this.accentColor = const Color(0xFFC6FF00),
    this.backgroundColor = Colors.black,
    this.borderColor,
    this.textStyle,
    this.hintStyle,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final Color accentColor;
  final Color backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsets contentPadding;

  @override
  State<CyberTextField> createState() => _CyberTextFieldState();
}

class _CyberTextFieldState extends State<CyberTextField> {
  bool _obscured = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: _focused
              ? widget.accentColor.withValues(alpha: 0.4)
              : effectiveBorder,
          width: 1,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscured : false,
          style: widget.textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 1,
              ),
          cursorColor: widget.accentColor,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.accentColor.withValues(alpha: 0.5),
                    size: 18,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 18,
                    ),
                  )
                : null,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
            border: InputBorder.none,
            contentPadding: widget.contentPadding,
          ),
        ),
      ),
    );
  }
}

