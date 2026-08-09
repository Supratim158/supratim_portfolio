import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../animations/typing_animation.dart';
import '../../../animations/floating_animation.dart';
import '../../../widgets/code_window.dart';
import '../../../widgets/interactive_coder_scene.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../providers/github_provider.dart';

/// Hero section: background typing 3D workstation scene, name, role typing, description,
/// CTA buttons, stats, and right-side floating code windows.
class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection> {
  Offset _mouseOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final screenSize = MediaQuery.sizeOf(context);

    return MouseRegion(
      onHover: (event) {
        final centerX = screenSize.width / 2;
        final centerY = screenSize.height / 2;
        setState(() {
          _mouseOffset = Offset(
            ((event.localPosition.dx - centerX) / centerX).clamp(-1.0, 1.0),
            ((event.localPosition.dy - centerY) / centerY).clamp(-1.0, 1.0),
          );
        });
      },
      onExit: (_) => setState(() => _mouseOffset = Offset.zero),
      child: Stack(
        children: [
          // Full background 3D Workstation Scene (moving with cursor)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.75, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.15,
                child: InteractiveCoderScene(
                  isBackground: true,
                  externalMouseOffset: _mouseOffset,
                ),
              ),
            ),
          ),
          // Foreground Content
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.contentPadding(context),
              vertical: isMobile ? 40 : 80,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: isMobile ? _buildMobile(context) : _buildDesktop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Text content
        Expanded(
          flex: 5,
          child: _buildTextContent(context, false),
        ),
        const SizedBox(width: 40),
        // Right: Floating code windows (the older ones)
        Expanded(
          flex: 4,
          child: _buildCodeWindows(),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(context, true),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, bool isMobile) {
    final allCommitsAsync = ref.watch(allCommitsProvider);

    // Get total commit count from /api/github/all-commits
    final commitCount = allCommitsAsync.when(
      data: (total) => total >= 1000
          ? '${(total / 1000).toStringAsFixed(1)}k'
          : '$total',
      loading: () => const ShimmerLoader(width: 60, height: 28),
      error: (_, __) => AppStrings.statCommits,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(AppStrings.heroLabel, style: AppTextStyles.sectionLabel),
        const SizedBox(height: 20),
        // Name
        Text(
          AppStrings.heroName,
          style: isMobile ? AppTextStyles.heroNameMobile : AppTextStyles.heroName,
        ),
        const SizedBox(height: 12),
        // Typing role
        RoleTypingAnimation(
          roles: AppStrings.heroRoles,
          style: AppTextStyles.heroRole.copyWith(
            fontSize: isMobile ? 16 : 20,
          ),
        ),
        const SizedBox(height: 24),
        // Description
        SizedBox(
          width: isMobile ? double.infinity : 420,
          child: Text(AppStrings.heroDescription, style: AppTextStyles.body),
        ),
        const SizedBox(height: 32),
        // CTA buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: () async {
                final uri = Uri.parse(AppConstants.resumeUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(AppStrings.downloadResume, style: AppTextStyles.button),
            ),
          ],
        ),
        const SizedBox(height: 48),
        // Stats
        Row(
          children: [
            _statItem(AppStrings.statProjects, AppStrings.statProjectsLabel),
            const SizedBox(width: 100),
            _statItem(commitCount, AppStrings.statCommitsLabel),
          ],
        ),
      ],
    );
  }

  Widget _statItem(dynamic value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        value is Widget
            ? value
            : Text(value.toString(), style: AppTextStyles.statNumber.copyWith(fontSize: 28)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }

  Widget _buildCodeWindows() {
    final commitsAsync = ref.watch(commitsProvider);

    // Get the latest commit details for the terminal window as InlineSpan
    final latestShaSpan = commitsAsync.when(
      data: (commits) => TextSpan(
        text: commits.isNotEmpty ? commits.first.sha.substring(0, 7) : '0000000',
        style: AppTextStyles.codeKeyword,
      ),
      loading: () => const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ShimmerLoader(width: 50, height: 12),
      ),
      error: (_, __) => TextSpan(
        text: '0000000',
        style: AppTextStyles.codeKeyword,
      ),
    );

    final latestMessageSpan = commitsAsync.when(
      data: (commits) => TextSpan(
        text: commits.isNotEmpty ? commits.first.message.split('\n').first : '',
        style: AppTextStyles.codeString,
      ),
      loading: () => const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ShimmerLoader(width: 100, height: 12),
      ),
      error: (_, __) => TextSpan(
        text: 'offline',
        style: AppTextStyles.codeString,
      ),
    );

    final latestRepoSpan = commitsAsync.when(
      data: (commits) => TextSpan(
        text: commits.isNotEmpty ? commits.first.repoName : 'repository',
        style: AppTextStyles.codeString,
      ),
      loading: () => const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ShimmerLoader(width: 80, height: 12),
      ),
      error: (_, __) => TextSpan(
        text: 'repository',
        style: AppTextStyles.codeString,
      ),
    );

    final statusSpan = commitsAsync.when(
      data: (_) => TextSpan(text: 'synced ✓', style: AppTextStyles.codeKeyword),
      loading: () => const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ShimmerLoader(width: 60, height: 12),
      ),
      error: (_, __) => TextSpan(
        text: 'failed',
        style: AppTextStyles.codeKeyword.copyWith(color: AppColors.error),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Code editor window
        FloatingAnimation(
          amplitude: 6,
          period: const Duration(seconds: 4),
          child: CodeWindow(
            title: 'architect.dart',
            tag: 'FLUTTER ENGINE',
            codeLines: [
              TextSpan(text: 'class ', style: AppTextStyles.codeKeyword),
              TextSpan(text: 'Architect {\n', style: AppTextStyles.code),
              TextSpan(text: '  private ', style: AppTextStyles.codeKeyword),
              TextSpan(text: 'vision: string;\n', style: AppTextStyles.code),
              TextSpan(text: '  constructor() {\n', style: AppTextStyles.code),
              TextSpan(text: '    this.vision = ', style: AppTextStyles.code),
              TextSpan(text: '"Innovation"', style: AppTextStyles.codeString),
              TextSpan(text: ';\n', style: AppTextStyles.code),
              TextSpan(text: '  }\n', style: AppTextStyles.code),
              TextSpan(text: '}', style: AppTextStyles.code),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Terminal window — shows actual latest commit
        FloatingAnimation(
          amplitude: 8,
          period: const Duration(seconds: 5),
          child: CodeWindow(
            title: 'terminal — zsh',
            tag: 'LATEST COMMIT',
            codeLines: [
              TextSpan(text: '→ ~ ', style: AppTextStyles.codeKeyword),
              TextSpan(text: 'git log --oneline -1\n', style: AppTextStyles.code),
              latestShaSpan,
              const TextSpan(text: ' '),
              latestMessageSpan,
              const TextSpan(text: '\n'),
              TextSpan(text: '→ repo: ', style: AppTextStyles.code),
              latestRepoSpan,
              const TextSpan(text: '\n'),
              TextSpan(text: '→ status: ', style: AppTextStyles.code),
              statusSpan,
            ],
          ),
        ),
      ],
    );
  }
}
