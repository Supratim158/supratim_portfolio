import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Floating glassmorphic top navigation bar.
class NavBar extends ConsumerWidget {
  final int currentIndex;

  const NavBar({super.key, required this.currentIndex});

  static const _routes = [
    '/home',
    '/about',
    '/stack',
    '/metrics',
    '/work',
    '/contact',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    final content = isMobile
        ? Row(
            children: [
              Text(
                AppConstants.brandName,
                style: AppTextStyles.brand.copyWith(fontSize: 14),
              ),
              const Spacer(),
              _buildResumeButton(),
            ],
          )
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Row(
                children: [
                  Text(AppConstants.brandName, style: AppTextStyles.brand),
                  const Spacer(),
                  ...List.generate(AppStrings.navItems.length, (i) {
                    final isActive = i == currentIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _NavItem(
                        label: AppStrings.navItems[i],
                        isActive: isActive,
                        onTap: () => context.go(_routes[i]),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  _buildResumeButton(),
                ],
              ),
            ),
          );

    // Outer padding makes the bar "float" away from the screen edges.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 24,
        isMobile ? 10 : 16,
        isMobile ? 12 : 24,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth + 80,
          ),
          child: _GlassContainer(
            height: AppConstants.navHeight,
            borderRadius: isMobile ? 18 : 24,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 28,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    return OutlinedButton(
      onPressed: () async {
        final uri = Uri.parse(AppConstants.resumeUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.06),
        side: BorderSide(color: Colors.white.withOpacity(0.18)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        'Resume',
        style: AppTextStyles.navItem.copyWith(fontSize: 13),
      ),
    );
  }
}

/// Reusable frosted-glass container.
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({
    required this.child,
    required this.height,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        // Soft shadow lifts the bar off the content
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              // Translucent gradient fill = the "glass"
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              // Thin light border for the glass edge highlight
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? AppColors.textPrimary
                    : _hovering
                        ? AppColors.textMuted
                        : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: widget.isActive
                ? AppTextStyles.navItemActive
                : AppTextStyles.navItem.copyWith(
                    color: _hovering
                        ? AppColors.textPrimary
                        : AppColors.navInactive,
                  ),
          ),
        ),
      ),
    );
  }
}