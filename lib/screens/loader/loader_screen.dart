import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';

/// Cinematic terminal boot loader screen with rich animated background.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with TickerProviderStateMixin {
  final List<String> _visibleLines = [];
  int _currentLine = 0;
  double _progress = 0.0;
  bool _iconVisible = false;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _gridController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _startSequence();
  }

  void _startSequence() async {
    // Show icon
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _iconVisible = true);

    // Type each line
    await Future.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < AppStrings.loaderMessages.length; i++) {
      if (!mounted) return;
      setState(() {
        _visibleLines.add(AppStrings.loaderMessages[i]);
        _currentLine = i;
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Progress bar
    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.forward();
    _progressController.addListener(() {
      if (mounted) setState(() => _progress = _progressController.value);
    });

    // Navigate after completion
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _progressController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Layer 1: Animated grid lines
          _AnimatedGrid(animation: _gridController),
          // Layer 2: Orbital rings
          _OrbitalRings(animation: _orbitController),
          // Layer 3: Central pulse glow
          _PulseGlow(animation: _pulseController),
          // Layer 4: Floating particles (more than before)
          ...List.generate(14, (i) => _buildParticle(i)),
          // Layer 5: Floating code fragments
          ...List.generate(5, (i) => _buildCodeFragment(i)),
          // Layer 6: Scanning line
          _ScanLine(animation: _gridController),
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Code icon with glow
                AnimatedOpacity(
                  opacity: _iconVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedScale(
                    scale: _iconVisible ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final glowOpacity = 0.15 + 0.15 * _pulseController.value;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(glowOpacity),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryLight.withOpacity(0.3),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '< >',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Typing lines
                ...List.generate(_visibleLines.length, (i) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 8 * (1 - value)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '> ',
                                  style: AppTextStyles.mono(
                                    size: 14,
                                    color: AppColors.primaryLight.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  _visibleLines[i],
                                  style: AppTextStyles.mono(
                                    size: 14,
                                    color: AppColors.loaderText,
                                  ),
                                ),
                                if (i == _visibleLines.length - 1) ...[
                                  const SizedBox(width: 2),
                                  _BlinkingCursor(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 40),
                // Progress bar
                SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      // Progress with glow
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            // Background
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Fill
                            FractionallySizedBox(
                              widthFactor: _progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryDim,
                                      AppColors.primaryLight,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryLight.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Percentage
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: AppTextStyles.mono(
                          size: 11,
                          color: AppColors.primaryLight.withOpacity(0.7),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.systemVersion,
                        style: AppTextStyles.mono(
                          size: 10,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index * 7 + 3);
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final size = 1.5 + random.nextDouble() * 3.5;
    final speed = 0.05 + random.nextDouble() * 0.15;
    final isAccent = index % 4 == 0;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final time = _particleController.value;
        final dx = (startX + math.sin(time * math.pi * 2 + index * 0.7) * 0.03) *
            screenSize.width;
        final dy = ((startY + time * speed) % 1.0) * screenSize.height;
        final opacity = 0.1 +
            0.2 * math.sin(time * math.pi * 2 + index * 1.3).abs();
        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isAccent
                    ? AppColors.primaryLight
                    : AppColors.textMuted,
                shape: BoxShape.circle,
                boxShadow: isAccent
                    ? [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeFragment(int index) {
    final random = math.Random(index * 13 + 42);
    final fragments = [
      'fn init()',
      'async {}',
      '=> void',
      'const π',
      'import *',
    ];
    final startX = 0.05 + random.nextDouble() * 0.85;
    final startY = 0.1 + random.nextDouble() * 0.8;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final time = _particleController.value;
        final dx = startX * screenSize.width +
            math.sin(time * math.pi * 2 + index * 1.2) * 15;
        final dy = startY * screenSize.height +
            math.cos(time * math.pi * 2 + index * 0.8) * 10;
        final opacity = 0.04 + 0.06 * math.sin(time * math.pi * 2 + index);
        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Text(
              fragments[index % fragments.length],
              style: AppTextStyles.mono(
                size: 11,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Background animation layers
// ═══════════════════════════════════════════════════════════════

/// Animated perspective grid that subtly pulses.
class _AnimatedGrid extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedGrid({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _GridPainter(animation.value),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;

  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Vertical lines
    const spacing = 60.0;
    final lineCount = (size.width / spacing).ceil() + 1;
    for (int i = 0; i < lineCount; i++) {
      final x = i * spacing;
      final opacity = 0.03 + 0.02 * math.sin(progress * math.pi * 2 + i * 0.3);
      paint.color = AppColors.primaryLight.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    final hLineCount = (size.height / spacing).ceil() + 1;
    for (int i = 0; i < hLineCount; i++) {
      final y = i * spacing;
      final opacity = 0.03 + 0.02 * math.sin(progress * math.pi * 2 + i * 0.5);
      paint.color = AppColors.primaryLight.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Grid intersection dots
    for (int i = 0; i < lineCount; i++) {
      for (int j = 0; j < hLineCount; j++) {
        final dist = math.sqrt(
            math.pow(i - lineCount / 2, 2) + math.pow(j - hLineCount / 2, 2));
        final opacity =
            0.06 * math.exp(-dist * 0.08) * (0.7 + 0.3 * math.sin(progress * math.pi * 2 + dist * 0.3));
        if (opacity > 0.01) {
          paint.color = AppColors.primaryLight.withOpacity(opacity.clamp(0.0, 1.0));
          paint.style = PaintingStyle.fill;
          canvas.drawCircle(Offset(i * spacing, j * spacing), 1.5, paint);
          paint.style = PaintingStyle.stroke;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Concentric orbital rings rotating around the center.
class _OrbitalRings extends StatelessWidget {
  final Animation<double> animation;

  const _OrbitalRings({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _OrbitalPainter(animation.value),
        );
      },
    );
  }
}

class _OrbitalPainter extends CustomPainter {
  final double progress;

  _OrbitalPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw 3 concentric elliptical arcs
    final radii = [140.0, 200.0, 280.0];
    final opacities = [0.08, 0.05, 0.03];
    final speeds = [1.0, -0.7, 0.4];

    for (int i = 0; i < radii.length; i++) {
      final angle = progress * math.pi * 2 * speeds[i];
      paint.color = AppColors.primaryLight.withOpacity(opacities[i]);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.scale(1.0, 0.35); // squash to ellipse

      // Draw arc (not full circle)
      final rect = Rect.fromCircle(center: Offset.zero, radius: radii[i]);
      canvas.drawArc(rect, 0, math.pi * 1.3, false, paint);

      // Small orbiting dot
      final dotAngle = angle * 2 + i * math.pi / 3;
      final dotX = radii[i] * math.cos(dotAngle);
      final dotY = radii[i] * math.sin(dotAngle);
      paint.style = PaintingStyle.fill;
      paint.color = AppColors.primaryLight.withOpacity(opacities[i] * 3);
      canvas.drawCircle(Offset(dotX, dotY), 2.5, paint);
      paint.style = PaintingStyle.stroke;

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Central pulse glow effect.
class _PulseGlow extends StatelessWidget {
  final Animation<double> animation;

  const _PulseGlow({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final glowRadius = 120.0 + 40.0 * animation.value;
        return Positioned(
          left: size.width / 2 - glowRadius,
          top: size.height / 2 - glowRadius - 40,
          child: Container(
            width: glowRadius * 2,
            height: glowRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.06 * animation.value),
                  AppColors.primary.withOpacity(0.02 * animation.value),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal scan line sweeping down the screen.
class _ScanLine extends StatelessWidget {
  final Animation<double> animation;

  const _ScanLine({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final y = animation.value * size.height;
        return Positioned(
          left: 0,
          top: y,
          child: Container(
            width: size.width,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryLight.withOpacity(0.06),
                  AppColors.primaryLight.withOpacity(0.12),
                  AppColors.primaryLight.withOpacity(0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Blinking cursor widget for the terminal effect.
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value > 0.5 ? 1.0 : 0.0,
          child: Container(
            width: 8,
            height: 16,
            color: AppColors.primaryLight.withOpacity(0.7),
          ),
        );
      },
    );
  }
}
