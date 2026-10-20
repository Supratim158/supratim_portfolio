import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';

/// Realistic developer-workstation side panels (pure Flutter, NO images).
///
/// - No box / border / opaque background: the scenery blends into the page
///   background and every edge fades out softly.
/// - Staggered entrance animation on open:
///     LEFT : lamp drops in -> light flickers on -> laptop lid opens -> screen
///            boots + code types in -> notebook & pen appear.
///     RIGHT: neon sign flickers on (with the lamp) -> headphones -> books
///            drop one by one (with the laptop) -> plant & pen cup.
/// - The lamp beam is painted OVER the laptop, so the light really falls on the
///   screen, keyboard, notebook and desk. Every object has contact shadows.
class DeskSceneryPanel extends StatelessWidget {
  final bool isLeft;

  const DeskSceneryPanel({
    super.key,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: _kPanelW,
        height: _kPanelH,
        child: _EdgeBlend(
          child: isLeft ? const DeskLeftLampScenery() : const DeskRightScenery(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SHARED CONSTANTS & HELPERS
// ══════════════════════════════════════════════════════════════════

const double _kPanelW = 280;
const double _kPanelH = 520;
const double _kDeskTop = 270;
const double _kDeskH = _kPanelH - _kDeskTop;

/// Maps the master timeline [v] (0..1) onto the window [a]..[b] with a curve.
double _seg(double v, double a, double b, [Curve curve = Curves.easeOutCubic]) {
  if (b <= a) return 1;
  final x = ((v - a) / (b - a)).clamp(0.0, 1.0).toDouble();
  return curve.transform(x);
}

/// Neon / bulb "turning on" flicker. 0 -> off, 1 -> fully on.
double _flicker(double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  final base = (t * 1.4).clamp(0.0, 1.0).toDouble();
  final f = 0.65 + 0.35 * math.sin(t * 38).abs();
  final k = ((t - 0.6) / 0.4).clamp(0.0, 1.0).toDouble();
  return base * (f * (1 - k) + k);
}

/// Fade + slide + scale reveal.
Widget _reveal({
  required double t,
  double dx = 0,
  double dy = 0,
  double from = 1.0,
  Alignment align = Alignment.center,
  required Widget child,
}) {
  final o = t.clamp(0.0, 1.0).toDouble();
  if (o <= 0) return const SizedBox.shrink();
  return Opacity(
    opacity: o,
    child: Transform.translate(
      offset: Offset(dx * (1 - t), dy * (1 - t)),
      child: Transform.scale(
        scale: from + (1 - from) * t,
        alignment: align,
        child: child,
      ),
    ),
  );
}

Color _dark(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _light(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

/// Softly fades all four edges to transparent so the panel melts into the bg.
class _EdgeBlend extends StatelessWidget {
  final Widget child;
  const _EdgeBlend({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0.0, 0.13, 0.87, 1.0],
      ).createShader(rect),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.07, 0.86, 1.0],
        ).createShader(rect),
        child: child,
      ),
    );
  }
}

/// Soft elliptical glow (radial gradient stretched to the rect).
class _GlowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  _GlowPainter(this.color, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rect = Offset.zero & size;
    final shader = RadialGradient(
      colors: [
        color.withOpacity((opacity).clamp(0.0, 1.0).toDouble()),
        color.withOpacity((opacity * 0.4).clamp(0.0, 1.0).toDouble()),
        color.withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);
    canvas.drawOval(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) =>
      old.opacity != opacity || old.color != color;
}

Widget _glow({
  required double left,
  required double top,
  required double width,
  required double height,
  required Color color,
  required double opacity,
}) {
  return Positioned(
    left: left,
    top: top,
    width: width,
    height: height,
    child: IgnorePointer(
      child: CustomPaint(painter: _GlowPainter(color, opacity)),
    ),
  );
}

/// Blurred dark oval used as a contact shadow under objects.
class _ShadowPainter extends CustomPainter {
  final double opacity;
  final double sigma;
  _ShadowPainter(this.opacity, this.sigma);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      sigma,
      sigma * 0.5,
      math.max(0, size.width - sigma * 2),
      math.max(0, size.height - sigma),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.black.withOpacity(opacity.clamp(0.0, 1.0).toDouble())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.opacity != opacity || old.sigma != sigma;
}

Widget _shadow({
  required double left,
  required double top,
  required double width,
  required double height,
  required double opacity,
  double sigma = 6,
}) {
  return Positioned(
    left: left,
    top: top,
    width: width,
    height: height,
    child: IgnorePointer(
      child: CustomPaint(painter: _ShadowPainter(opacity, sigma)),
    ),
  );
}

/// Wooden desk surface with grain and a soft highlighted front edge.
class _WoodDeskPainter extends CustomPainter {
  final int seed;
  _WoodDeskPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3D2616),
            Color(0xFF29170E),
            Color(0xFF160C07),
          ],
        ).createShader(rect),
    );

    // Wood grain
    final rnd = math.Random(seed);
    for (int i = 0; i < 54; i++) {
      final y = rnd.nextDouble() * h;
      final a = (rnd.nextDouble() - 0.5) * 5;
      final b = (rnd.nextDouble() - 0.5) * 5;
      final lightLine = rnd.nextBool();
      final p = Path()
        ..moveTo(0, y)
        ..cubicTo(w * 0.3, y + a, w * 0.65, y + b, w, y + (a + b) * 0.5);
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5 + rnd.nextDouble() * 1.3
          ..color = (lightLine ? const Color(0xFF8A5A36) : Colors.black)
              .withOpacity(lightLine ? 0.07 : 0.16),
      );
    }

    // Back-edge shadow (wall/desk contact) for depth
    final backRect = Rect.fromLTWH(0, 0, w, 34);
    canvas.drawRect(
      backRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.55), Colors.transparent],
        ).createShader(backRect),
    );

    // Bevel highlight that fades towards both sides
    final lineRect = Rect.fromLTWH(0, 0, w, 1.6);
    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFB07A4C).withOpacity(0.75),
            Colors.transparent,
          ],
        ).createShader(lineRect),
    );
  }

  @override
  bool shouldRepaint(covariant _WoodDeskPainter old) => old.seed != seed;
}

