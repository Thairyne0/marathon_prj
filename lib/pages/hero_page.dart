import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// The main shell page with header, left sidebar menu, right brand bar,
/// and a central hero content area. Full cyberpunk / HUD aesthetic.
class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage>
    with TickerProviderStateMixin {
  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);
  static const _dark = Color(0xFF111111);

  int _selectedMenuIndex = 0;
  bool _pixelDone = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content underneath
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                // Left sidebar
                _buildSidebar(),

                // Main area (header + content)
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),

                // Right brand bar
                _buildBrandBar(),
              ],
            ),
          ),

          // Pixel transition overlay: green → black, sweeping bottom→top
          // (the green "exits" upward from bottom, revealing the page)
          if (!_pixelDone)
            IgnorePointer(
              child: PixelTransition(
                direction: PixelTransitionDirection.greenToBlack,
                sweepDirection: PixelSweepDirection.bottomToTop,
                autoStart: true,
                startDelay: const Duration(milliseconds: 200),
                pixelInterval: const Duration(milliseconds: 5),
                batchSize: 6,
                onPhaseComplete: () {
                  if (mounted) setState(() => _pixelDone = true);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── LEFT SIDEBAR ────────────────────────────────────────────────────
  Widget _buildSidebar() {
    final items = <_SidebarItem>[
      _SidebarItem(Icons.dashboard_outlined, 'DASHBOARD'),
      _SidebarItem(Icons.bug_report_outlined, 'BUGS'),
      _SidebarItem(Icons.code, 'PROJECTS'),
      _SidebarItem(Icons.people_outline, 'TEAM'),
      _SidebarItem(Icons.analytics_outlined, 'ANALYTICS'),
      _SidebarItem(Icons.settings_outlined, 'SETTINGS'),
    ];

    return Container(
      width: 64,
      color: _dark,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _neon.withValues(alpha: 0.4), width: 1),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: _neon,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Separator
          Container(
            width: 24,
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 16),

          // Menu items
          ...List.generate(items.length, (i) {
            final selected = i == _selectedMenuIndex;
            return _buildSidebarIcon(
              icon: items[i].icon,
              label: items[i].label,
              selected: selected,
              onTap: () => setState(() => _selectedMenuIndex = i),
            );
          }),

          const Spacer(),

          // Bottom violet decorative icon
          CyberIconBox(
            icon: Icons.add,
            size: 28,
            color: _violet,
            borderWidth: 1,
            glowOnHover: false,
          ),
          const SizedBox(height: 12),
          CyberIconBox(
            icon: Icons.fiber_manual_record,
            size: 28,
            iconSize: 6,
            color: _violet,
            borderWidth: 1,
            glowOnHover: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      decoration: BoxDecoration(
        color: _dark,
        border: Border.all(color: _neon.withValues(alpha: 0.2)),
      ),
      textStyle: const TextStyle(
        color: _neon,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? _neon.withValues(alpha: 0.06)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: selected ? _neon : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? _neon
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 52,
      color: _dark,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Left: breadcrumb
          Text(
            'BUGBOARD26',
            style: TextStyle(
              color: _neon,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(width: 12),
          Text(
            'DASHBOARD',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),

          const Spacer(),

          // Center: status indicators
          _buildStatusDot(_neon, 'ONLINE'),
          const SizedBox(width: 16),
          _buildStatusDot(_violet, 'SYNC'),
          const SizedBox(width: 16),

          // Right: HUD labels
          Text(
            '[ SYS-26 ]',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 16),

          // User icon box
          CyberIconBox(
            icon: Icons.person_outline,
            size: 30,
            color: _neon,
            borderWidth: 1,
            glowOnHover: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // ─── RIGHT BRAND BAR ─────────────────────────────────────────────────
  Widget _buildBrandBar() {
    return Container(
      width: 56,
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Top decorative square block
          Container(width: 8, height: 8, color: _neon),
          const SizedBox(height: 6),
          Container(width: 8, height: 8, decoration: BoxDecoration(border: Border.all(color: _neon.withValues(alpha: 0.3), width: 1))),
          const SizedBox(height: 10),
          Container(
            width: 2,
            height: 40,
            color: _neon.withValues(alpha: 0.15),
          ),

          const Spacer(),

          // Vertical site name — large, squared, aggressive
          RotatedBox(
            quarterTurns: 1,
            child: Text(
              'BUGBOARD26',
              style: TextStyle(
                color: _neon,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 14,
                height: 1,
                shadows: [
                  Shadow(
                    color: _neon.withValues(alpha: 0.7),
                    blurRadius: 20,
                  ),
                  Shadow(
                    color: _neon.withValues(alpha: 0.35),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom decorative squared elements
          Container(
            width: 2,
            height: 40,
            color: _violet.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          Container(width: 8, height: 8, decoration: BoxDecoration(border: Border.all(color: _violet.withValues(alpha: 0.4), width: 1))),
          const SizedBox(height: 6),
          Container(width: 8, height: 8, color: _violet.withValues(alpha: 0.5)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── MAIN CONTENT ────────────────────────────────────────────────────
  Widget _buildContent() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Grid pattern background
          Positioned.fill(child: _buildGridOverlay()),

          // Main content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero title section
                _buildHeroTitle(),
                const SizedBox(height: 28),

                // Stats cards row
                Expanded(
                  child: _buildDashboardGrid(),
                ),
              ],
            ),
          ),

          // HUD corners
          const Positioned(top: 12, left: 12, child: HudCorner()),
          const Positioned(top: 12, right: 12, child: HudCorner(flipX: true)),
          const Positioned(bottom: 12, left: 12, child: HudCorner(flipY: true)),
          const Positioned(bottom: 12, right: 12, child: HudCorner(flipX: true, flipY: true)),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: _GridOverlayPainter(),
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 20, color: _neon),
            const SizedBox(width: 12),
            const Text(
              'WELCOME BACK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'Sistema operativo • Stato: attivo • Sessione autorizzata',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              const PixelSeparator(),
            ].map((w) => Expanded(child: w)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        if (isNarrow) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatCard('BUGS APERTI', '42', Icons.bug_report_outlined, _neon),
                const SizedBox(height: 12),
                _buildStatCard('PROGETTI', '7', Icons.code, _violet),
                const SizedBox(height: 12),
                _buildStatCard('TEAM', '12', Icons.people_outline, _neon),
                const SizedBox(height: 12),
                _buildActivityPanel(),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: stat cards
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  _buildStatCard('BUGS APERTI', '42', Icons.bug_report_outlined, _neon),
                  const SizedBox(height: 12),
                  _buildStatCard('PROGETTI', '7', Icons.code, _violet),
                  const SizedBox(height: 12),
                  _buildStatCard('TEAM', '12', Icons.people_outline, _neon),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Right column: activity
            Expanded(child: _buildActivityPanel()),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accent) {
    return CyberPanel(
      accentColor: accent,
      headerLabel: label,
      headerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      bodyPadding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const Spacer(),
          CyberIconBox(
            icon: icon,
            size: 40,
            color: accent,
            borderWidth: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPanel() {
    final activities = <_ActivityEntry>[
      _ActivityEntry('BUG-1042', 'Memory leak in auth module', 'CRITICO', _neon),
      _ActivityEntry('BUG-1041', 'UI offset on dashboard cards', 'MEDIO', _violet),
      _ActivityEntry('PRJ-007', 'New feature: dark mode toggle', 'BASSO', Colors.white.withValues(alpha: 0.3)),
      _ActivityEntry('BUG-1040', 'API timeout on heavy load', 'CRITICO', _neon),
      _ActivityEntry('BUG-1039', 'Font rendering glitch', 'MEDIO', _violet),
    ];

    return CyberPanel(
      headerLabel: 'ATTIVITÀ RECENTI',
      headerTag: 'LIVE',
      bodyPadding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(activities.length, (i) {
          final a = activities[i];
          return _buildActivityRow(a, isLast: i == activities.length - 1);
        }),
      ),
    );
  }

  Widget _buildActivityRow(_ActivityEntry entry, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: entry.statusColor,
              boxShadow: [
                BoxShadow(
                  color: entry.statusColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ID tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              entry.id,
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
              entry.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Priority tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: entry.statusColor.withValues(alpha: 0.1),
              border: Border.all(
                color: entry.statusColor.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              entry.priority,
              style: TextStyle(
                color: entry.statusColor,
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

// ─── HELPERS ──────────────────────────────────────────────────────────────

class _SidebarItem {
  final IconData icon;
  final String label;
  _SidebarItem(this.icon, this.label);
}

class _ActivityEntry {
  final String id;
  final String description;
  final String priority;
  final Color statusColor;
  _ActivityEntry(this.id, this.description, this.priority, this.statusColor);
}

// ─── GRID OVERLAY PAINTER ─────────────────────────────────────────────────

class _GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}





