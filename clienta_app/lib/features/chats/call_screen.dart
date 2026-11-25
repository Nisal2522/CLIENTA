import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';

/// WhatsApp-style voice call screen (simulated: calling → ringing → connected).
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.title, this.photoUrl, this.isGroup = false});
  final String title;
  final String? photoUrl;
  final bool isGroup;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

enum _Phase { calling, ringing, connected, ended }

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  final _timers = <Timer>[];
  Timer? _clock;
  _Phase _phase = _Phase.calling;
  int _secs = 0;
  bool _muted = false;
  bool _speaker = false;
  bool _video = false;

  @override
  void initState() {
    super.initState();
    _timers
      ..add(Timer(const Duration(milliseconds: 1200), () => setState(() => _phase = _Phase.ringing)))
      ..add(Timer(const Duration(milliseconds: 4200), () {
        HapticFeedback.mediumImpact();
        _pulse.stop();
        setState(() => _phase = _Phase.connected);
        _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _secs++));
      }));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _clock?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _end() {
    if (_phase == _Phase.ended) return;
    for (final t in _timers) {
      t.cancel();
    }
    _clock?.cancel();
    _pulse.stop();
    setState(() => _phase = _Phase.ended);
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.pop(context);
    });
  }

  String get _status => switch (_phase) {
        _Phase.calling => 'Calling…',
        _Phase.ringing => 'Ringing…',
        _Phase.connected => '${(_secs ~/ 60).toString().padLeft(2, '0')}:${(_secs % 60).toString().padLeft(2, '0')}',
        _Phase.ended => 'Call ended',
      };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: _phase == _Phase.ended,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _end();
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navy700, AppColors.navy950],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 13, color: Colors.white54),
                      const SizedBox(width: 5),
                      Text(_video ? 'CLIENTA video call' : 'CLIENTA voice call', style: const TextStyle(color: Colors.white54, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_phase == _Phase.calling || _phase == _Phase.ringing)
                            for (final offset in [0.0, 0.5])
                              Builder(builder: (_) {
                                final v = (_pulse.value + offset) % 1;
                                return Container(
                                  width: 130 + 90 * v,
                                  height: 130 + 90 * v,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.blue.withValues(alpha: 0.28 * (1 - v))),
                                );
                              }),
                          child!,
                        ],
                      ),
                      child: widget.isGroup
                          ? const IconBadge(icon: Icons.groups_rounded, size: 130, circle: true, solid: true, color: AppColors.teal)
                          : AppAvatar(name: widget.title, url: widget.photoUrl, size: 130),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _status,
                      key: ValueKey(_phase),
                      style: TextStyle(
                        color: _phase == _Phase.ended ? AppColors.red : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallToggle(icon: Icons.volume_up_rounded, label: 'Speaker', on: _speaker, onTap: () => setState(() => _speaker = !_speaker)),
                      _CallToggle(icon: _video ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: 'Video', on: _video, onTap: () => setState(() => _video = !_video)),
                      _CallToggle(icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded, label: 'Mute', on: _muted, onTap: () => setState(() => _muted = !_muted)),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Pressable(
                    scale: 0.88,
                    onTap: _end,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red,
                        boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CallToggle extends StatelessWidget {
  const _CallToggle({required this.icon, required this.label, required this.on, required this.onTap});
  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.88,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            decoration: BoxDecoration(shape: BoxShape.circle, color: on ? Colors.white : Colors.white.withValues(alpha: 0.14)),
            child: Icon(icon, color: on ? AppColors.navy900 : Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