// ══════════════════════════════════════════════════════════════════
//  LEFT SCENERY: LAMP + LIGHT BEAM + LAPTOP
// ══════════════════════════════════════════════════════════════════

class DeskLeftLampScenery extends StatefulWidget {
  const DeskLeftLampScenery({super.key});

  @override
  State<DeskLeftLampScenery> createState() => _DeskLeftLampSceneryState();
}

class _DeskLeftLampSceneryState extends State<DeskLeftLampScenery>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter; // one-shot entrance timeline

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final e = _enter.value;
        // Subtle ambient flicker during entrance that settles to still
        final pulse = e < 1.0 ? (math.sin(e * math.pi * 6).abs() * (1.0 - e)) : 0.0;

        // ── Timeline ──────────────────────────────────────────────
        final deskT = _seg(e, 0.00, 0.14, Curves.easeOut);
        final lampT = _seg(e, 0.00, 0.24, Curves.easeOutBack);
        final beam = _flicker(_seg(e, 0.20, 0.38, Curves.linear));
        final laptopT = _seg(e, 0.36, 0.56);
        final lid = _seg(e, 0.38, 0.62, Curves.easeInOutCubic);
        final screenOn = _seg(e, 0.58, 0.82, Curves.linear);
        final noteT = _seg(e, 0.62, 0.78);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Wooden desk (blends into bg through the edge mask)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _kDeskH,
              child: Opacity(
                opacity: deskT,
                child: CustomPaint(painter: _WoodDeskPainter(11)),
              ),
            ),

            // 2. Warm light pool on the wood where the beam lands
            _glow(
              left: 14,
              top: _kDeskTop - 14,
              width: 262,
              height: 190,
              color: const Color(0xFFFFB300),
              opacity: 0.34 * beam + 0.04 * pulse * beam,
            ),

            // 3. Laptop contact shadow
            _shadow(
              left: 8,
              top: 272,
              width: 264,
              height: 30,
              opacity: 0.8 * laptopT,
              sigma: 7,
            ),

            // 4. Laptop (lid opens, screen boots)
            Positioned(
              top: 104,
              left: 20,
              right: 20,
              child: _reveal(
                t: laptopT,
                dy: 26,
                child: _buildLaptop(lid, screenOn, beam, pulse),
              ),
            ),

            // 5. Notebook & pen on the desk in front of the laptop
            _shadow(
              left: 18,
              top: 330,
              width: 250,
              height: 22,
              opacity: 0.7 * noteT,
              sigma: 5,
            ),
            Positioned(
              top: 312,
              left: 26,
              right: 22,
              child: _reveal(
                t: noteT,
                dy: 14,
                child: _buildNotebookAndPen(beam),
              ),
            ),

            // 6. Light beam painted OVER laptop/desk: light really hits them
            SizedBox.expand(
              child: CustomPaint(
                painter: _LampPainter(
                  pulse: pulse,
                  lampT: lampT,
                  beam: beam,
                  beamOnly: true,
                ),
              ),
            ),

            // 7. Lamp hardware on top of the beam
            SizedBox.expand(
              child: Opacity(
                opacity: lampT.clamp(0.0, 1.0).toDouble(),
                child: CustomPaint(
                  painter: _LampPainter(
                    pulse: pulse,
                    lampT: lampT,
                    beam: beam,
                    beamOnly: false,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── LAPTOP ──────────────────────────────────────────────────────
  Widget _buildLaptop(double lid, double screenOn, double light, double pulse) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(1.25 * (1 - lid)),
          child: _buildScreen(screenOn, light, pulse),
        ),
        SizedBox(
          height: 34,
          width: double.infinity,
          child: CustomPaint(painter: _LaptopDeckPainter(light)),
        ),
      ],
    );
  }

  Widget _buildScreen(double screenOn, double light, double pulse) {
    final lines = <List<InlineSpan>>[
      [
        _tok('class ', const Color(0xFFF43F5E)),
        _tok('SupratimPortfolio ', const Color(0xFF38BDF8)),
        _tok('{', Colors.white),
      ],
      [
        _tok('  final ', const Color(0xFFF43F5E)),
        _tok('focus = ', Colors.white70),
        _tok("'FullStack';", const Color(0xFF34D399)),
      ],
      [
        _tok('  void ', const Color(0xFFF43F5E)),
        _tok('renderUI', const Color(0xFFFBBF24)),
        _tok('() {', Colors.white),
      ],
      [
        _tok('    buildStudioWorkspace', const Color(0xFF818CF8)),
        _tok('();', Colors.white70),
      ],
      [_tok('  }', Colors.white)],
      [_tok('}', Colors.white)],
    ];

    double lineOpacity(int i) =>
        (screenOn * (lines.length + 1) - i).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A5470), Color(0xFF2A3145)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        boxShadow: [
          // Screen emission glow
          BoxShadow(
            color: const Color(0xFF38BDF8)
                .withOpacity((0.20 + pulse * 0.05) * screenOn),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
          // Warm lamp light catching the top of the lid
          BoxShadow(
            color: const Color(0xFFFFB74D).withOpacity(0.32 * light),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
        child: SizedBox(
          height: 164,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: const Color(0xFF05070D)),
              ),
              // Screen content (boots after lid is open)
              Positioned.fill(
                child: Opacity(
                  opacity: screenOn,
                  child: Column(
                    children: [
                      Container(
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: const Color(0xFF060910),
                        child: Row(
                          children: [
                            _dot(const Color(0xFFFF5F56)),
                            const SizedBox(width: 4),
                            _dot(const Color(0xFFFFBD2E)),
                            const SizedBox(width: 4),
                            _dot(const Color(0xFF27C93F)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111728),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.flutter_dash,
                                      size: 7.5, color: Color(0xFF38BDF8)),
                                  const SizedBox(width: 3.5),
                                  Text(
                                    'portfolio.dart',
                                    style: AppTextStyles.mono(
                                        size: 6.5, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          color: const Color(0xFF080C16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(
                                  lines.length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2.5),
                                    child: Opacity(
                                      opacity: lineOpacity(i),
                                      child: Text(
                                        '${i + 1}',
                                        style: AppTextStyles.mono(
                                          size: 6.5,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < lines.length; i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.5),
                                        child: Opacity(
                                          opacity: lineOpacity(i),
                                          child: _codeLine(lines[i]),
                                        ),
                                      ),
                                  ],
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
              // Lamp light falling directly on the glass
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScreenGlarePainter(light, pulse),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _codeLine(List<InlineSpan> spans) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.mono(size: 6.5),
        children: spans,
      ),
    );
  }

  InlineSpan _tok(String text, Color color) {
    return TextSpan(
      text: text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  // ── NOTEBOOK + PEN ──────────────────────────────────────────────
  Widget _buildNotebookAndPen(double light) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -0.04,
          child: SizedBox(
            width: 98,
            height: 28,
            child: Stack(
              children: [
                // page block (thickness)
                Positioned(
                  left: 2,
                  right: 1,
                  bottom: 0,
                  height: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7DFCB),
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFEFE8D6), Color(0xFFB9AF96)],
                      ),
                    ),
                  ),
                ),
                // cover
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 23,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFF34343C), width: 1),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2B2B33), Color(0xFF15151A)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // spine
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF3F3F4A),
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(3)),
                            ),
                          ),
                        ),
                        // elastic band
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          width: 3,
                          child: Container(color: const Color(0xFF8B1E2D)),
                        ),
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          right: 18,
                          child: Center(
                            child: Text(
                              'DEV_LOG.MD',
                              style: AppTextStyles.mono(
                                size: 7,
                                color: const Color(0xFF8A8A96),
                                letterSpacing: 1,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // lamp light across the cover
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFFFC46B)
                                        .withOpacity(0.30 * light),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
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
        ),
        const SizedBox(width: 14),
        // Metallic pen with clip, reflecting the lamp
        Expanded(
          child: Transform.rotate(
            angle: 0.07,
            child: SizedBox(
              height: 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 6,
                    top: 1.5,
                    height: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF4F4F5),
                            Color(0xFF8E8E98),
                            Color(0xFF1A1A20),
                          ],
                          stops: [0.0, 0.35, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 3,
                            offset: const Offset(0, 2.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // pen tip
                  Positioned(
                    right: 0,
                    top: 2.5,
                    width: 8,
                    height: 3,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A3A44),
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(2)),
                      ),
                    ),
                  ),
                  // clip
                  Positioned(
                    left: 6,
                    top: 0,
                    width: 20,
                    height: 1.8,
                    child: Container(color: const Color(0xFFD4D4D8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Keyboard deck in perspective: aluminium body, keys lit by the lamp, trackpad.
class _LaptopDeckPainter extends CustomPainter {
  final double light;
  _LaptopDeckPainter(this.light);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(7, 0)
      ..lineTo(w - 7, 0)
      ..lineTo(w, h - 4)
      ..quadraticBezierTo(w, h, w - 5, h)
      ..lineTo(5, h)
      ..quadraticBezierTo(0, h, 0, h - 4)
      ..close();

    final rect = Offset.zero & size;
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F475E), Color(0xFF282E41), Color(0xFF181C2A)],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(body);

    // warm lamp light on the deck
    if (light > 0) {
      final lr = Rect.fromCenter(
        center: Offset(w * 0.47, 0),
        width: w * 1.05,
        height: h * 2.2,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFC46B).withOpacity(0.38 * light),
              Colors.transparent,
            ],
          ).createShader(lr),
      );
    }

    // keys
    const rows = 3;
    for (int r = 0; r < rows; r++) {
      final y = 4.0 + r * 5.8;
      final inset = 9.0 - (y / h) * 7;
      final usable = w - inset * 2 - 12;
      const n = 15;
      final kw = usable / n - 1.4;
      for (int i = 0; i < n; i++) {
        final x = inset + 6 + i * (usable / n);
        final dist = ((x + kw / 2 - w * 0.47).abs() / (w * 0.5))
            .clamp(0.0, 1.0)
            .toDouble();
        final lit = (1 - dist) * light * 0.55;
        final keyRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, kw, 4.6),
          const Radius.circular(1),
        );
        canvas.drawRRect(
          keyRect,
          Paint()
            ..color = Color.lerp(
                const Color(0xFF0D1019), const Color(0xFF6A5638), lit)!,
        );
        canvas.drawLine(
          Offset(x + 0.5, y + 0.4),
          Offset(x + kw - 0.5, y + 0.4),
          Paint()
            ..color = Colors.white.withOpacity(0.10 + lit * 0.25)
            ..strokeWidth = 0.6,
        );
      }
    }

    // trackpad
    final pad = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(w / 2, h - 8.5), width: 62, height: 11),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(pad, Paint()..color = const Color(0xFF121622));
    canvas.drawRRect(
      pad,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF343C54),
    );

    canvas.restore();

    // top rim highlight (hinge line)
    canvas.drawLine(
      const Offset(7, 0.7),
      Offset(w - 7, 0.7),
      Paint()
        ..color = Color.lerp(
            const Color(0xFF6D7894), const Color(0xFFFFD9A0), light * 0.7)!
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _LaptopDeckPainter old) => old.light != light;
}

