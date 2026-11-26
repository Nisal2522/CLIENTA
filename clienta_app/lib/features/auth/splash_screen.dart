import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import '../home/home_preload.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  late final AnimationController _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // Start loading Home while the splash plays, so Home is ready at sign-in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) preloadHome(context);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      replaceAll(context, AppState.instance.onboardingSeen ? const WelcomeScreen() : const OnboardingScreen());
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _glow.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_c, _glow]),
        builder: (context, _) {
          final logoIn = _interval(0, 0.45, Curves.easeOutBack);
          final swirl = _interval(0.1, 0.7);
          final word = _interval(0.45, 0.75);
          final tag = _interval(0.65, 0.95);
          return Stack(
            children: [
              // Ambient orbs
              Positioned(
                top: -120 + 40 * _glow.value,
                left: -80,
                child: _orb(320, AppColors.blue.withValues(alpha: 0.14)),
              ),
              Positioned(
                bottom: -140 - 30 * _glow.value,
                right: -100,
                child: _orb(360, AppColors.blueDeep.withValues(alpha: 0.08)),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.5 + 0.5 * logoIn,
                      child: Opacity(
                        opacity: logoIn.clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: 0.18 + 0.17 * _glow.value),
                                blurRadius: 60 + 30 * _glow.value,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClientaLogo(size: 150, progress: swirl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Opacity(
                      opacity: word,
                      child: Text(
                        'CLIENTA',
                        style: TextStyle(
                          color: AppColors.navy900,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 14 - 8 * word,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Opacity(
                  opacity: tag,
                  child: Center(
                    child: Image.asset(
                      'assets/images/control_union_logo.png',
                      width: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
}
