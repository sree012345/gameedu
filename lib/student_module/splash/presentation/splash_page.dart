import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/student_module/auth/presentation/common/auth_scaffold.dart'
    show AuthLogo;

import '../services/startup_service.dart';

/// Opens Login, Create Profile, or the Dashboard after the splash animation.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const Duration _minDuration = Duration(milliseconds: 2400);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _minDuration,
  );

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  bool _startupFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    _progress.forward(from: 0);
    _float.repeat(reverse: true);

    final elapsed = Stopwatch()..start();

    try {
      debugPrint('[Splash] Resolving next route');
      final route = await StartupService().resolveNextRoute();

      final remaining = _minDuration - elapsed.elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }

      if (!mounted) return;

      debugPrint('[Splash] Opening $route');
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil<void>(route, (_) => false);
    } catch (error, stackTrace) {
      debugPrint('[Splash] Startup failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _progress.stop();
      _float.stop();
      setState(() => _startupFailed = true);
    }
  }

  void _retry() {
    if (!_startupFailed) return;

    setState(() => _startupFailed = false);
    unawaited(_start());
  }

  @override
  void dispose() {
    _progress.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPalette.headerGradientStart,
              AppPalette.headerGradientMid,
              AppPalette.pageGradientStart,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(child: _Circle(size: width * 0.95, alpha: 0.06)),
              Center(child: _Circle(size: width * 0.68, alpha: 0.08)),
              AnimatedBuilder(
                animation: _float,
                builder: (context, _) {
                  final t = math.sin(_float.value * math.pi) * 10;
                  return Stack(
                    children: [
                      Align(
                        alignment: const Alignment(-0.75, -0.62),
                        child: Transform.translate(
                          offset: Offset(0, t),
                          child: const _Tile(Icons.sports_esports_rounded, -0.12),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.75, -0.45),
                        child: Transform.translate(
                          offset: Offset(0, -t),
                          child: const _Tile(Icons.emoji_events_outlined, 0.14),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.7, 0.5),
                        child: Transform.translate(
                          offset: Offset(0, -t),
                          child: const _Tile(Icons.code_rounded, -0.1),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.72, 0.6),
                        child: Transform.translate(
                          offset: Offset(0, t),
                          child: const _Tile(Icons.school_outlined, 0.12),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Align(alignment: Alignment(0.7, -0.8), child: _Dot(10)),
              const Align(alignment: Alignment(-0.6, 0.1), child: _Dot(9)),
              const Align(alignment: Alignment(0.82, 0.18), child: _Dot(12)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthLogo(height: 170),
                    const SizedBox(height: 22),
                    const Text(
                      'Learn. Play. Create.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Game development learning with your college',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppPalette.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) => Container(
                          width: 240,
                          height: 5,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppPalette.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: _progress.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppPalette.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_startupFailed)
                        TextButton(
                          onPressed: _retry,
                          style: TextButton.styleFrom(
                            foregroundColor: AppPalette.white,
                          ),
                          child: const Text('Unable to load. Tap to retry.'),
                        )
                      else
                        Text(
                          'Loading your experience...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppPalette.white.withValues(alpha: 0.8),
                          ),
                        ),
                      const SizedBox(height: 44),
                      Text(
                        'Revo Racers | Game Development Club',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.angle);

  final IconData icon;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: AppPalette.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: AppPalette.white, size: 30),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.white.withValues(alpha: 0.45),
      ),
    );
  }
}
