import 'package:flutter/material.dart';

/// A terminal-style panel card with a colored header bar and dark body.
///
/// ```dart
/// CyberPanel(
///   headerLabel: 'ACCESS TERMINAL',
///   headerTag: 'SEC-26',
///   child: Column(children: [...]),
/// )
/// ```
class CyberPanel extends StatelessWidget {
  const CyberPanel({
    super.key,
    required this.child,
    this.headerLabel,
    this.headerTag,
    this.accentColor = const Color(0xFFC6FF00),
    this.backgroundColor = const Color(0xFF111111),
    this.borderColor,
    this.bodyPadding = const EdgeInsets.all(32),
    this.headerPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final Widget child;
  final String? headerLabel;
  final String? headerTag;
  final Color accentColor;
  final Color backgroundColor;
  final Color? borderColor;
  final EdgeInsets bodyPadding;
  final EdgeInsets headerPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        borderColor ?? accentColor.withValues(alpha: 0.15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header bar
        if (headerLabel != null) ...[
          Container(
            width: double.infinity,
            padding: headerPadding,
            decoration: BoxDecoration(
              color: accentColor,
              border: Border.all(color: accentColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  headerLabel!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const Spacer(),
                if (headerTag != null)
                  Text(
                    headerTag!,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
        ],

        // Body
        Container(
          width: double.infinity,
          padding: bodyPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: effectiveBorder, width: 1),
          ),
          child: child,
        ),
      ],
    );
  }
}

