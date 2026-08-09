import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography hierarchy matching the DEV_CORE design system.
class AppTextStyles {
  AppTextStyles._();

  // ── Mono (Brand, Code, Labels) ──────────────────────────────
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  // ── Brand / Logo ────────────────────────────────────────────
  static TextStyle brand = GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontStyle: FontStyle.italic,
  );

  // ── Hero Name ───────────────────────────────────────────────
  static TextStyle heroName = GoogleFonts.spaceGrotesk(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle heroNameMobile = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // ── Hero Role (Typing animation text) ───────────────────────
  static TextStyle heroRole = GoogleFonts.jetBrainsMono(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryLight,
  );

  // ── Section Label (small uppercase) ─────────────────────────
  static TextStyle sectionLabel = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryLight,
    letterSpacing: 3.0,
  );

  // ── Section Title ───────────────────────────────────────────
  static TextStyle sectionTitle = GoogleFonts.spaceGrotesk(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle sectionTitleMobile = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // ── Subtitle ────────────────────────────────────────────────
  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // ── Body ────────────────────────────────────────────────────
  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.6,
  );

  // ── Card Title ──────────────────────────────────────────────
  static TextStyle cardTitle = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Card Description ────────────────────────────────────────
  static TextStyle cardDescription = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Stat Number ─────────────────────────────────────────────
  static TextStyle statNumber = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle statLabel = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 1.5,
  );

  // ── Navigation ──────────────────────────────────────────────
  static TextStyle navItem = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.navInactive,
  );

  static TextStyle navItemActive = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.navActive,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.navActive,
    decorationThickness: 2,
  );

  // ── Button ──────────────────────────────────────────────────
  static TextStyle button = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  // ── Footer ──────────────────────────────────────────────────
  static TextStyle footer = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 1.0,
  );

  // ── Code Snippet ────────────────────────────────────────────
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle codeKeyword = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryLight,
    height: 1.6,
  );

  static TextStyle codeString = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    height: 1.6,
  );

  // ── Tech Marquee ────────────────────────────────────────────
  static TextStyle marquee = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 6.0,
  );
}
