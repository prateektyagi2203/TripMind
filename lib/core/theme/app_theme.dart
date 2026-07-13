import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the app [ThemeData] using the Lovable design language.
/// Display/headings use Fraunces (serif); body uses a Geist-like sans (Inter).
abstract class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        primary: AppColors.primary,
        surface: AppColors.card,
        // ignore: deprecated_member_use
        background: AppColors.background,
        error: AppColors.destructive,
        brightness: Brightness.light,
      ),
    );

    final sans = GoogleFonts.interTextTheme(base.textTheme);
    final display = GoogleFonts.fraunces(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: AppColors.foreground,
    );

    return base.copyWith(
      textTheme: sans
          .copyWith(
            displaySmall: display.copyWith(fontSize: 30),
            headlineMedium: display.copyWith(fontSize: 24),
            headlineSmall: display.copyWith(fontSize: 20),
            titleLarge: display.copyWith(fontSize: 18),
          )
          .apply(
            bodyColor: AppColors.foreground,
            displayColor: AppColors.foreground,
          ),
      dividerColor: AppColors.border,
    );
  }
}
