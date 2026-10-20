import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/project.dart';

/// Project Card modeled directly after the user's reference image (Image 1):
/// - Top header with index ("01"), "CLIENT" label, and top-right "LIVE PROJECT" pill button.
/// - Left side: image preview.
/// - Right side: project details, description, tech stack, and action buttons:
///   1. "VIEW DETAILS"
///   2. "LIVE DEMO" (if demo is available)
/// - Glowing glassmorphism effect with internal luminous glow and frosted blur.
class StackedProjectCard extends StatefulWidget {
  final int index;
  final Project project;
  final bool isMobile;
  final VoidCallback? onHeaderTap;

  const StackedProjectCard({
    super.key,
    required this.index,
    required this.project,
    required this.isMobile,
    this.onHeaderTap,
  });

  @override
  State<StackedProjectCard> createState() => _StackedProjectCardState();
}

class _StackedProjectCardState extends State<StackedProjectCard> {
  bool _isCardHovered = false;

  bool get _hasLiveDemo =>
      widget.project.liveUrl != null && widget.project.liveUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final indexStr = (widget.index + 1).toString().padLeft(2, '0');

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isCardHovered
                ? AppColors.primaryLight.withOpacity(0.75)
                : Colors.white.withOpacity(0.24),
            width: 1.5,
          ),
          boxShadow: [
            // Dark ambient depth shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
            // Outer glass glow
            BoxShadow(
              color: _isCardHovered
                  ? AppColors.primaryLight.withOpacity(0.28)
                  : AppColors.primary.withOpacity(0.16),
              blurRadius: _isCardHovered ? 40 : 26,
              spreadRadius: _isCardHovered ? 1 : -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ── Glowing Glassmorphism Background with Inner Glow ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF162038).withOpacity(0.92),
                        const Color(0xFF0C101F).withOpacity(0.95),
                        const Color(0xFF070B16).withOpacity(0.98),
                      ],
                    ),
                  ),
                ),
              ),
              // Inner Top-Left Luminous Glass Glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.85, -0.9),
                      radius: 1.1,
                      colors: [
                        AppColors.primaryLight.withOpacity(_isCardHovered ? 0.28 : 0.18),
                        AppColors.primary.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              // Inner Bottom-Right Cyan Accent Glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.9, 0.9),
                      radius: 0.9,
                      colors: [
                        AppColors.accent.withOpacity(_isCardHovered ? 0.18 : 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Card Content ──────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header (01 CLIENT ... [LIVE PROJECT]) ─────
                  _buildTopHeader(indexStr),

                  // ── Card Content Body (Left Image + Right Text) ───
                  Padding(
                    padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
                    child: widget.isMobile
                        ? _buildMobileContent()
                        : _buildDesktopContent(),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  // ── HEADER (01 CLIENT ... [LIVE PROJECT]) ───────────────────────
  Widget _buildTopHeader(String indexStr) {
    return InkWell(
      onTap: widget.onHeaderTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 18 : 24,
          vertical: widget.isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Big Bold Number: "01"
            Text(
              indexStr,
              style: AppTextStyles.mono(
                size: widget.isMobile ? 24 : 32,
                color: Colors.white,
                weight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 14),
            // "CLIENT" label & Project Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CLIENT',
                  style: AppTextStyles.mono(
                    size: 9,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.project.title,
                  style: AppTextStyles.mono(
                    size: widget.isMobile ? 12 : 14,
                    color: AppColors.textPrimary,
                    weight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            // Top-right pill button
            if (_hasLiveDemo)
              _buildLivePillButton()
            else
              _buildStatusPill(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePillButton() {
    return InkWell(
      onTap: () => _launchLiveDemo(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.8),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE PROJECT',
              style: AppTextStyles.mono(
                size: 10,
                color: Colors.white,
                letterSpacing: 1.2,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        widget.project.status.toUpperCase(),
        style: AppTextStyles.mono(
          size: 9,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
          weight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── DESKTOP CONTENT (Left Image + Right Text & Buttons) ────────
  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: One Image
        Expanded(
          flex: 5,
          child: _buildImageSection(height: 260),
        ),
        const SizedBox(width: 28),
        // Right: Text & Action Buttons
        Expanded(
          flex: 6,
          child: _buildDetailsColumn(),
        ),
      ],
    );
  }

  // ── MOBILE CONTENT (Image on top, Text & Buttons below) ────────
  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(height: 190),
        const SizedBox(height: 18),
        _buildDetailsColumn(),
      ],
    );
  }

  // ── IMAGE SECTION ──────────────────────────────────────────────
  Widget _buildImageSection({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.project.imagePath != null)
              Image.asset(
                widget.project.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else if (widget.project.imageUrl != null)
              Image.network(
                widget.project.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            // Subtle gradient overlay for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.cardBg,
            AppColors.primaryDim.withOpacity(0.25),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.code_rounded,
          size: 48,
          color: AppColors.textMuted.withOpacity(0.3),
        ),
      ),
    );
  }

  // ── DETAILS COLUMN (Text + Buttons) ───────────────────────────
  Widget _buildDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.project.title,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: widget.isMobile ? 18 : 22,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.project.tagline.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.project.tagline,
            style: AppTextStyles.mono(
              size: widget.isMobile ? 11 : 12,
              color: AppColors.primaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 10),
        // Description
        Text(
          widget.project.description,
          style: AppTextStyles.cardDescription.copyWith(
            fontSize: widget.isMobile ? 12 : 13,
            height: 1.5,
          ),
          maxLines: widget.isMobile ? 3 : 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        // Tech Stack Chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.project.techStack.take(5).map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                tag,
                style: AppTextStyles.mono(
                  size: 9,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // ── Action Buttons Row ───────────────────────────────
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Button 1: VIEW DETAILS
        Expanded(
          child: _btn(
            icon: Icons.arrow_forward_rounded,
            label: 'VIEW DETAILS',
            isPrimary: true,
            onTap: () => context.go('/work/${widget.project.id}'),
          ),
        ),
        const SizedBox(width: 12),
        // Button 2: LIVE DEMO (if demo is available)
        if (_hasLiveDemo) ...[
          Expanded(
            child: _btn(
              icon: Icons.open_in_new_rounded,
              label: 'LIVE DEMO',
              isPrimary: false,
              isAccent: true,
              onTap: () => _launchLiveDemo(),
            ),
          ),
        ] else if (widget.project.githubUrl != null) ...[
          // Optional source code button if no live demo
          Expanded(
            child: _btn(
              icon: Icons.code_rounded,
              label: 'GITHUB',
              isPrimary: false,
              onTap: () => _launchUrl(widget.project.githubUrl!),
            ),
          ),
        ],
      ],
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isAccent = false,
    required VoidCallback onTap,
  }) {
    final borderColor = isPrimary
        ? AppColors.primary
        : (isAccent ? AppColors.success : AppColors.border);
    final bgColor = isPrimary
        ? AppColors.primary.withOpacity(0.18)
        : (isAccent ? AppColors.success.withOpacity(0.12) : Colors.transparent);
    final textColor = isPrimary
        ? AppColors.primaryLight
        : (isAccent ? AppColors.success : AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 10 : 14,
          vertical: widget.isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.mono(
                  size: widget.isMobile ? 10 : 11,
                  color: textColor,
                  weight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchLiveDemo() async {
    if (widget.project.liveUrl != null && widget.project.liveUrl!.isNotEmpty) {
      await _launchUrl(widget.project.liveUrl!);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
