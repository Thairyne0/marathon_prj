import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  static const _violet = Color(0xFF470BF6);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Pixel transition out state
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    // Start fade-in after a small delay to feel seamless
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;
    final panelWidth = isNarrow ? screenWidth * 0.9 : 420.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Login content
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - _fadeAnimation.value)),
                  child: child,
                ),
              );
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: SizedBox(
                  width: panelWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decorative icon boxes row
                      _buildIconBoxRow(),
                      const SizedBox(height: 20),

                      // Panel with header + body
                      CyberPanel(
                        headerLabel: 'ACCESS TERMINAL',
                        headerTag: 'SEC-26',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              'LOGIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inserisci le tue credenziali per accedere',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 32),

                            const PixelSeparator(),
                            const SizedBox(height: 24),

                            // Email
                            _fieldLabel('EMAIL'),
                            const SizedBox(height: 8),
                            CyberTextField(
                              controller: _emailController,
                              hintText: 'user@bugboard.io',
                              prefixIcon: Icons.alternate_email,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            _fieldLabel('PASSWORD'),
                            const SizedBox(height: 8),
                            CyberTextField(
                              controller: _passwordController,
                              hintText: '••••••••••',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 32),

                            // Login CTA
                            NeonButton(
                              label: 'ACCEDI',
                              onTap: _startTransitionToHero,
                            ),
                            const SizedBox(height: 20),

                            // OR divider
                            _orDivider(),
                            const SizedBox(height: 20),

                            // Social buttons
                            CyberOutlineButton(
                              label: 'CONTINUA CON GOOGLE',
                              icon: Icons.g_mobiledata,
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),
                            CyberOutlineButton(
                              label: 'CONTINUA CON GITHUB',
                              icon: Icons.code,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Violet accent strip
                      _buildVioletStrip(),
                      const SizedBox(height: 16),

                      // Bottom links
                      _buildBottomLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // HUD decorations
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHudOverlay(),
          ),

          // Pixel transition overlay (activated on login)
          if (_transitioning)
            PixelTransition(
              direction: PixelTransitionDirection.blackToGreen,
              sweepDirection: PixelSweepDirection.bottomToTop,
              autoStart: true,
              startDelay: Duration.zero,
              pixelInterval: const Duration(milliseconds: 5),
              batchSize: 6,
              onPhaseComplete: () {
                if (mounted) context.go('/hero');
              },
            ),
        ],
      ),
    );
  }

  void _startTransitionToHero() {
    if (_transitioning) return;
    setState(() => _transitioning = true);
  }

  Widget _buildIconBoxRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CyberIconBox(
          icon: Icons.add,
          size: 36,
          color: _violet,
        ),
        const SizedBox(width: 8),
        CyberIconBox(
          icon: Icons.remove,
          size: 36,
          color: _violet,
        ),
        const SizedBox(width: 8),
        CyberIconBox(
          icon: Icons.grid_view_sharp,
          size: 36,
          color: _violet,
          filled: true,
        ),
        const SizedBox(width: 8),
        CyberIconBox(
          icon: Icons.arrow_forward,
          size: 36,
          color: _violet,
        ),
        const SizedBox(width: 8),
        CyberIconBox(
          icon: Icons.close,
          size: 36,
          color: _violet,
        ),
      ],
    );
  }

  Widget _buildVioletStrip() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          color: _violet,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 1,
            color: _violet.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'SYS-AUTH',
          style: TextStyle(
            color: _violet.withValues(alpha: 0.5),
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 1,
            color: _violet.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 4,
          height: 4,
          color: _violet,
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 3, color: const Color(0xFFC6FF00)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OPPURE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            'PASSWORD DIMENTICATA?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'REGISTRATI',
            style: TextStyle(
              color: Color(0xFFC6FF00),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudOverlay() {
    return Stack(
      children: [
        const Positioned(
          top: 20,
          left: 20,
          child: HudCorner(),
        ),
        const Positioned(
          top: 20,
          right: 20,
          child: HudCorner(flipX: true),
        ),
        const Positioned(
          bottom: 20,
          left: 20,
          child: HudCorner(flipY: true),
        ),
        const Positioned(
          bottom: 20,
          right: 20,
          child: HudCorner(flipX: true, flipY: true),
        ),

        // Violet accent icon boxes - top left cluster
        Positioned(
          top: 60,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CyberIconBox(
                icon: Icons.add,
                size: 24,
                color: _violet,
                borderWidth: 1,
                glowOnHover: false,
              ),
              const SizedBox(height: 4),
              CyberIconBox(
                icon: Icons.fiber_manual_record,
                size: 24,
                iconSize: 6,
                color: _violet,
                borderWidth: 1,
                glowOnHover: false,
              ),
            ],
          ),
        ),

        // Violet accent icon boxes - bottom right cluster
        Positioned(
          bottom: 60,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CyberIconBox(
                icon: Icons.fiber_manual_record,
                size: 24,
                iconSize: 6,
                color: _violet,
                borderWidth: 1,
                glowOnHover: false,
              ),
              const SizedBox(height: 4),
              CyberIconBox(
                icon: Icons.add,
                size: 24,
                color: _violet,
                borderWidth: 1,
                glowOnHover: false,
              ),
            ],
          ),
        ),

        // Violet vertical line - left side
        Positioned(
          top: 120,
          left: 32,
          child: Container(
            width: 1,
            height: 40,
            color: _violet.withValues(alpha: 0.25),
          ),
        ),

        // Violet vertical line - right side
        Positioned(
          bottom: 120,
          right: 32,
          child: Container(
            width: 1,
            height: 40,
            color: _violet.withValues(alpha: 0.25),
          ),
        ),

        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '[ SYSTEM ACTIVE ]',
              style: TextStyle(
                color: const Color(0xFFC6FF00).withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 6,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'v2.6.0 // BUGBOARD INTERFACE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 9,
                fontWeight: FontWeight.w400,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