/// Lamp light on the glass: warm bloom where the beam hits + faint streak.
class _ScreenGlarePainter extends CustomPainter {
  final double light;
  final double pulse;
  _ScreenGlarePainter(this.light, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    if (light <= 0) return;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    final bloom = Rect.fromCenter(
      center: Offset(w * 0.46, 0),
      width: w * 1.25,
      height: h * 1.7,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE2A8)
                .withOpacity((0.40 + pulse * 0.04) * light),
            const Color(0xFFFFC46B).withOpacity(0.12 * light),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bloom),
    );

    // glass reflection streak
    final streak = Path()
      ..moveTo(w * 0.12, 0)
      ..lineTo(w * 0.42, 0)
      ..lineTo(w * 0.18, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      streak,
      Paint()..color = Colors.white.withOpacity(0.045 * light),
    );
  }

  @override
  bool shouldRepaint(covariant _ScreenGlarePainter old) =>
      old.light != light || old.pulse != pulse;
}

// ══════════════════════════════════════════════════════════════════
//  LAMP + BEAM PAINTER (shared exact coordinates, so they always collide)
// ══════════════════════════════════════════════════════════════════

class _LampPainter extends CustomPainter {
  final double pulse;
  final double lampT; // entrance progress (can overshoot slightly)
  final double beam; // light intensity 0..1
  final bool beamOnly;

