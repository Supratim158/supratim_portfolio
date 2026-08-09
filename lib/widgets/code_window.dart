import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Floating code snippet window for the hero section.
class CodeWindow extends StatelessWidget {
  final String title;
  final List<InlineSpan> codeLines;
  final String? tag;

  const CodeWindow({
    super.key,
    required this.title,
    required this.codeLines,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title bar with dots
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                _dot(AppColors.error),
                const SizedBox(width: 6),
                _dot(AppColors.warning),
                const SizedBox(width: 6),
                _dot(AppColors.success),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(14),
            child: RichText(
              text: TextSpan(children: codeLines),
            ),
          ),
          // Optional tag
          if (tag != null)
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    tag!,
                    style: AppTextStyles.mono(size: 9, color: AppColors.primaryLight, letterSpacing: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
