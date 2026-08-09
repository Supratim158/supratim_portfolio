import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top navigation bar matching the DEV_CORE design.
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

    if (isMobile) {
      // Mobile: simplified top bar with just the brand
      return Container(
        height: AppConstants.navHeight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.navBg.withOpacity(0.95),
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(AppConstants.brandName, style: AppTextStyles.brand.copyWith(fontSize: 14)),
            const Spacer(),
            _buildResumeButton(),
          ],
        ),
      );
    }

    // Desktop / Tablet navigation
    return Container(
      height: AppConstants.navHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.contentPadding(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.navBg.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Row(
            children: [
              // Brand
              Text(AppConstants.brandName, style: AppTextStyles.brand),
              const Spacer(),
              // Nav items
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
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
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
        side: const BorderSide(color: AppColors.borderLight),
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