  _LampPainter({
    required this.pulse,
    required this.lampT,
    required this.beam,
    required this.beamOnly,
  });

  static const Offset pMount = Offset(136, 62);
  static const double baseAngle = 0.10;
  static const double rimY = 46.0;
  static const double rimHalf = 38.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (beamOnly) {
      if (beam > 0.01) _paintBeam(canvas);
    } else {
      _paintHardware(canvas);
    }
  }

  void _paintBeam(Canvas canvas) {
    canvas.save();
    canvas.translate(pMount.dx, pMount.dy);
    canvas.rotate(baseAngle);

    // Wide ambient cone
    final wide = Path()
      ..moveTo(-rimHalf + 4, rimY)
      ..lineTo(rimHalf - 4, rimY)
      ..lineTo(125, 400)
      ..lineTo(-125, 400)
      ..close();

    final wideShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFF3D0).withOpacity((0.40 + pulse * 0.05) * beam),
        const Color(0xFFFFD54F).withOpacity(0.17 * beam),
        const Color(0xFFFFB300).withOpacity(0.06 * beam),
        Colors.transparent,
      ],
      stops: const [0.0, 0.22, 0.65, 1.0],
    ).createShader(const Rect.fromLTWH(-125, rimY, 250, 400 - rimY));

    canvas.drawPath(
      wide,
      Paint()
        ..shader = wideShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Brighter narrow core
    final core = Path()
      ..moveTo(-22, rimY)
      ..lineTo(22, rimY)
      ..lineTo(64, 300)
      ..lineTo(-64, 300)
      ..close();
    final coreShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFFFFF).withOpacity(0.22 * beam),
        const Color(0xFFFFE9B0).withOpacity(0.08 * beam),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(const Rect.fromLTWH(-64, rimY, 128, 300 - rimY));
    canvas.drawPath(
      core,
      Paint()
        ..shader = coreShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.restore();
  }

  void _bar(Canvas c, Offset a, Offset b) {
    c.drawLine(
      a + const Offset(0, 2.5),
      b + const Offset(0, 2.5),
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    c.drawLine(
      a,
      b,
      Paint()
        ..color = const Color(0xFF1A1E2A)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    c.drawLine(
      a + const Offset(0, -1.2),
      b + const Offset(0, -1.2),
      Paint()
        ..color = const Color(0xFF4A556F)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintHardware(Canvas canvas) {
    final t = lampT;
    final dy = -(1 - t) * 70;
    final angle = baseAngle + (1 - t) * 0.5;
    final b = beam.clamp(0.0, 1.0).toDouble();

    canvas.save();
    canvas.translate(0, dy);

    // Wall bracket
    const plateRect = Rect.fromLTWH(0, -4, 22, 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plateRect, const Radius.circular(3)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF30374C), Color(0xFF151925)],
        ).createShader(plateRect),
    );
    canvas.drawCircle(
        const Offset(11, 3), 1.6, Paint()..color = const Color(0xFF64748B));
    canvas.drawCircle(
        const Offset(11, 19), 1.6, Paint()..color = const Color(0xFF64748B));

    // Articulated twin arms
    const pOrigin = Offset(12, 10);
    const pJoint1 = Offset(68, 38);
    _bar(canvas, pOrigin, pJoint1);
    _bar(canvas, const Offset(16, 6), const Offset(72, 34));

    final jointPaint = Paint()..color = const Color(0xFF283042);
    canvas.drawCircle(pJoint1, 6.5, jointPaint);
    canvas.drawCircle(pJoint1, 2.5, Paint()..color = const Color(0xFF64748B));

    _bar(canvas, pJoint1, pMount);
    canvas.drawCircle(pMount, 6.0, jointPaint);
    canvas.drawCircle(pMount, 2.2, Paint()..color = const Color(0xFF64748B));

    // Shade
    canvas.save();
    canvas.translate(pMount.dx, pMount.dy);
    canvas.rotate(angle);

    // top knob
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-6, -14, 12, 8), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1B2030),
    );

    final hood = Path()
      ..moveTo(-15, -8)
      ..lineTo(15, -8)
      ..quadraticBezierTo(26, 20, rimHalf, rimY)
      ..lineTo(-rimHalf, rimY)
      ..quadraticBezierTo(-26, 20, -15, -8)
      ..close();

    canvas.drawPath(
      hood,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF3A4260),
            Color(0xFF141826),
            Color(0xFF0C0F18),
            Color(0xFF2A3148),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(
          const Rect.fromLTWH(-rimHalf, -8, rimHalf * 2, rimY + 8),
        ),
    );

    // glossy highlight along the hood
    final gloss = Path()
      ..moveTo(-10, -4)
      ..quadraticBezierTo(-20, 18, -29, 40);
    canvas.drawPath(
      gloss,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withOpacity(0.16 + 0.12 * b),
    );

    // warm light spilling onto the hood bottom from the bulb
    canvas.drawPath(
      hood,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFB74D).withOpacity(0.35 * b),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45],
        ).createShader(
          const Rect.fromLTWH(-rimHalf, -8, rimHalf * 2, rimY + 8),
        ),
    );

    // lit mouth of the shade
    final mouth = Rect.fromCenter(
        center: const Offset(0, rimY), width: rimHalf * 2, height: 10);
    canvas.drawOval(
      mouth,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFF3A2A18), Colors.white, b)!,
            Color.lerp(
                const Color(0xFF2A1D10), const Color(0xFFFFB74D), b)!,
          ],
        ).createShader(mouth),
    );
    canvas.drawOval(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF7C8AA5),
    );

    // bulb
    canvas.drawCircle(
      const Offset(0, rimY + 1),
      10 + pulse * 2,
      Paint()
        ..color = Colors.white.withOpacity(0.9 * b)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      const Offset(0, rimY + 1),
      5.5,
      Paint()
        ..color = Color.lerp(const Color(0xFF4A4036), Colors.white, b)!,
    );

    canvas.restore(); // shade
    canvas.restore(); // drop
  }

  @override
  bool shouldRepaint(covariant _LampPainter old) =>
      old.pulse != pulse ||
      old.lampT != lampT ||
      old.beam != beam ||
      old.beamOnly != beamOnly;
}

