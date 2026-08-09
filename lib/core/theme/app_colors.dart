import 'package:flutter/material.dart';

/// Centralized color palette extracted from the DEV_CORE design system.
/// Dark matte theme with indigo accent.
class AppColors {
  AppColors._();

  // ── Background ──────────────────────────────────────────────
  static const Color background = Color(0xFF080B14);
  static const Color surface = Color(0xFF0F1629);
  static const Color surfaceLight = Color(0xFF151D30);
  static const Color cardBg = Color(0xFF111827);
  static const Color cardBgLight = Color(0xFF1A2035);
  static const Color cardBgHover = Color(0xFF1E2A42);

  // ── Borders ─────────────────────────────────────────────────
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF2A3654);
  static const Color borderAccent = Color(0xFF3B4C6B);

  // ── Primary Accent (Indigo / Blue-Violet) ───────────────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryMuted = Color(0xFF4F46E5);
  static const Color primaryDim = Color(0xFF3730A3);

  // ── Secondary Accent ────────────────────────────────────────
  static const Color accent = Color(0xFF93C5FD);
  static const Color accentMuted = Color(0xFF60A5FA);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF475569);

  // ── Status ──────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ── Contribution Graph ──────────────────────────────────────
  static const Color contribNone = Color(0xFF161B22);
  static const Color contribLow = Color(0xFF0E4429);
  static const Color contribMed = Color(0xFF006D32);
  static const Color contribHigh = Color(0xFF26A641);
  static const Color contribMax = Color(0xFF39D353);

  // ── Loader ──────────────────────────────────────────────────
  static const Color loaderText = Color(0xFF7B8DB5);
  static const Color loaderIcon = Color(0xFF818CF8);

  // ── Nav Bar ─────────────────────────────────────────────────
  static const Color navBg = Color(0xFF0C1020);
  static const Color navActive = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF94A3B8);

  // ── Button ──────────────────────────────────────────────────
  static const Color buttonBorder = Color(0xFF2A3654);
  static const Color buttonHover = Color(0xFF1E2A42);

  // ── Gradients ───────────────────────────────────────────────
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Color(0xFF0F1629)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF080B14), Color(0xFF0C1020)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [Color(0xFF111827), Color(0xFF1A2035), Color(0xFF111827)],
  );
}
