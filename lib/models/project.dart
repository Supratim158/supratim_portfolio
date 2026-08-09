/// Project model for the portfolio showcase.
///
/// Each project is defined in [project_data.dart] for easy editing.
class Project {
  /// Unique identifier used for routing to the detail page.
  final String id;

  final String title;
  final String description;

  /// A short one-line tagline shown on the card.
  final String tagline;

  /// Path to a local asset image, e.g. 'assets/images/projects/my_app.png'
  final String? imagePath;

  /// Network image URL (fallback if imagePath is null).
  final String? imageUrl;

  final List<String> techStack;
  final String? githubUrl;
  final String? liveUrl;

  // ── Detail Page Fields ──────────────────────────────────────
  /// Long-form description shown on the detail page.
  final String longDescription;

  /// Key features / highlights.
  final List<String> features;

  /// Screenshots for the detail page gallery.
  final List<String> screenshotPaths;

  /// What role you played in this project.
  final String? role;

  /// Duration / timeline of the project.
  final String? duration;

  /// Status of the project (e.g. 'Completed', 'In Progress', 'Maintained').
  final String status;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    this.tagline = '',
    this.imagePath,
    this.imageUrl,
    required this.techStack,
    this.githubUrl,
    this.liveUrl,
    this.longDescription = '',
    this.features = const [],
    this.screenshotPaths = const [],
    this.role,
    this.duration,
    this.status = 'Completed',
  });
}
