import 'package:flutter/material.dart';

/// TripMind design tokens, mirrored exactly from the Lovable source
/// (`reference/lovable-source/src/styles.css`). Original values are in `oklch`;
/// these are the converted sRGB hex equivalents (see `reference/oklch_to_hex.py`).
///
/// Design language: warm sandy paper background, deep ink-ocean foreground,
/// ocean-teal primary, sunset-coral accent.
abstract class AppColors {
  // Surfaces
  static const background = Color(0xFFFEFAF1); // warm paper
  static const foreground = Color(0xFF031E29); // deep ink ocean
  static const card = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF1EADC);
  static const muted = Color(0xFFF0EBE0);
  static const sand = Color(0xFFF9EDD9);

  // Text
  static const mutedForeground = Color(0xFF526771);

  // Brand
  static const primary = Color(0xFF004B59); // ocean teal (deep)
  static const ocean = Color(0xFF007F9E); // ocean (active nav, links)
  static const sunset = Color(0xFFF47F46); // coral accent / CTAs
  static const accent = Color(0xFFF9DFCB);

  // Lines & status
  static const border = Color(0xFFDDD7C9);
  static const input = Color(0xFFE4DDCF);
  static const destructive = Color(0xFFDF2225);

  // Gradients
  static const gradientSunset = [
    Color(0xFFF8A052),
    Color(0xFFF57050),
    Color(0xFFA84E7C),
  ];
  static const gradientOcean = [Color(0xFF006078), Color(0xFF06384B)];
}
