/// Central constants for the portfolio application.
class AppConstants {
  AppConstants._();

  // ── API ─────────────────────────────────────────────────────
  static const String apiBaseUrl = 'https://supratim-portfolio-backend.onrender.com';
  static const String githubProfileEndpoint = '/api/github/profile';
  static const String githubReposEndpoint = '/api/github/repositories';
  static const String githubContributionsEndpoint = '/api/github/contributions';
  static const String githubCommitsEndpoint = '/api/github/commits';
  static const String githubContribGraphEndpoint = '/api/github/contribution-graph';
  static const String githubAllCommitsEndpoint = '/api/github/all-commits';
  static const String contactEndpoint = '/api/contact';

  // ── Social Links ────────────────────────────────────────────
  static const String githubUrl = 'https://github.com/Supratim158';
  static const String linkedinUrl = 'https://linkedin.com/in/supratim-modak';
  static const String instagramUrl = 'https://www.instagram.com/supratiim__';
  static const String email = 'supratim2005k@gmail.com';
  static const String resumeUrl =
      'https://drive.google.com/file/d/1waw8V6bqYPkjwQCAq37idUHsIv5sD8JE/view?usp=drivesdk';

  // ── Animation Durations (ms) ────────────────────────────────
  static const int loaderDuration = 3500;
  static const int fadeInDuration = 600;
  static const int staggerDelay = 100;
  static const int typingSpeed = 50;
  static const int hoverDuration = 200;
  static const int pageTransition = 400;

  // ── Layout ──────────────────────────────────────────────────
  static const double maxContentWidth = 1200.0;
  static const double navHeight = 72.0;
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1280.0;

  // ── Branding ────────────────────────────────────────────────
  static const String brandName = "SUPRATIM's_PORTFOLIO";
  static const String systemVersion = 'SYSTEM VERSION 1.0.4 // AI_SYSTEMS_ACTIVE';
  static const String copyright = '© 2026 CRAFTED WITH CODE, CREATIVITY & PRECISION';
}
