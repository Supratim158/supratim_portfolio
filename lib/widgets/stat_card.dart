import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'glass_card.dart';
import 'shimmer_loader.dart';

/// Stat card showing an icon, label, large number, and description.
/// Used on the About and Metrics pages.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String description;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryLight, size: 20),
                const Spacer(),
                Text(
                  label,
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            value == '...'
                ? const ShimmerLoader(width: 80, height: 28)
                : Text(value, style: AppTextStyles.statNumber),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.mono(
                size: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
