import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 登录页专用的低负载粒子背景。
///
/// 粒子只由一个 [CustomPainter] 绘制，不创建多颗动画 Widget；视觉上
/// 保持克制，且在系统请求“减少动态效果”时自动静止。
class LoginParticleBackdrop extends StatefulWidget {
  const LoginParticleBackdrop({super.key});

  @override
  State<LoginParticleBackdrop> createState() => _LoginParticleBackdropState();
}

class _LoginParticleBackdropState extends State<LoginParticleBackdrop>
    with SingleTickerProviderStateMixin {
  static const _particles = [
    _LoginParticle(0.08, 0.14, 0.052, 2.2, 0.080, 2.4),
    _LoginParticle(0.24, 0.05, 0.036, 4.8, 0.055, 3.2),
    _LoginParticle(0.42, 0.22, 0.056, 0.6, 0.065, 2.8),
    _LoginParticle(0.70, 0.10, 0.040, 5.6, 0.055, 2.1),
    _LoginParticle(0.88, 0.28, 0.060, 3.4, 0.075, 3.0),
    _LoginParticle(0.14, 0.44, 0.038, 1.1, 0.050, 2.6),
    _LoginParticle(0.33, 0.56, 0.054, 4.1, 0.070, 3.4),
    _LoginParticle(0.57, 0.42, 0.034, 2.9, 0.045, 2.0),
    _LoginParticle(0.76, 0.61, 0.056, 0.2, 0.065, 3.1),
    _LoginParticle(0.93, 0.48, 0.040, 5.0, 0.050, 2.5),
    _LoginParticle(0.09, 0.77, 0.058, 3.8, 0.070, 2.9),
    _LoginParticle(0.28, 0.89, 0.036, 1.7, 0.045, 2.2),
    _LoginParticle(0.61, 0.83, 0.052, 5.4, 0.060, 3.3),
    _LoginParticle(0.84, 0.91, 0.040, 2.5, 0.050, 2.7),
  ];

  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _controller.isAnimating) {
      return;
    }

    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.gradientAtmosphere,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _LoginParticlePainter(
                progress: _reduceMotion ? 0.36 : _controller.value,
                particles: _particles,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginParticlePainter extends CustomPainter {
  final double progress;
  final List<_LoginParticle> particles;

  const _LoginParticlePainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cycle = progress * math.pi * 2;

    for (final particle in particles) {
      final phase = cycle + particle.phase;
      final center = Offset(
        particle.x * size.width + math.sin(phase) * particle.drift * size.width,
        particle.y * size.height +
            math.cos(phase * 0.84) * particle.drift * size.height * 0.52,
      );
      final opacity = particle.opacity * (0.78 + math.sin(phase) * 0.22);
      final paint = Paint()
        ..color = AppColors.primaryLight.withValues(alpha: opacity);
      canvas.drawCircle(center, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoginParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LoginParticle {
  final double x;
  final double y;
  final double opacity;
  final double phase;
  final double drift;
  final double radius;

  const _LoginParticle(
    this.x,
    this.y,
    this.opacity,
    this.phase,
    this.drift,
    this.radius,
  );
}
