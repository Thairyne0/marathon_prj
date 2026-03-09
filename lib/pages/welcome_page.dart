import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/widgets.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  final GlobalKey<PixelTransitionState> _pixelKey = GlobalKey();

  // Animation controllers
  late AnimationController _textColorController;
  late AnimationController _titleSlideController;
  late Animation<Offset> _titleSlideAnimation;

  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    // Text color morph: black → neon green
    _textColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Title slide up
    _titleSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(
      parent: _titleSlideController,
      curve: Curves.easeInOutCubic,
    ));
  }

  /// Called by PixelTransition on every tick with progress 0.0 → 1.0.
  void _onPixelProgress(double progress) {
    // Sync text color to pixel progress
    _textColorController.value = progress;

    // At ~75% start sliding the title up and navigate
    if (progress >= 0.75 && !_navigating) {
      _navigating = true;
      _titleSlideController.forward();

      // Navigate to login after the title has slid up enough
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.go('/login');
        }
      });
    }
  }

  @override
  void dispose() {
    _textColorController.dispose();
    _titleSlideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer 1: Pixel transition overlay
          PixelTransition(
            key: _pixelKey,
            direction: PixelTransitionDirection.greenToBlack,
            autoStart: true,
            startDelay: const Duration(milliseconds: 2000),
            pixelInterval: const Duration(milliseconds: 6),
            batchSize: 4,
            onTransitionPercent: _onPixelProgress,
          ),

          // Layer 2: Centered title
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_titleSlideController, _textColorController]),
      builder: (context, child) {
        final t = _textColorController.value;
        final textColor = Color.lerp(
          Colors.black,
          const Color(0xFFC6FF00),
          t,
        )!;

        final shadows = t > 0.5
            ? [
                Shadow(
                  color: const Color(0xFFC6FF00)
                      .withValues(alpha: (t - 0.5) * 2 * 0.8),
                  blurRadius: 20,
                ),
                Shadow(
                  color: const Color(0xFFC6FF00)
                      .withValues(alpha: (t - 0.5) * 2 * 0.4),
                  blurRadius: 40,
                ),
              ]
            : <Shadow>[];

        return SlideTransition(
          position: _titleSlideAnimation,
          child: Center(
            child: Text(
              'BUGBOARD26',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 12,
                height: 1,
                shadows: shadows,
              ),
            ),
          ),
        );
      },
    );
  }
}

