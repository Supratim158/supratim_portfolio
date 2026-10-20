import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Scattered, project-related animated objects in the left and right margins.
/// - Upon opening the page, they animate in from each side with a generous, clearly visible duration.
/// - After the entrance animation completes, all objects remain STILL.
/// - Objects are scattered across varied horizontal offsets and angles (not in a straight line).
/// - Objects represent real project components (Mobile App, AI Assistant, Web Portal, Offline GPS, Database, Cloud, Sockets).
class SideAnimatedObjects extends StatefulWidget {
  final bool isLeft;
  final double viewportHeight;

  const SideAnimatedObjects({
    super.key,
    required this.isLeft,
    required this.viewportHeight,
  });

  @override
  State<SideAnimatedObjects> createState() => _SideAnimatedObjectsState();
}

class _SideAnimatedObjectsState extends State<SideAnimatedObjects>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    // Generous duration (~2.8 seconds) so the user can clearly see each object glide in
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Start animation shortly after build
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        final progress = _entranceController.value;

        return SizedBox(
          height: widget.viewportHeight,
          width: 320,
          child: Stack(
            clipBehavior: Clip.none,
            children: widget.isLeft
                ? _buildLeftScatteredObjects(progress)
                : _buildRightScatteredObjects(progress),
          ),
        );
      },
    );
  }

  // ── LEFT SCATTERED OBJECTS (varied offsets & rotations) ─────────
  List<Widget> _buildLeftScatteredObjects(double progress) {
    return [
      // 1. Mobile App Preview (Sanctuary Social App)
      _scatteredPositioned(
        top: 24,
        left: 15,
        rotation: -0.04,
        index: 0,
        progress: progress,
        child: _buildSanctuaryCard(),
      ),

      // 2. Offline Survival & GPS Navigator Widget
      _scatteredPositioned(
        top: 140,
        left: 55, // indented inwards (scattered!)
        rotation: 0.03,
        index: 1,
        progress: progress,
        child: _buildGpsNavigatorCard(),
      ),

      // 3. Database & Cloud Storage Node
      _scatteredPositioned(
        top: 250,
        left: 8, // shifted outwards
        rotation: -0.02,
        index: 2,
        progress: progress,
        child: _buildDatabaseNodeCard(),
      ),

      // 4. Mobile SDK & IoT Chip
      _scatteredPositioned(
        top: 350,
        left: 45, // indented inwards
        rotation: 0.04,
        index: 3,
        progress: progress,
        child: _buildSdkChip(),
      ),
    ];
  }

  // ── RIGHT SCATTERED OBJECTS (varied offsets & rotations) ────────
  List<Widget> _buildRightScatteredObjects(double progress) {
    return [
      // 1. TYSON AI Voice Assistant with mini visualizer bars
      _scatteredPositioned(
        top: 30,
        right: 40, // indented inwards (scattered!)
        rotation: 0.04,
        index: 0,
        progress: progress,
        child: _buildTysonAiCard(),
      ),

      // 2. ProjexHub Showcase Portal Card
      _scatteredPositioned(
        top: 145,
        right: 10, // shifted outwards
        rotation: -0.03,
        index: 1,
        progress: progress,
        child: _buildProjexHubCard(),
      ),

      // 3. Socket.IO Real-time Engine
      _scatteredPositioned(
        top: 255,
        right: 50, // indented inwards
        rotation: 0.03,
        index: 2,
        progress: progress,
        child: _buildSocketIoCard(),
      ),

      // 4. JWT & Security Shield
      _scatteredPositioned(
        top: 355,
        right: 15, // shifted outwards
        rotation: -0.02,
        index: 3,
        progress: progress,
        child: _buildSecurityShieldCard(),
      ),
    ];
  }

  // ── POSITIONED HELPER WITH STAGGERED SWOOP ANIMATION ───────────
  Widget _scatteredPositioned({
    required double top,
    double? left,
    double? right,
    required double rotation,
    required int index,
    required double progress,
    required Widget child,
  }) {
    // Stagger each item across the 2.8s duration
    final start = (index * 0.18).clamp(0.0, 0.65);
    final end = (start + 0.38).clamp(0.0, 1.0);
    final itemProgress = ((progress - start) / (end - start)).clamp(0.0, 1.0);

    // Smooth overshoot curve for clear, delightful entrance
    final curved = Curves.easeOutBack.transform(itemProgress);

    // Initial off-screen translation
    final offscreenDistance = widget.isLeft ? -320.0 : 320.0;
    final translateX = offscreenDistance * (1.0 - curved);

    // Notice: NO continuous floating! Once itemProgress reaches 1.0, it is 100% STILL!
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: itemProgress,
        child: Transform(
          transform: Matrix4.identity()
            ..translate(translateX, 0.0, 0.0)
            ..rotateZ(rotation * curved),
          child: child,
        ),
      ),
    );
  }

  // ── PROJECT-RELATED CARDS (LEFT SIDE) ──────────────────────────

  // 1. Mobile App Preview Card (Sanctuary Social App)
  Widget _buildSanctuaryCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF6366F1), // Indigo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_iphone_rounded,
                  size: 15,
                  color: Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MOBILE APP',
                    style: AppTextStyles.mono(
                      size: 8,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Sanctuary Social',
                    style: AppTextStyles.mono(
                      size: 11,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tagPill('Flutter'),
              const SizedBox(width: 4),
              _tagPill('Node.js'),
              const SizedBox(width: 6),
              const Icon(Icons.favorite_rounded, size: 11, color: Color(0xFFEC4899)),
              const SizedBox(width: 2),
              Text(
                'Live Feed',
                style: AppTextStyles.mono(size: 9, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Offline Survival & GPS Navigator
  Widget _buildGpsNavigatorCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF10B981), // Emerald
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.explore_rounded,
              size: 18,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GPS OFFLINE SYNC',
                    style: AppTextStyles.mono(
                      size: 8,
                      color: const Color(0xFF34D399),
                      weight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Survival Companion',
                style: AppTextStyles.mono(
                  size: 11,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '22.57° N · 88.36° E',
                style: AppTextStyles.mono(
                  size: 9,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Database & Cloud Storage Node
  Widget _buildDatabaseNodeCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF06B6D4), // Cyan
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dns_rounded,
              size: 15,
              color: Color(0xFF22D3EE),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DATABASE CLUSTER',
                style: AppTextStyles.mono(
                  size: 8,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                  weight: FontWeight.w700,
                ),
              ),
              Text(
                'MongoDB · Cloudinary',
                style: AppTextStyles.mono(
                  size: 10,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Hardware / SDK Integration Chip
  Widget _buildSdkChip() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFFF59E0B), // Amber
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.memory_rounded, size: 14, color: Color(0xFFFBBF24)),
          const SizedBox(width: 6),
          Text(
            'CROSS-PLATFORM SDK',
            style: AppTextStyles.mono(
              size: 9,
              color: const Color(0xFFFBBF24),
              weight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── PROJECT-RELATED CARDS (RIGHT SIDE) ─────────────────────────

  // 1. TYSON AI Voice Assistant Card with Mini Equalizer
  Widget _buildTysonAiCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFFA855F7), // Purple
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 16,
                  color: Color(0xFFC084FC),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI ASSISTANT',
                    style: AppTextStyles.mono(
                      size: 8,
                      color: const Color(0xFFC084FC),
                      letterSpacing: 1.2,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'TYSON Voice Engine',
                    style: AppTextStyles.mono(
                      size: 11,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mini Equalizer soundwave visualizer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _soundBar(12, const Color(0xFFA855F7)),
              const SizedBox(width: 3),
              _soundBar(18, const Color(0xFFC084FC)),
              const SizedBox(width: 3),
              _soundBar(14, const Color(0xFF818CF8)),
              const SizedBox(width: 3),
              _soundBar(22, const Color(0xFF38BDF8)),
              const SizedBox(width: 3),
              _soundBar(10, const Color(0xFFC084FC)),
              const SizedBox(width: 8),
              Text(
                'Speech-to-Action',
                style: AppTextStyles.mono(size: 9, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _soundBar(double height, Color color) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // 2. ProjexHub Showcase Portal Card
  Widget _buildProjexHubCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF3B82F6), // Blue
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              size: 16,
              color: Color(0xFF60A5FA),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WEB PLATFORM',
                style: AppTextStyles.mono(
                  size: 8,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                  weight: FontWeight.w700,
                ),
              ),
              Text(
                'ProjexHub Portal V2',
                style: AppTextStyles.mono(
                  size: 11,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Project Publishing & Review',
                style: AppTextStyles.mono(
                  size: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Socket.IO Live Engine
  Widget _buildSocketIoCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF10B981), // Emerald
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              size: 15,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SOCKET.IO ENGINE',
                    style: AppTextStyles.mono(
                      size: 8,
                      color: const Color(0xFF34D399),
                      weight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '<12ms',
                      style: AppTextStyles.mono(size: 8, color: const Color(0xFF34D399)),
                    ),
                  ),
                ],
              ),
              Text(
                'Live Notifications & Chat',
                style: AppTextStyles.mono(
                  size: 10,
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Security & JWT Shield
  Widget _buildSecurityShieldCard() {
    return _ScatteredGlassCard(
      accentColor: const Color(0xFF818CF8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF818CF8)),
          const SizedBox(width: 6),
          Text(
            'JWT AUTH & REST API',
            style: AppTextStyles.mono(
              size: 9,
              color: const Color(0xFF818CF8),
              weight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.mono(size: 8, color: AppColors.textMuted),
      ),
    );
  }
}

/// Frosted glass container for scattered objects with subtle glowing border.
class _ScatteredGlassCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const _ScatteredGlassCard({
    required this.child,
    required this.accentColor,
  });

  @override
  State<_ScatteredGlassCard> createState() => _ScatteredGlassCardState();
}

class _ScatteredGlassCardState extends State<_ScatteredGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFF161F36).withOpacity(0.92)
              : const Color(0xFF0E1424).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withOpacity(0.7)
                : widget.accentColor.withOpacity(0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            if (_isHovered)
              BoxShadow(
                color: widget.accentColor.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
