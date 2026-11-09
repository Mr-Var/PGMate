import 'package:flutter/material.dart';

/// "Clean Blue" palette. Blue is reserved for actions, selection and the
/// brand mark; everything else is a calibrated cool-grey scale so figures,
/// not chrome, carry the screen. Widgets use these tokens, never raw hex.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF1E40AF);
  static const light = Color(0xFF93B4F5);
  static const ink = Color(0xFF0B1220); // lock screen, dark surfaces

  // Neutrals
  static const background = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F2F5);
  static const border = Color(0xFFE4E7EC);
  static const borderStrong = Color(0xFFD0D5DD);
  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF475467); // 7.6:1 on white
  static const textMuted = Color(0xFF667085); // 4.8:1 on white

  // Progress on the light hero card.
  static const heroProgress = primary;
  static const heroTrack = Color(0xFFE4E7EC);

  // Actions & highlights
  static const accent = primary;
  static const accentText = primary;
  static const accentSoft = Color(0xFFEFF4FF);

  // Semantic status colours (text-safe on white) with very light fills.
  static const success = Color(0xFF067647);
  static const successSoft = Color(0xFFECFDF3);
  static const warning = Color(0xFFB54708);
  static const warningSoft = Color(0xFFFFFAEB);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFEF3F2);
  static const info = Color(0xFF175CD3);
  static const infoSoft = Color(0xFFEFF8FF);
  static const neutralSoft = Color(0xFFF2F4F7);

  // Bed status
  static const bedAvailable = success;
  static const bedOccupied = primary;
  static const bedReserved = Color(0xFF6941C6);
  static const bedMaintenance = warning;

  /// Muted, distinct hues for initials avatars (stable per name).
  static const avatarHues = [
    Color(0xFF1D4ED8),
    Color(0xFF067647),
    Color(0xFF6941C6),
    Color(0xFFB54708),
    Color(0xFF0E7090),
    Color(0xFFC11574),
    Color(0xFF3E4784),
    Color(0xFF4E5BA6),
  ];

  static Color avatarFor(String name) {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return avatarHues[h % avatarHues.length];
  }
}
