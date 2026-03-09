import 'package:flutter/material.dart';

/// Hero section for the BugBoard26 issue tracker.
///
/// LEFT: overview stats, welcome message, quick-action button.
/// RIGHT: live ticket feed / recent issues preview.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key, this.scrollOffset = 0.0});

  final double scrollOffset;

  static const _neon = Color(0xFFC6FF00);
  static const _cyan = Color(0xFF00D9FF);
  static const _violet = Color(0xFF470BF6);
  static const _darkBlue = Color(0xFF0B1E3A);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 800;

    if (compact) {
      return _buildCompact();
    }

    return SizedBox(
      height: 480,
      child: Row(
        children: [
          Expanded(flex: 40, child: _buildLeftPanel()),
          Expanded(flex: 60, child: _buildRightPanel()),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeftPanel(),
        SizedBox(height: 400, child: _buildRightPanel()),
      ],
    );
  }

  // ── Left info panel ─────────────────────────────────────────────────
  Widget _buildLeftPanel() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Neon accent bar
          Container(width: 32, height: 3, color: _neon),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            'ISSUE TRACKER — OVERVIEW',
            style: TextStyle(
              color: _cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 28),

          // Title
          const Text(
            'YOUR\nTICKETS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Visualizza, gestisci e traccia tutti i bug\n'
            'e le issue dei tuoi progetti.\n'
            'Filtra per priorità, stato e assegnatario.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 36),

          // CTA button
          _HeroCta(label: 'VEDI TUTTI I TICKET'),
        ],
      ),
    );
  }

  // ── Right panel: recent tickets feed ────────────────────────────────
  Widget _buildRightPanel() {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Transform.translate(
            offset: Offset(0, scrollOffset * 0.08),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_darkBlue, Color(0xFF060D18), Colors.black],
                ),
              ),
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),

          // Left gradient fade
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          // Ticket list overlay
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildTicketFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketFeed() {
    final tickets = [
      _TicketData('BUG-1042', 'Memory leak nel modulo di autenticazione', 'CRITICO', _neon),
      _TicketData('BUG-1041', 'Offset UI nelle card della dashboard', 'MEDIO', _violet),
      _TicketData('FEAT-089', 'Aggiungere filtro per data di creazione', 'BASSO', Colors.white.withValues(alpha: 0.3)),
      _TicketData('BUG-1040', 'API timeout su carico pesante', 'CRITICO', _neon),
      _TicketData('BUG-1039', 'Glitch nel rendering dei font', 'MEDIO', _violet),
      _TicketData('FEAT-088', 'Notifiche push per ticket assegnati', 'BASSO', Colors.white.withValues(alpha: 0.3)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: _cyan.withValues(alpha: 0.3)),
              ),
              child: Text(
                'TICKET RECENTI • LIVE',
                style: TextStyle(
                  color: _cyan.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${tickets.length} ITEMS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ticket rows
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.04),
            ),
            itemBuilder: (context, i) => _buildTicketRow(tickets[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketRow(_TicketData t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: t.color,
              boxShadow: [BoxShadow(color: t.color.withValues(alpha: 0.5), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 12),

          // ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              t.id,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Description
          Expanded(
            child: Text(
              t.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Priority
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: t.color.withValues(alpha: 0.1),
              border: Border.all(color: t.color.withValues(alpha: 0.2)),
            ),
            child: Text(
              t.priority,
              style: TextStyle(
                color: t.color,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ticket data model ────────────────────────────────────────────────

class _TicketData {
  final String id;
  final String description;
  final String priority;
  final Color color;
  _TicketData(this.id, this.description, this.priority, this.color);
}

// ─── Hero CTA button ──────────────────────────────────────────────────

class _HeroCta extends StatefulWidget {
  const _HeroCta({required this.label});
  final String label;

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: _hovered ? _neon : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: _neon.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 1)]
              : [],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _hovered ? _neon : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

// ─── Grid painter ─────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF00D9FF).withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const sp = 50.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Decorative circle
    paint
      ..color = const Color(0xFF470BF6).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.45),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


