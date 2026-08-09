import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/footer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/pull_to_reload.dart';
import '../../widgets/glass_card.dart';
import '../../animations/section_reveal.dart';
import '../../models/project.dart';
import '../../models/project_data.dart';

/// Detail page for an individual project.
class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final project = findProjectById(projectId);

    if (project == null) {
      return _buildNotFound(context, isMobile);
    }

    final body = PullToReload(
      child: Column(
        children: [
          const NavBar(currentIndex: 4),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 24 : 48),
                  _buildBreadcrumb(context, project, isMobile),
                  SizedBox(height: isMobile ? 24 : 40),
                  _buildHero(context, project, isMobile),
                  SizedBox(height: isMobile ? 32 : 56),
                  _buildContent(context, project, isMobile),
                  SizedBox(height: isMobile ? 40 : 80),
                  const AppFooter(),
                  if (isMobile) const SizedBox(height: AppBottomNavBar.totalHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile
          ? AppBottomNavBar.wrapWithFloatingNav(body: body, currentIndex: 4)
          : body,
    );
  }

  Widget _buildNotFound(BuildContext context, bool isMobile) {
    final notFoundBody = Column(
      children: [
        const NavBar(currentIndex: 4),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.4)),
                const SizedBox(height: 20),
                Text('Project not found', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                Text(
                  'The project you\'re looking for doesn\'t exist.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 32),
                InkWell(
                  onTap: () => context.go('/work'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text('← Back to Projects', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile
          ? AppBottomNavBar.wrapWithFloatingNav(body: notFoundBody, currentIndex: 4)
          : notFoundBody,
    );
  }

  Widget _buildBreadcrumb(BuildContext context, Project project, bool isMobile) {
    return ContentWrapper(
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/work'),
            borderRadius: BorderRadius.circular(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'ALL PROJECTS',
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('/', style: AppTextStyles.mono(size: 11, color: AppColors.textDark)),
          ),
          Flexible(
            child: Text(
              project.title.toUpperCase(),
              style: AppTextStyles.mono(
                size: 11,
                color: AppColors.primaryLight,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Project project, bool isMobile) {
    return ContentWrapper(
      child: SectionReveal(
        child: GlassCard(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(context, project),
                    const SizedBox(height: 24),
                    _buildHeroInfo(project, isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildHeroImage(context, project),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 5,
                      child: _buildHeroInfo(project, isMobile),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, Project project) {
    if (project.imagePath == null && project.imageUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.cardBg,
                AppColors.primaryDim.withOpacity(0.3),
              ],
            ),
          ),
          child: _imageplaceholder(),
        ),
      );
    }

    final imageWidget = project.imagePath != null
        ? Image.asset(
            project.imagePath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _imageplaceholder(),
          )
        : Image.network(
            project.imageUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _imageplaceholder(),
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openImageFullScreen(context, project),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            width: double.infinity,
            color: AppColors.surface.withOpacity(0.5),
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  void _openImageFullScreen(BuildContext context, Project project) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Zoomable Image
              Center(
                child: InteractiveViewer(
                  maxScale: 4.0,
                  minScale: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: project.imagePath != null
                        ? Image.asset(project.imagePath!)
                        : Image.network(project.imageUrl!),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: Material(
                    color: Colors.black.withOpacity(0.5),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageplaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 56, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            'PROJECT PREVIEW',
            style: AppTextStyles.mono(size: 10, color: AppColors.textDark, letterSpacing: 2),
          ),
        ],
      ),
    );
  }


  Widget _buildHeroInfo(Project project, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusColor(project).withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _statusColor(project).withOpacity(0.3)),
          ),
          child: Text(
            project.status.toUpperCase(),
            style: AppTextStyles.mono(
              size: 10,
              color: _statusColor(project),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          project.title,
          style: isMobile ? AppTextStyles.sectionTitleMobile : AppTextStyles.sectionTitle,
        ),
        if (project.tagline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(project.tagline, style: AppTextStyles.subtitle),
        ],
        const SizedBox(height: 16),
        // Description
        Text(project.description, style: AppTextStyles.body),
        const SizedBox(height: 20),
        // Tech stack
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: project.techStack.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(tag, style: AppTextStyles.mono(size: 10, color: AppColors.textMuted)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Meta info row
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            if (project.role != null) _metaItem(Icons.person_outline_rounded, project.role!),
            if (project.duration != null) _metaItem(Icons.schedule_rounded, project.duration!),
          ],
        ),
        const SizedBox(height: 24),
        // Action buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (project.githubUrl != null)
              _heroButton(
                icon: Icons.code_rounded,
                label: 'OPEN GITHUB',
                isPrimary: false,
                onTap: () async {
                  final uri = Uri.parse(project.githubUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            if (project.liveUrl != null && project.liveUrl!.isNotEmpty)
              _heroButton(
                icon: Icons.open_in_new_rounded,
                label: 'LIVE DEMO',
                isPrimary: true,
                onTap: () async {
                  final uri = Uri.parse(project.liveUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _metaItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(value, style: AppTextStyles.mono(size: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _heroButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryMuted.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isPrimary ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isPrimary ? AppColors.primaryLight : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 11,
                color: isPrimary ? AppColors.primaryLight : AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Project project, bool isMobile) {
    return ContentWrapper(
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.longDescription.isNotEmpty) ...[
                  _buildAboutSection(project),
                  const SizedBox(height: 32),
                ],
                if (project.features.isNotEmpty) _buildFeaturesSection(project),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.longDescription.isNotEmpty)
                  Expanded(
                    flex: 6,
                    child: _buildAboutSection(project),
                  ),
                if (project.longDescription.isNotEmpty && project.features.isNotEmpty)
                  const SizedBox(width: 40),
                if (project.features.isNotEmpty)
                  Expanded(
                    flex: 4,
                    child: _buildFeaturesSection(project),
                  ),
              ],
            ),
    );
  }

  Widget _buildAboutSection(Project project) {
    return SectionReveal(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ABOUT THIS PROJECT',
                  style: AppTextStyles.mono(
                    size: 12,
                    color: AppColors.primaryLight,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              project.longDescription,
              style: AppTextStyles.body.copyWith(height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(Project project) {
    return SectionReveal(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'KEY FEATURES',
                  style: AppTextStyles.mono(
                    size: 12,
                    color: AppColors.success,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...project.features.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.body.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _statusColor(Project project) {
    switch (project.status.toLowerCase()) {
      case 'in progress':
        return AppColors.warning;
      case 'maintained':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }
}
