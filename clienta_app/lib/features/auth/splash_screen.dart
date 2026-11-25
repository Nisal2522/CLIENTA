import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
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
                child: _orb(360, AppColors.purple.withValues(alpha: 0.08)),
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
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: tag,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - tag)),
                        child: Text(
                          'A Smarter Way to Collaborate with Clients',
                          style: const TextStyle(color: Color(0xFF5B6B7F), fontSize: 14, letterSpacing: 0.3),
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
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _c.value,
                            minHeight: 3,
                            backgroundColor: const Color(0xFFE6EBF1),
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('PETERSON & CONTROL UNION', style: const TextStyle(color: Color(0xFF94A3B5), fontSize: 11, letterSpacing: 2.4, fontWeight: FontWeight.w700)),
                    ],
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
