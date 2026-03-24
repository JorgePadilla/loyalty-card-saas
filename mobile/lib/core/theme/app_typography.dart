import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Headlines — Inter, bold
  // ---------------------------------------------------------------------------

  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.matte,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.matte,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.matte,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // Titles — Inter, semibold
  // ---------------------------------------------------------------------------

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.matte,
    height: 1.3,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.matte,
    height: 1.35,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.matte,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Body — Inter, regular
  // ---------------------------------------------------------------------------

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.matte,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.matte,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
    height: 1.5,
  );

  // ---------------------------------------------------------------------------
  // Labels — Inter, medium
  // ---------------------------------------------------------------------------

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.matte,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Mono — Space Grotesk for numbers and points
  // ---------------------------------------------------------------------------

  static TextStyle mono = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.matte,
    height: 1.4,
  );

  static TextStyle monoLarge = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.matte,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle monoMedium = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.matte,
    height: 1.3,
  );

  static TextStyle monoSmall = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // TextTheme assembled for ThemeData
  // ---------------------------------------------------------------------------

  static TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
