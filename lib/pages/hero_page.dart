import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// BugBoard26 issue tracker dashboard page.
/// Shell layout with sidebar, header, brand bar.
/// Central content: scrollable landing with ticket overview,
/// stats, recent issues feed, and workflow statement.
class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage>
    with TickerProviderStateMixin {
  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);
  static const _cyan = Color(0xFF00D9FF);
  static const _dark = Color(0xFF111111);

  int _selectedMenuIndex = 0;
  bool _pixelDone = false;
  double _scrollOffset = 0.0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;

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

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                // Left sidebar
                _buildSidebar(),

                // Main area
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildLandingContent()),
                    ],
                  ),
                ),

                // Right brand bar
                _buildBrandBar(),
              ],
            ),
          ),

          // Pixel transition overlay
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

  // ─── LANDING CONTENT ─────────────────────────────────────────────────
  Widget _buildLandingContent() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Grid overlay
          Positioned.fill(child: _buildGridOverlay()),

          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top navbar
              SliverToBoxAdapter(child: const TopNavbar()),

              // Neon separator under navbar
              SliverToBoxAdapter(
                child: Container(height: 1, color: _neon.withValues(alpha: 0.08)),
              ),

              // Hero section with parallax
              SliverToBoxAdapter(
                child: HeroSection(scrollOffset: _scrollOffset),
              ),

              // Thin neon accent line
              SliverToBoxAdapter(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  color: _neon.withValues(alpha: 0.12),
                ),
              ),

              // Info panel
              SliverToBoxAdapter(child: const InfoPanel()),

              // Large title section
              SliverToBoxAdapter(child: const LargeTitleSection()),

              // Bottom footer bar
              SliverToBoxAdapter(child: _buildFooterBar()),

              // Footer spacing
              SliverToBoxAdapter(child: const SizedBox(height: 60)),
            ],
          ),

          // HUD corners
          const Positioned(top: 8, left: 8, child: HudCorner(size: 20)),
          const Positioned(top: 8, right: 8, child: HudCorner(size: 20, flipX: true)),
          const Positioned(bottom: 8, left: 8, child: HudCorner(size: 20, flipY: true)),
          const Positioned(bottom: 8, right: 8, child: HudCorner(size: 20, flipX: true, flipY: true)),
        ],
      ),
    );
  }

  // ─── FOOTER BAR ───────────────────────────────────────────────────
  Widget _buildFooterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      color: Colors.black,
      child: Row(
        children: [
          _footerTag('GITHUB'),
          const SizedBox(width: 16),
          _footerTag('SLACK'),
          const SizedBox(width: 16),
          _footerTag('API'),
          const Spacer(),
          Text(
            'v2.6.0 • BUGBOARD26',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
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
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(width: 24, height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 16),
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
              color: selected ? _neon.withValues(alpha: 0.06) : Colors.transparent,
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
                color: selected ? _neon : Colors.white.withValues(alpha: 0.3),
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
          const Text(
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
          _buildStatusDot(_neon, 'ONLINE'),
          const SizedBox(width: 16),
          _buildStatusDot(_cyan, 'SYNC'),
          const SizedBox(width: 16),
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
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
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
          Container(width: 8, height: 8, color: _neon),
          const SizedBox(height: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border: Border.all(color: _neon.withValues(alpha: 0.3), width: 1),
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 2, height: 40, color: _neon.withValues(alpha: 0.15)),
          const Spacer(),
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
              ),
            ),
          ),
          const Spacer(),
          Container(width: 2, height: 40, color: _violet.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border: Border.all(color: _violet.withValues(alpha: 0.4), width: 1),
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 8, height: 8, color: _violet.withValues(alpha: 0.5)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── GRID OVERLAY ────────────────────────────────────────────────────
  Widget _buildGridOverlay() {
    return CustomPaint(painter: _GridOverlayPainter());
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────

class _SidebarItem {
  final IconData icon;
  final String label;
  _SidebarItem(this.icon, this.label);
}


// ─── GRID OVERLAY PAINTER ─────────────────────────────────────────────────

class _GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

