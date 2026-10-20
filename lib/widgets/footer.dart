import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Footer widget with brand, social links, copyright, back-to-top,
/// and compact bottom-right PREV / NEXT page navigation buttons.
class AppFooter extends StatelessWidget {
  final int? currentPageIndex;

  const AppFooter({
    super.key,
    this.currentPageIndex,
  });

  static const List<String> _routes = [
    '/home',
    '/about',
    '/stack',
    '/metrics',
    '/work',
    '/contact',
  ];

  int? _resolveCurrentIndex(BuildContext context) {
    if (currentPageIndex != null) return currentPageIndex;
    try {
      final loc = GoRouterState.of(context).uri.path;
      final idx = _routes.indexOf(loc);
      if (idx != -1) return idx;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.contentPadding(context),
        vertical: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: isMobile ? _buildMobileFooter(context) : _buildDesktopFooter(context),
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    final nav = _buildNavControls(context);

    return Row(
      children: [
        // Brand
        Text(AppConstants.brandName, style: AppTextStyles.brand),
        const Spacer(),
        // Social links
        _socialLink('GitHub', AppConstants.githubUrl),
        _socialLink('LinkedIn', AppConstants.linkedinUrl),
        _socialLink('Instagram', AppConstants.instagramUrl),
        const Spacer(),
        // Copyright
        Text(AppConstants.copyright, style: AppTextStyles.footer),
        const SizedBox(width: 20),
        // Back to top
        _backToTop(context),
        if (nav != null) ...[
          const SizedBox(width: 18),
          nav,
        ],
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    final nav = _buildNavControls(context);

    return Column(
      children: [
        Text(AppConstants.brandName, style: AppTextStyles.brand.copyWith(fontSize: 14)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialLink('GitHub', AppConstants.githubUrl),
            _socialLink('LinkedIn', AppConstants.linkedinUrl),
            _socialLink('Instagram', AppConstants.instagramUrl),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppConstants.copyright, style: AppTextStyles.footer.copyWith(fontSize: 10)),
            _backToTop(context),
          ],
        ),
      ],
    );
  }

  Widget? _buildNavControls(BuildContext context) {
    final idx = _resolveCurrentIndex(context);
    if (idx == null || idx < 0 || idx >= _routes.length) return null;

    final hasPrev = idx > 0;
    final hasNext = idx < _routes.length - 1;

    if (!hasPrev && !hasNext) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPrev)
          _FooterNavButton(
            isNext: false,
            onTap: () => context.go(_routes[idx - 1]),
          ),
        if (hasPrev && hasNext) const SizedBox(width: 8),
        if (hasNext)
          _FooterNavButton(
            isNext: true,
            onTap: () => context.go(_routes[idx + 1]),
          ),
      ],
    );
  }

  Widget _socialLink(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          label,
          style: AppTextStyles.footer.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _backToTop(BuildContext context) {
    return InkWell(
      onTap: () {
        final scrollable = Scrollable.maybeOf(context);
        scrollable?.position.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppStrings.backToTop, style: AppTextStyles.footer),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_upward, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Compact, elegant footer navigation button with no page names and minimal padding.
class _FooterNavButton extends StatefulWidget {
  final bool isNext;
  final VoidCallback onTap;

  const _FooterNavButton({
    required this.isNext,
    required this.onTap,
  });

  @override
  State<_FooterNavButton> createState() => _FooterNavButtonState();
}

class _FooterNavButtonState extends State<_FooterNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primary.withOpacity(0.18)
                : AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryLight.withOpacity(0.7)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isNext) ...[
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 10,
                  color: _isHovered ? AppColors.primaryLight : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                widget.isNext ? 'NEXT' : 'PREV',
                style: AppTextStyles.mono(
                  size: 9.5,
                  weight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: _isHovered ? AppColors.primaryLight : AppColors.textSecondary,
                ),
              ),
              if (widget.isNext) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: _isHovered ? AppColors.primaryLight : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
