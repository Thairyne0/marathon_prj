import 'package:flutter/material.dart';

/// A massive oversized neon title section for the issue tracker.
/// Brutalist, futuristic, cinematic typography — product statement.
class LargeTitleSection extends StatelessWidget {
  const LargeTitleSection({super.key});

  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final fontSize = w < 600 ? 52.0 : (w < 900 ? 80.0 : 110.0);

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: w < 600 ? 20 : 40,
        vertical: 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top separator
          Row(
            children: [
              Container(width: 40, height: 2, color: _neon),
              const SizedBox(width: 12),
              Text(
                'IL TUO WORKFLOW',
                style: TextStyle(
                  color: _neon.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Massive title
          Text(
            'TRACCIA.',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: fontSize * 0.08,
              height: 1.0,
            ),
          ),
          Text(
            'RISOLVI.',
            style: TextStyle(
              color: _neon,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: fontSize * 0.08,
              height: 1.0,
            ),
          ),
          Text(
            'CONSEGNA.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: fontSize * 0.08,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 40),

          // Bottom accent bar
          Row(
            children: [
              Container(width: 6, height: 6, color: _violet),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '© 2026 BUGBOARD26',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
