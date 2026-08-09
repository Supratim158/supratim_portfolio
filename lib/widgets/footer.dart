import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Footer widget matching the DEV_CORE design.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.contentPadding(context),
        vertical: 32,
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
        const SizedBox(width: 24),
        // Back to top
        _backToTop(context),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      children: [
        Text(AppConstants.brandName, style: AppTextStyles.brand.copyWith(fontSize: 14)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialLink('GitHub', AppConstants.githubUrl),
            _socialLink('LinkedIn', AppConstants.linkedinUrl),
            _socialLink('Instagram', AppConstants.instagramUrl),
          ],
        ),
        const SizedBox(height: 20),
        Text(AppConstants.copyright, style: AppTextStyles.footer.copyWith(fontSize: 10)),
        const SizedBox(height: 12),
        _backToTop(context),
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
        // Scroll to top
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
