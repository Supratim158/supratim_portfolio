import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mini_coding_pc.dart';
import 'mini_terminal_typing.dart';

class InteractiveCoderScene extends StatefulWidget {
  final bool isBackground;
  /// When non-null, this offset drives the parallax instead of the internal MouseRegion.
  /// Use this when the widget is placed behind other content that absorbs pointer events.
  final Offset? externalMouseOffset;
  const InteractiveCoderScene({super.key, this.isBackground = false, this.externalMouseOffset});

  @override
  State<InteractiveCoderScene> createState() => _InteractiveCoderSceneState();
}

class _InteractiveCoderSceneState extends State<InteractiveCoderScene>
    with SingleTickerProviderStateMixin {
  Offset _mouseOffset = Offset.zero;
  late AnimationController _rotationController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        final activeWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 580.0;
        final activeHeight = constraints.maxHeight > 0 ? constraints.maxHeight : 450.0;

        // Use parent-driven offset when available (background mode behind other content)
        if (widget.externalMouseOffset != null) {
          _mouseOffset = widget.externalMouseOffset!;
        }

        Widget content = MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) {
            setState(() {
              _isHovering = false;
              _mouseOffset = Offset.zero;
            });
          },
          onHover: widget.externalMouseOffset != null
              ? null
              : (event) {
                  // Calculate normalized offset from center (-1.0 to 1.0)
                  final localX = event.localPosition.dx;
                  final localY = event.localPosition.dy;
                  setState(() {
                    _mouseOffset = Offset(
                      (localX - (activeWidth / 2)) / (activeWidth / 2),
                      (localY - (activeHeight / 2)) / (activeHeight / 2),
                    );
                  });
                },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: widget.isBackground
                ? const BoxDecoration(color: Colors.transparent)
                : BoxDecoration(
                    color: const Color(0xFF0F111A).withOpacity(_isHovering ? 0.75 : 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHovering
                          ? const Color(0xFF00FFCC).withOpacity(0.35)
                          : const Color(0xFF1F2335).withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FFCC).withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
            child: Stack(
              children: [
                // Layer 1: Digital Tech Grid Background (moves opposite to cursor, full-screen coverage)
                Positioned.fill(
                  child: TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(begin: Offset.zero, end: _mouseOffset),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: Offset(-offset.dx * 12, -offset.dy * 12),
                        child: CustomPaint(
                          painter: GridBackgroundPainter(),
                        ),
                      );
                    },
                  ),
                ),

                // Center workspace box containing enlarged screens
                Center(
                  child: isMobile
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 900,
                            height: 500,
                            child: ClipRect(
                              child: TweenAnimationBuilder<Offset>(
                                tween: Tween<Offset>(begin: Offset.zero, end: _mouseOffset),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                builder: (context, offset, child) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Layer 2: Floating code binary/glitch elements
                                      Positioned(
                                        left: 40,
                                        top: 60,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * -15, offset.dy * -15),
                                          child: _buildFloatingText("01010110", Colors.cyan.withOpacity(0.12)),
                                        ),
                                      ),
                                      Positioned(
                                        right: 60,
                                        top: 100,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * -18, offset.dy * -18),
                                          child: _buildFloatingText("supratimz", Colors.purple.withOpacity(0.15)),
                                        ),
                                      ),

                                      // Layer 3: Enlarged Computer Screens (Left, Right, Center, HUD)
                                      // Center PC
                                      Positioned(
                                        left: 275,
                                        top: 60,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * 12, offset.dy * 8),
                                          child: MiniCodingPC(
                                            title: "vs-code — portfolio",
                                            screenType: ScreenType.ide,
                                            rotateYAngle: offset.dx * 0.06,
                                            rotateXAngle: -0.06 + offset.dy * 0.04,
                                            glowColor: const Color(0xFFFF79C6), // Pink glow
                                            width: 350,
                                            height: 250,
                                          ),
                                        ),
                                      ),

                                      // Left PC (angled right)
                                      Positioned(
                                        left: 20,
                                        top: 160,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * 18, offset.dy * 12),
                                          child: MiniCodingPC(
                                            title: "zsh — deployment",
                                            screenType: ScreenType.terminal,
                                            rotateYAngle: 0.38 + offset.dx * 0.05,
                                            rotateXAngle: -0.04 + offset.dy * 0.04,
                                            glowColor: const Color(0xFF8BE9FD), // Cyan glow
                                            width: 270,
                                            height: 210,
                                            typingSpeed: const Duration(milliseconds: 25),
                                          ),
                                        ),
                                      ),

                                      // Right PC (angled left)
                                      Positioned(
                                        right: 20,
                                        top: 160,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * 18, offset.dy * 12),
                                          child: MiniCodingPC(
                                            title: "postgresql — analytics",
                                            screenType: ScreenType.database,
                                            rotateYAngle: -0.38 + offset.dx * 0.05,
                                            rotateXAngle: -0.04 + offset.dy * 0.04,
                                            glowColor: const Color(0xFF50FA7B), // Green glow
                                            width: 270,
                                            height: 210,
                                            typingSpeed: const Duration(milliseconds: 40),
                                          ),
                                        ),
                                      ),

                                      // Floating HUD analytics window (top-right, no stand, tilts)
                                      Positioned(
                                        right: 80,
                                        top: 25,
                                        child: Transform.translate(
                                          offset: Offset(offset.dx * 22, offset.dy * 16),
                                          child: Transform(
                                            transform: Matrix4.identity()
                                              ..setEntry(3, 2, 0.001)
                                              ..rotateY(-0.25 + offset.dx * 0.04)
                                              ..rotateX(-0.1 + offset.dy * 0.04),
                                            child: Container(
                                              width: 200,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A1B26).withOpacity(0.85),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: const Color(0xFFBD93F9).withOpacity(0.5),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFBD93F9).withOpacity(0.2),
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: const MiniTerminalTyping(
                                                  type: ScreenType.analytics,
                                                  typingSpeed: Duration(milliseconds: 60),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 900,
                          height: 500,
                          child: ClipRect(
                            child: TweenAnimationBuilder<Offset>(
                              tween: Tween<Offset>(begin: Offset.zero, end: _mouseOffset),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              builder: (context, offset, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Layer 2: Floating code binary/glitch elements
                                    Positioned(
                                      left: 40,
                                      top: 60,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * -15, offset.dy * -15),
                                        child: _buildFloatingText("01010110", Colors.cyan.withOpacity(0.12)),
                                      ),
                                    ),
                                    Positioned(
                                      right: 60,
                                      top: 100,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * -18, offset.dy * -18),
                                        child: _buildFloatingText("supratimz", Colors.purple.withOpacity(0.15)),
                                      ),
                                    ),

                                    // Layer 3: Enlarged Computer Screens (Left, Right, Center, HUD)
                                    // Center PC
                                    Positioned(
                                      left: 275,
                                      top: 60,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * 12, offset.dy * 8),
                                        child: MiniCodingPC(
                                          title: "vs-code — portfolio",
                                          screenType: ScreenType.ide,
                                          rotateYAngle: offset.dx * 0.06,
                                          rotateXAngle: -0.06 + offset.dy * 0.04,
                                          glowColor: const Color(0xFFFF79C6), // Pink glow
                                          width: 350,
                                          height: 250,
                                        ),
                                      ),
                                    ),

                                    // Left PC (angled right)
                                    Positioned(
                                      left: 20,
                                      top: 160,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * 18, offset.dy * 12),
                                        child: MiniCodingPC(
                                          title: "zsh — deployment",
                                          screenType: ScreenType.terminal,
                                          rotateYAngle: 0.38 + offset.dx * 0.05,
                                          rotateXAngle: -0.04 + offset.dy * 0.04,
                                          glowColor: const Color(0xFF8BE9FD), // Cyan glow
                                          width: 270,
                                          height: 210,
                                          typingSpeed: const Duration(milliseconds: 25),
                                        ),
                                      ),
                                    ),

                                    // Right PC (angled left)
                                    Positioned(
                                      right: 20,
                                      top: 160,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * 18, offset.dy * 12),
                                        child: MiniCodingPC(
                                          title: "postgresql — analytics",
                                          screenType: ScreenType.database,
                                          rotateYAngle: -0.38 + offset.dx * 0.05,
                                          rotateXAngle: -0.04 + offset.dy * 0.04,
                                          glowColor: const Color(0xFF50FA7B), // Green glow
                                          width: 270,
                                          height: 210,
                                          typingSpeed: const Duration(milliseconds: 40),
                                        ),
                                      ),
                                    ),

                                    // Floating HUD analytics window (top-right, no stand, tilts)
                                    Positioned(
                                      right: 80,
                                      top: 25,
                                      child: Transform.translate(
                                        offset: Offset(offset.dx * 22, offset.dy * 16),
                                        child: Transform(
                                          transform: Matrix4.identity()
                                            ..setEntry(3, 2, 0.001)
                                            ..rotateY(-0.25 + offset.dx * 0.04)
                                            ..rotateX(-0.1 + offset.dy * 0.04),
                                          child: Container(
                                            width: 200,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A1B26).withOpacity(0.85),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFFBD93F9).withOpacity(0.5),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFBD93F9).withOpacity(0.2),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: const MiniTerminalTyping(
                                                type: ScreenType.analytics,
                                                typingSpeed: Duration(milliseconds: 60),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );

        return content;
      },
    );
  }

  Widget _buildFloatingText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildDeveloperAvatar() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Futuristic Rotating Outer Rings
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFCC).withOpacity(0.3),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Stack(
                    children: List.generate(4, (index) {
                      final angle = (index * math.pi / 2);
                      return Transform.rotate(
                        angle: angle,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00FFCC),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),

          // Glowing Aura Pulse
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              final pulseFactor = 1.0 + 0.05 * math.sin(_rotationController.value * 4 * math.pi);
              return Transform.scale(
                scale: pulseFactor,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBD93F9).withOpacity(0.25),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          // Central Profile Image / Developer Icon Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF16161E),
              border: Border.all(
                color: const Color(0xFFBD93F9),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Premium developer placeholder avatar if profile.png fails
                  return Container(
                    color: const Color(0xFF1F2335),
                    child: const Icon(
                      Icons.code,
                      color: Color(0xFF00FFCC),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          // "CODING" Indicator badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFCC),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFCC).withOpacity(0.4),
                    blurRadius: 6,
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard_double_arrow_right, size: 10, color: Colors.black),
                  SizedBox(width: 2),
                  Text(
                    "ACTIVE",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkstationKeyboard(Offset offset) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0018)
        ..rotateX(1.0) // Lay flat on desk
        ..rotateY(offset.dx * 0.03)
        ..rotateZ(offset.dy * -0.02),
      alignment: Alignment.center,
      child: Container(
        width: 150,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF00FFCC).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFCC).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (keyIndex) {
                // Keycaps animate flashing states representing typing
                final isFlashing = (rowIndex + keyIndex) % 3 == 0;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 150 + (keyIndex % 4) * 80),
                  width: 11,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1.2),
                  decoration: BoxDecoration(
                    color: isFlashing
                        ? const Color(0xFF00FFCC).withOpacity(0.85)
                        : const Color(0xFF3B4252),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHUDMetricCircle(String label, String value, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2335).withOpacity(0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Background painter that draws a digital tech grid and glowing star nodes
class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2335).withOpacity(0.45)
      ..strokeWidth = 1.0;

    const gridSpacing = 30.0;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw small glowing nodes at grid intersections
    final dotPaint = Paint()
      ..color = const Color(0xFF00FFCC).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 2.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.25), 1.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.8), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
