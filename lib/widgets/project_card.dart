import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/project.dart';
import '../animations/hover_scale.dart';
import 'glass_card.dart';

/// Project showcase card with image, title, description, tech tags, and two action buttons.
class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Project Image ───────────────────────────────
            _buildImage(),
            // ── Content ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    project.title,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.tagline.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      project.tagline,
                      style: AppTextStyles.mono(
                        size: 11,
                        color: AppColors.primaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Description
                  Text(
                    project.description,
                    style: AppTextStyles.cardDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  // Tech tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.techStack.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.border, width: 1),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.mono(
                            size: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      project.status.toUpperCase(),
                      style: AppTextStyles.mono(
                        size: 9,
                        color: _statusColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Action Buttons ──────────────────────────
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (project.status.toLowerCase()) {
      case 'in progress':
        return AppColors.warning;
      case 'maintained':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 160,
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
        child: project.imagePath != null
            ? Image.asset(
                project.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              )
            : project.imageUrl != null
                ? Image.network(
                    project.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
      ),
    );
  }

  Widget _placeholderImage() {
    return Center(
      child: Icon(
        Icons.folder_outlined,
        size: 48,
        color: AppColors.textMuted.withOpacity(0.4),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // View Details button
        Expanded(
          child: _actionButton(
            context,
            icon: Icons.arrow_forward_rounded,
            label: 'VIEW DETAILS',
            isPrimary: true,
            onTap: () => context.go('/work/${project.id}'),
          ),
        ),
        const SizedBox(width: 10),
        // Open GitHub button
        if (project.githubUrl != null)
          Expanded(
            child: _actionButton(
              context,
              icon: Icons.code_rounded,
              label: 'GITHUB',
              isPrimary: false,
              onTap: () async {
                final uri = Uri.parse(project.githubUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryMuted.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isPrimary ? AppColors.primaryLight : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 10,
                color: isPrimary ? AppColors.primaryLight : AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
