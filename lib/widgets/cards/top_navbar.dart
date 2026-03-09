import 'package:flutter/material.dart';

/// Top navigation bar for the BugBoard26 issue tracker.
class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 700;

    return Container(
      height: 56,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
      child: Row(
        children: [
          // ── Logo ──
          _logo(),

          if (!compact) ...[
            const SizedBox(width: 40),
            // ── Nav links ──
            ..._navLinks(),
          ],

          const Spacer(),

          if (!compact) ...[
            _statusBadge(),
            const SizedBox(width: 24),
          ],

          // ── CTA ──
          _NavCta(label: 'NEW TICKET'),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _neon, width: 1.5),
      ),
      child: const Center(
        child: Text(
          'B',
          style: TextStyle(
            color: _neon,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  List<Widget> _navLinks() {
    const links = ['ISSUES', 'BOARDS', 'TEAM', 'DOCS'];
    return links
        .map((l) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _NavLink(label: l),
            ))
        .toList();
  }

  Widget _statusBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _neon,
            boxShadow: [
              BoxShadow(color: _neon.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '12 OPEN',
          style: TextStyle(
            color: _neon.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 6,
          height: 6,
          color: _violet,
        ),
        const SizedBox(width: 6),
        Text(
          '3 CRITICAL',
          style: TextStyle(
            color: _violet.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─── Nav link with hover ───────────────────────────────────────────────

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label});
  final String label;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          color: _hovered ? Colors.white : Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
        child: Text(widget.label),
      ),
    );
  }
}

// ─── CTA button ────────────────────────────────────────────────────────

class _NavCta extends StatefulWidget {
  const _NavCta({required this.label});
  final String label;

  @override
  State<_NavCta> createState() => _NavCtaState();
}

class _NavCtaState extends State<_NavCta> {
  static const _neon = Color(0xFFC6FF00);
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _neon,
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _neon.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
