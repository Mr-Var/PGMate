import 'package:flutter/material.dart';

/// Brand palette and semantic colour tokens.
///
/// Widgets must use these tokens (or the [ColorScheme]) instead of raw hex
/// values so the look stays consistent across the app.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF522546);
  static const secondary = Color(0xFF633058);
  static const light = Color(0xFFA36BAC);
  static const accent = Color(0xFFF9943B);
  static const background = Color(0xFFF7F4F8);

  // Surfaces & text
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1ECF2);
  static const border = Color(0xFFE6DEE8);
  static const textPrimary = Color(0xFF1F1420);
  static const textSecondary = Color(0xFF5E5262); // 7.0:1 on white
  static const textMuted = Color(0xFF7A6E7E); // 4.7:1 on white

  // Accent text needs a darker shade to keep 4.5:1 contrast on light surfaces.
  static const accentText = Color(0xFFA8540C);
  static const accentSoft = Color(0xFFFEF0E3);

  // Semantic status colours (text-safe on white, with soft fills)
  static const success = Color(0xFF1E7B4F);
  static const successSoft = Color(0xFFE5F4EC);
  static const warning = Color(0xFFA8540C);
  static const warningSoft = Color(0xFFFEF0E3);
  static const danger = Color(0xFFC0362C);
  static const dangerSoft = Color(0xFFFBE9E7);
  static const info = Color(0xFF2E5AAC);
  static const infoSoft = Color(0xFFE8EEF9);
  static const neutralSoft = Color(0xFFEDEAEE);

  // Bed status colours
  static const bedAvailable = success;
  static const bedOccupied = primary;
  static const bedReserved = info;
  static const bedMaintenance = warning;
}
