import 'package:flutter/material.dart';

/// Info panel with ticket statistics and project summary blocks.
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);
  static const _cyan = Color(0xFF00D9FF);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final compact = w < 700;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 40,
        vertical: 40,
      ),
      child: compact ? _buildCompact() : _buildWide(),
    );
  }

  Widget _buildWide() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 20, child: _statBlock('42', 'TICKET APERTI', _neon)),
          const SizedBox(width: 2),
          Expanded(flex: 20, child: _statBlock('7', 'PROGETTI', _violet)),
          const SizedBox(width: 2),
          Expanded(flex: 20, child: _statBlock('12', 'MEMBRI', _cyan)),
          const SizedBox(width: 2),
          Expanded(flex: 40, child: _descBlock()),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statBlock('42', 'TICKET APERTI', _neon)),
            const SizedBox(width: 2),
            Expanded(child: _statBlock('7', 'PROGETTI', _violet)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(child: _statBlock('12', 'MEMBRI', _cyan)),
            const SizedBox(width: 2),
            Expanded(child: _buildMiniDesc()),
          ],
        ),
        const SizedBox(height: 2),
        _descBlock(),
      ],
    );
  }

  Widget _statBlock(String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: accent, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDesc() {
    return Container(
      padding: const EdgeInsets.all(28),
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '89%',
            style: TextStyle(
              color: _neon,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'RISOLTI',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _descBlock() {
    return Container(
      padding: const EdgeInsets.all(28),
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(width: 20, height: 2, color: _cyan),
              const SizedBox(width: 10),
              Text(
                'RIEPILOGO PROGETTO',
                style: TextStyle(
                  color: _cyan.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'BugBoard26 è il tuo centro di comando per la '
            'gestione di bug e feature request. Organizza i '
            'ticket per priorità, assegna ai membri del team, '
            'traccia lo stato di avanzamento e mantieni ogni '
            'progetto sotto controllo.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

