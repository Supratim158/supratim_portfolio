import 'package:flutter/material.dart';
import 'mini_terminal_typing.dart';

class MiniCodingPC extends StatelessWidget {
  final String title;
  final ScreenType screenType;
  final double rotateYAngle; // in radians, for 3D left/right angle
  final double rotateXAngle; // in radians, for 3D tilt
  final Color glowColor;
  final double width;
  final double height;
  final Duration typingSpeed;

  const MiniCodingPC({
    super.key,
    required this.title,
    required this.screenType,
    this.rotateYAngle = 0.0,
    this.rotateXAngle = 0.0,
    required this.glowColor,
    this.width = 240,
    this.height = 180,
    this.typingSpeed = const Duration(milliseconds: 35),
  });

  @override
  Widget build(BuildContext context) {
    // 3D Perspective Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // Perspective factor (depth perception)
      ..rotateX(rotateXAngle)
      ..rotateY(rotateYAngle);

    return Center(
      child: Container(
        width: width,
        height: height + 40, // Height plus the stand
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. The Monitor Stand (drawn behind screen, but connected at bottom)
            Positioned(
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Neck of the monitor
                  Container(
                    width: 18,
                    height: 25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E2030),
                          Color(0xFF3B4252),
                          Color(0xFF1E2030),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                  // Stand Base
                  Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2335),
                      borderRadius: const BorderRadius.all(Radius.elliptical(35, 3)),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. The 3D Transformed Screen Bezel and Display
            Transform(
              transform: matrix,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2335),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF414868).withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Outer screen glow
                    BoxShadow(
                      color: glowColor.withOpacity(0.35),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4), // Screen bezel width
                child: Column(
                  children: [
                    // Bezel top bar (macOS style window headers)
                    Container(
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16161E),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          // macOS dots
                          _buildWindowDot(const Color(0xFFFF5555)),
                          const SizedBox(width: 4),
                          _buildWindowDot(const Color(0xFFFFB86C)),
                          const SizedBox(width: 4),
                          _buildWindowDot(const Color(0xFF50FA7B)),
                          const SizedBox(width: 8),
                          // Window Title
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Empty space for balance
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                    // Screen Content (Typewriter terminal)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                        child: MiniTerminalTyping(
                          type: screenType,
                          typingSpeed: typingSpeed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
