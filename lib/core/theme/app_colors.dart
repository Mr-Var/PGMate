import 'package:flutter/material.dart';

/// "Clean Blue" palette and semantic colour tokens.
///
/// Widgets must use these tokens (or the [ColorScheme]) instead of raw hex
/// values so the look stays consistent across the app.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF1E40AF);
  static const light = Color(0xFF93B4F5);
  static const background = Color(0xFFF4F6F9);

  /// Progress fill on the blue hero card.
  static const heroProgress = Color(0xFFFFFFFF);
  static const heroTrack = Color(0x38FFFFFF);

  // Surfaces & text
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFEEF1F5);
  static const border = Color(0xFFE3E8EF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569); // 7.5:1 on white
  static const textMuted = Color(0xFF5B6576); // 5.9:1 on white

  // Accent used for quick actions and highlights.
  static const accent = primary;
  static const accentText = primary;
  static const accentSoft = Color(0xFFEAF0FE);

  // Semantic status colours (text-safe on white, with soft fills)
  static const success = Color(0xFF15803D);
  static const successSoft = Color(0xFFE8F6EE);
  static const warning = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFEF3E2);
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFDECEC);
  static const info = Color(0xFF0E7490);
  static const infoSoft = Color(0xFFE3F4F8);
  static const neutralSoft = Color(0xFFEEF1F5);

  // Bed status colours
  static const bedAvailable = success;
  static const bedOccupied = primary;
  static const bedReserved = info;
  static const bedMaintenance = warning;
}
