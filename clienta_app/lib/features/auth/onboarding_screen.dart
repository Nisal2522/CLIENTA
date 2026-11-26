import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/widgets/widgets.dart';
import 'welcome_screen.dart';

class _Slide {
  const _Slide(this.image, this.tag, this.title, this.body, this.color);
  final String image;
  final String tag;
  final String title;
  final String body;
  final Color color;
}

const _slides = [
  _Slide(
    'assets/images/onboarding_events.jpg',
    'EVENTS',
    'Every event,\nbeautifully organised',
    'Agenda, speakers, venue maps, resources and live updates — everything you need for PCU events in one place.',
    AppColors.blue,
  ),
  _Slide(
    'assets/images/onboarding_connect.jpg',
    'NETWORKING',
    'Connect and\ncollaborate',
    'Chat with participants, schedule 1:1 meetings and join event groups to make every conversation count.',
    AppColors.blueDeep,
  ),
  _Slide(
    'assets/images/onboarding_sustain.jpg',
    'INSIGHTS',
    'Stay informed,\nget recognised',
    'Global and country news, a Knowledge Hub of standards and guides, and digital certificates you can share.',
    AppColors.darkBlue80,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  double _pos = 0;

  @override
  void initState() {
    super.initState();
    _page.addListener(() => setState(() => _pos = _page.page ?? 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final s in _slides) {
      precacheImage(AssetImage(s.image), context);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _finish() {
    AppState.instance.onboardingSeen = true;
    replaceAll(context, const WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final index = _pos.round();
    final last = index == _slides.length - 1;
    final pal = context.pal;
    final color = Color.lerp(
      _slides[_pos.floor().clamp(0, _slides.length - 1)].color,
      _slides[_pos.ceil().clamp(0, _slides.length - 1)].color,
      _pos - _pos.floor(),
    )!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 4),
              child: Row(
                children: [
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: TextButton(
                      onPressed: last ? null : _finish,
                      child: Text('Skip', style: TextStyle(color: pal.textMuted, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  final delta = i - _pos;
                  final fade = (1 - delta.abs() * 1.3).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Transform.scale(
                            scale: 1 - 0.06 * delta.abs().clamp(0.0, 1.0),
                            child: _PhotoCard(slide: s, parallax: delta),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Transform.translate(
                          offset: Offset(delta * 80, 0),
                          child: Opacity(
                            opacity: fade,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.tag, style: TextStyle(color: s.color, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2)),
                                  const SizedBox(height: 8),
                                  Text(s.title, style: const TextStyle(color: AppColors.navy900, fontSize: 30, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.8)),
                                  const SizedBox(height: 12),
                                  Text(s.body, style: TextStyle(color: pal.textMuted, fontSize: 15, height: 1.55)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 18),
              child: Row(
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = (1 - (i - _pos).abs()).clamp(0.0, 1.0);
                      return Container(
                        margin: const EdgeInsets.only(right: 7),
                        width: 8 + 22 * active,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(pal.border, color, active),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: last ? 170 : 64,
                    child: Pressable(
                      onTap: () => last
                          ? _finish()
                          : _page.nextPage(duration: const Duration(milliseconds: 560), curve: Curves.easeOutCubic),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 10))],
                        ),
                        child: ClipRect(
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: last
                                  ? const Text('Get started', key: ValueKey('g'), maxLines: 1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5))
                                  : const Icon(Icons.arrow_forward_rounded, key: ValueKey('a'), color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded photo with parallax.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.slide, required this.parallax});
  final _Slide slide;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [BoxShadow(color: AppColors.navy900.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 16), spreadRadius: -6)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              slide.image,
              fit: BoxFit.cover,
              alignment: Alignment((parallax * 1.6).clamp(-1.0, 1.0), 0),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x00000000), Color(0x400D1424)],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