// ══════════════════════════════════════════════════════════════════
//  RIGHT SCENERY: NEON SIGN + HEADPHONES + PLANT + BOOKS (pure Flutter)
// ══════════════════════════════════════════════════════════════════

class DeskRightScenery extends StatefulWidget {
  const DeskRightScenery({super.key});

  @override
  State<DeskRightScenery> createState() => _DeskRightSceneryState();
}

class _DeskRightSceneryState extends State<DeskRightScenery>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final e = _enter.value;
        final pulse = e < 1.0 ? (math.sin(e * math.pi * 6).abs() * (1.0 - e)) : 0.0;

        // ── Timeline ──────────────────────────────────────────────
        final deskT = _seg(e, 0.00, 0.14, Curves.easeOut);
        final signT = _seg(e, 0.00, 0.22, Curves.easeOutBack);
        final neonOn = _flicker(_seg(e, 0.10, 0.32, Curves.linear));
        final neon = neonOn * (0.75 + 0.25 * pulse);
        final spillT = _seg(e, 0.20, 0.40, Curves.easeOut);
        final headT = _seg(e, 0.30, 0.52, Curves.easeOutBack);
        final plantT = _seg(e, 0.58, 0.78);

        // Books drop one by one (bottom first) alongside the laptop.
        double bookT(int indexFromTop) {
          final order = 3 - indexFromTop; // bottom book lands first
          final s = 0.38 + order * 0.06;
          return _seg(e, s, s + 0.16, Curves.easeOutBack);
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Purple neon bloom on the (invisible) wall
            _glow(
              left: 20,
              top: 10,
              width: 240,
              height: 190,
              color: const Color(0xFFA855F7),
              opacity: 0.20 * neonOn,
            ),

            // 2. Wooden desk
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _kDeskH,
              child: Opacity(
                opacity: deskT,
                child: CustomPaint(painter: _WoodDeskPainter(29)),
              ),
            ),

            // 3. Violet neon reflection on the wood + warm lamp spill from the left
            _glow(
              left: 90,
              top: _kDeskTop - 6,
              width: 190,
              height: 120,
              color: const Color(0xFFA855F7),
              opacity: 0.16 * neonOn,
            ),
            _glow(
              left: -50,
              top: _kDeskTop - 10,
              width: 180,
              height: 200,
              color: const Color(0xFFFFB300),
              opacity: 0.14 * spillT,
            ),

            // 4. Framed neon sign
            Positioned(
              top: 30,
              left: 36,
              right: 36,
              child: _reveal(
                t: signT,
                dy: -18,
                from: 0.9,
                child: _buildFramedWallSign(neon, neonOn),
              ),
            ),

            // 5. Headphones on stand
            _shadow(
              left: _kPanelW - 34 - 100,
              top: _kDeskTop - 6,
              width: 100,
              height: 16,
              opacity: 0.8 * headT.clamp(0.0, 1.0).toDouble(),
              sigma: 4,
            ),
            Positioned(
              top: 132,
              right: 34,
              width: 96,
              height: 120,
              child: _reveal(
                t: headT,
                dy: -22,
                child: CustomPaint(painter: _HeadphonesPainter(neon)),
              ),
            ),

            // 6. Plant + pen cup
            _shadow(
              left: 22,
              top: _kDeskTop + 4,
              width: 122,
              height: 16,
              opacity: 0.8 * plantT,
              sigma: 4,
            ),
            Positioned(
              top: 192,
              left: 30,
              child: _reveal(
                t: plantT,
                dy: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 64,
                      child: CustomPaint(painter: _PlantPainter()),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 40,
                      height: 64,
                      child: CustomPaint(painter: _PenCupPainter()),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Stacked books
            _shadow(
              left: 18,
              top: 384,
              width: 244,
              height: 26,
              opacity: 0.85 * bookT(3).clamp(0.0, 1.0).toDouble(),
              sigma: 7,
            ),
            Positioned(
              top: 292,
              left: 24,
              right: 24,
              child: _buildStackedBooks(bookT),
            ),
          ],
        );
      },
    );
  }

  // ── FRAMED NEON SIGN ────────────────────────────────────────────
  Widget _buildFramedWallSign(double neon, double neonOn) {
    TextStyle neonStyle(Color core, Color glow, double size) {
      final c = Color.lerp(const Color(0xFF3A4060), core, neonOn)!;
      return AppTextStyles.mono(
        size: size,
        color: c,
        weight: FontWeight.w800,
        letterSpacing: 1.2,
      ).copyWith(
        shadows: [
          Shadow(color: glow.withOpacity(0.95 * neon), blurRadius: 4),
          Shadow(color: glow.withOpacity(0.75 * neon), blurRadius: 12),
          Shadow(color: glow.withOpacity(0.45 * neon), blurRadius: 24),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // hanging wires + nail
        SizedBox(
          height: 14,
          width: double.infinity,
          child: CustomPaint(painter: _WirePainter()),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A3F55), Color(0xFF14172A), Color(0xFF262B40)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.75),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.16 * neon),
                blurRadius: 26,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: const Color(0xFF080A15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Good Code',
                        style: neonStyle(
                            const Color(0xFFFFFFFF), const Color(0xFF38BDF8), 11.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Better Tomorrow',
                        style: neonStyle(
                            const Color(0xFFF3E8FF), const Color(0xFFA855F7), 11.5),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF38BDF8)
                                .withOpacity(0.25 + 0.75 * neon),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8)
                                  .withOpacity(0.55 * neon),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          '</>',
                          style: neonStyle(const Color(0xFFE0F2FE),
                              const Color(0xFF38BDF8), 13),
                        ),
                      ),
                    ],
                  ),
                ),
                // glass glare
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── BOOKS ───────────────────────────────────────────────────────
  Widget _buildStackedBooks(double Function(int) bookT) {
    final books = <_BookSpec>[
      _BookSpec('BUILD', const Color(0xFF4338CA), 196, 25, 6, -0.008),
      _BookSpec('LEARN', const Color(0xFF0D9488), 208, 25, -8, 0.006),
      _BookSpec('IMPROVE', const Color(0xFFC2700A), 200, 27, 4, -0.004),
      _BookSpec('REPEAT', const Color(0xFF7E22CE), 214, 28, -2, 0.0),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < books.length; i++)
          _reveal(
            t: bookT(i),
            dy: -46,
            child: Transform.translate(
              offset: Offset(books[i].dx, 0),
              child: Transform.rotate(
                angle: books[i].tilt,
                child: _book(books[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _book(_BookSpec b) {
    final gold = const Color(0xFFF5E2A8);
    return SizedBox(
      width: b.width,
      height: b.height,
      child: Stack(
        children: [
          // cloth spine with cylindrical shading (lit from the left)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _dark(b.color, 0.45),
                    _light(b.color, 0.12),
                    b.color,
                    _dark(b.color, 0.40),
                  ],
                  stops: const [0.0, 0.16, 0.62, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // top cover board edge + highlight
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
                color: _dark(b.color, 0.25),
              ),
            ),
          ),
          Positioned(
            left: 3,
            right: 3,
            top: 0.8,
            height: 1,
            child: ColoredBox(color: Colors.white.withOpacity(0.28)),
          ),
          // bottom cover board edge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(3)),
                color: _dark(b.color, 0.55),
              ),
            ),
          ),
          // gold bands
          for (final x in [14.0, b.width - 15])
            Positioned(
              left: x,
              top: 3,
              bottom: 3,
              width: 1.6,
              child: ColoredBox(color: gold.withOpacity(0.65)),
            ),
          for (final x in [18.0, b.width - 19])
            Positioned(
              left: x,
              top: 3,
              bottom: 3,
              width: 0.8,
              child: ColoredBox(color: gold.withOpacity(0.4)),
            ),
          // embossed title
          Positioned.fill(
            child: Center(
              child: Text(
                b.title,
                style: AppTextStyles.mono(
                  size: 10,
                  color: gold,
                  weight: FontWeight.w800,
                  letterSpacing: 2.2,
                ).copyWith(
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0, 1),
                      blurRadius: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookSpec {
  final String title;
  final Color color;
  final double width;
  final double height;
  final double dx;
  final double tilt;
  _BookSpec(this.title, this.color, this.width, this.height, this.dx, this.tilt);
}

// ── Sign hanging wires ───────────────────────────────────────────
class _WirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final p = Paint()
      ..color = const Color(0xFF8A94AB).withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, 1), Offset(cx - size.width * 0.32, size.height), p);
    canvas.drawLine(Offset(cx, 1), Offset(cx + size.width * 0.32, size.height), p);
    canvas.drawCircle(Offset(cx, 2), 2.4, Paint()..color = const Color(0xFFB0B8CC));
    canvas.drawCircle(
        Offset(cx - 0.6, 1.4), 0.8, Paint()..color = Colors.white.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Studio headphones on a stand ─────────────────────────────────
class _HeadphonesPainter extends CustomPainter {
  final double glow;
  _HeadphonesPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // stand base
    final baseRect = Rect.fromCenter(center: Offset(cx, h - 5), width: 58, height: 10);
    canvas.drawOval(
      baseRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
        ).createShader(baseRect),
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, h - 6), width: 56, height: 8),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.18),
    );

    // stand stem
    final stem = Rect.fromLTWH(cx - 2.5, 10, 5, h - 14);
    canvas.drawRect(
      stem,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF94A3B8), Color(0xFF334155), Color(0xFF1E293B)],
        ).createShader(stem),
    );

    // headband (outer dark band + padded top + lamp highlight)
    final bandRect = Rect.fromLTWH(9, 5, w - 18, 86);
    canvas.drawArc(
      bandRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF111827),
    );
    canvas.drawArc(
      bandRect.deflate(0.5),
      math.pi * 1.28,
      math.pi * 0.44,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF1F2738),
    );
    canvas.drawArc(
      bandRect.translate(0, -1.5),
      math.pi * 1.05,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFFFB74D).withOpacity(0.35),
    );

    // earcups
    for (final left in [true, false]) {
      final ex = left ? 3.0 : w - 3 - 22;
      final cup = RRect.fromRectAndRadius(
        Rect.fromLTWH(ex, 38, 22, 40),
        const Radius.circular(10),
      );
      // yoke
      canvas.drawLine(
        Offset(left ? 12 : w - 12, 44),
        Offset(left ? 12 : w - 12, 52),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      // shadow
      canvas.drawRRect(
        cup.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withOpacity(0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // body
      canvas.drawRRect(
        cup,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: left
                ? const [Color(0xFF2E374E), Color(0xFF111726), Color(0xFF0A0D18)]
                : const [Color(0xFF1B2236), Color(0xFF0E1220), Color(0xFF080A14)],
          ).createShader(cup.outerRect),
      );
      // accent ring (LED)
      final ring = Rect.fromCenter(
          center: cup.center, width: 13, height: 24);
      canvas.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFFA855F7).withOpacity(0.35 + 0.55 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.6),
      );
      // cushion edge toward the inside
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left ? ex + 18 : ex - 1.5, 42, 5.5, 32),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF05070D),
      );
      // lamp-lit edge on the left side
      canvas.drawLine(
        Offset(ex + 1.6, 46),
        Offset(ex + 1.6, 70),
        Paint()
          ..color = const Color(0xFFFFB74D).withOpacity(left ? 0.38 : 0.16)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeadphonesPainter old) => old.glow != glow;
}

