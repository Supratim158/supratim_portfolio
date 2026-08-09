import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Most active repositories list.
class RepoListItem extends StatelessWidget {
  final String name;
  final String description;
  final String version;
  final int stars;
  final int forks;

  const RepoListItem({
    super.key,
    required this.name,
    required this.description,
    this.version = '',
    this.stars = 0,
    this.forks = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.mono(size: 14, weight: FontWeight.w600, color: AppColors.textPrimary)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(description, style: AppTextStyles.mono(size: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          if (version.isNotEmpty) ...[
            Text(version, style: AppTextStyles.mono(size: 10, color: AppColors.textMuted)),
            const SizedBox(width: 12),
          ],
          const Icon(Icons.star_border, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text('$stars', style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          const Icon(Icons.call_split, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text('$forks', style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