// ── Succulent in a ceramic pot ───────────────────────────────────
class _PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // pot
    final pot = Path()
      ..moveTo(9, 36)
      ..lineTo(w - 9, 36)
      ..lineTo(w - 13, 61)
      ..quadraticBezierTo(w / 2, 66, 13, 61)
      ..close();
    final potRect = Rect.fromLTWH(9, 36, w - 18, 30);
    canvas.drawPath(
      pot,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE9E3D8),
            Color(0xFFB4ADA2),
            Color(0xFF8A847B),
          ],
          stops: [0.0, 0.3, 0.75, 1.0],
        ).createShader(potRect),
    );

    // rim + soil
    final rim = Rect.fromLTWH(7, 32, w - 14, 9);
    canvas.drawOval(rim, Paint()..color = const Color(0xFFF1ECE3));
    canvas.drawOval(
      rim.deflate(1.6),
      Paint()..color = const Color(0xFF2A1B10),
    );

    // leaves (back to front)
    void leaf(double deg, double len, double wd, Color a, Color b) {
      canvas.save();
      canvas.translate(w / 2, 36);
      canvas.rotate(deg * math.pi / 180);
      final r = Rect.fromCenter(center: Offset(0, -len / 2), width: wd, height: len);
      canvas.drawOval(
        r,
        Paint()
          ..shader = LinearGradient(colors: [a, b, _dark(b, 0.35)])
              .createShader(r),
      );
      canvas.drawLine(
        Offset(0, -2),
        Offset(0, -len + 3),
        Paint()
          ..color = Colors.white.withOpacity(0.18)
          ..strokeWidth = 0.7,
      );
      canvas.restore();
    }

    const dark = Color(0xFF15803D);
    const mid = Color(0xFF22A058);
    const lite = Color(0xFF4ADE80);
    for (final d in [-72.0, 72.0]) {
      leaf(d, 22, 9, dark, dark);
    }
    for (final d in [-48.0, 48.0]) {
      leaf(d, 25, 10, mid, dark);
    }
    for (final d in [-24.0, 24.0]) {
      leaf(d, 27, 10.5, lite, mid);
    }
    leaf(0, 29, 11, lite, mid);
    leaf(-10, 17, 8, lite, mid);
    leaf(12, 16, 8, lite, mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Mesh pen cup with pens ───────────────────────────────────────
class _PenCupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // pens (behind the front of the cup)
    void pen(double deg, Color c) {
      canvas.save();
      canvas.translate(w / 2, 40);
      canvas.rotate(deg * math.pi / 180);
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(-1.7, -36, 3.4, 36),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(body, Paint()..color = c);
      canvas.drawRect(
        const Rect.fromLTWH(-1.7, -36, 1.1, 36),
        Paint()..color = Colors.white.withOpacity(0.28),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-1.7, -38.5, 3.4, 3),
        Paint()..color = const Color(0xFF9CA3AF),
      );
      canvas.restore();
    }

    pen(-16, const Color(0xFF0284C7));
    pen(4, const Color(0xFF64748B));
    pen(18, const Color(0xFFE11D48));

    // cup body
    final body = Path()
      ..moveTo(5, 28)
      ..lineTo(w - 5, 28)
      ..lineTo(w - 7, 58)
      ..quadraticBezierTo(w / 2, 63, 7, 58)
      ..close();
    final bodyRect = Rect.fromLTWH(5, 28, w - 10, 36);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3B465C), Color(0xFF151B2A), Color(0xFF0A0E18)],
        ).createShader(bodyRect),
    );

    // mesh
    canvas.save();
    canvas.clipPath(body);
    final mesh = Paint()
      ..color = const Color(0xFF64748B).withOpacity(0.55)
      ..strokeWidth = 0.7;
    for (double i = -40; i < 80; i += 4.5) {
      canvas.drawLine(Offset(i, 28), Offset(i + 36, 66), mesh);
      canvas.drawLine(Offset(i + 36, 28), Offset(i, 66), mesh);
    }
    // lamp-lit left edge
    canvas.drawRect(
      Rect.fromLTWH(5, 28, 4, 36),
      Paint()..color = const Color(0xFFFFB74D).withOpacity(0.18),
    );
    canvas.restore();

    // rim
    canvas.drawOval(
      Rect.fromLTWH(5, 24, w - 10, 8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF94A3B8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}