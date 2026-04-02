import 'package:flutter/material.dart';

// Material 3 Light Theme – khớp với Stitch HTML mockups (Tailwind color config)
class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background         = Color(0xFFF8F9FB);
  static const Color surface            = Color(0xFFF8F9FB);
  static const Color surfaceBright      = Color(0xFFF8F9FB);
  static const Color surfaceVariant     = Color(0xFFE1E2E4);

  // Surface containers (depth / elevation)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow    = Color(0xFFF3F4F6);
  static const Color surfaceContainer       = Color(0xFFEDEEF0);
  static const Color surfaceContainerHigh   = Color(0xFFE7E8EA);
  static const Color surfaceContainerHighest= Color(0xFFE1E2E4);
  static const Color surfaceDim             = Color(0xFFD9DADC);

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary            = Color(0xFF003D9B);
  static const Color primaryContainer   = Color(0xFF0052CC); // Trello Blue
  static const Color primaryFixed       = Color(0xFFDAE2FF);
  static const Color primaryFixedDim    = Color(0xFFB2C5FF);
  static const Color inversePrimary     = Color(0xFFB2C5FF);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary          = Color(0xFF515F76);
  static const Color secondaryContainer = Color(0xFFD2E0FC);
  static const Color secondaryFixed     = Color(0xFFD5E3FF);
  static const Color secondaryFixedDim  = Color(0xFFB9C7E2);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary           = Color(0xFF004B59);
  static const Color tertiaryContainer  = Color(0xFF006477);
  static const Color tertiaryFixed      = Color(0xFFAFECFF);
  static const Color tertiaryFixedDim   = Color(0xFF48D7F9);

  // ── On-colors (text on top of color surfaces) ────────────────────────────
  static const Color onPrimary          = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFC4D2FF);
  static const Color onPrimaryFixed     = Color(0xFF001848);
  static const Color onSecondary        = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF55637B);
  static const Color onTertiary         = Color(0xFFFFFFFF);
  static const Color onBackground       = Color(0xFF191C1E);
  static const Color onSurface         = Color(0xFF191C1E);
  static const Color onSurfaceVariant  = Color(0xFF434654);
  static const Color inverseOnSurface  = Color(0xFFF0F1F3);
  static const Color inverseSurface    = Color(0xFF2E3132);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error             = Color(0xFFBA1A1A);
  static const Color errorContainer   = Color(0xFFFFDAD6);
  static const Color onError          = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Outline / Divider ────────────────────────────────────────────────────
  static const Color outline           = Color(0xFF737685);
  static const Color outlineVariant    = Color(0xFFC3C6D6);

  // ── Surface tint ─────────────────────────────────────────────────────────
  static const Color surfaceTint       = Color(0xFF0C56D0);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success           = Color(0xFF16A34A);
  static const Color warning           = Color(0xFFD97706);

  // ── Bottom Nav ───────────────────────────────────────────────────────────
  static const Color navBackground     = Color(0xFFFFFFFF);
  static const Color navSelected       = Color(0xFF1D4ED8); // blue-800
  static const Color navSelectedBg     = Color(0xFFDBEAFE); // blue-100
  static const Color navUnselected     = Color(0xFF64748B); // slate-500

  // ── Board cover colors (kept for mock boards) ────────────────────────────
  static const List<Color> boardColors = [
    Color(0xFF0079BF),
    Color(0xFFD29034),
    Color(0xFF519839),
    Color(0xFFB04632),
    Color(0xFF89609E),
    Color(0xFFCD5A91),
    Color(0xFF4BBF6B),
    Color(0xFF00AECC),
    Color(0xFF838C91),
  ];

  // ── Card / Shadow ────────────────────────────────────────────────────────
  /// Dùng cho BoxShadow thống nhất trên toàn app
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F191C1E),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // ── Legacy aliases (backward compat – sẽ xóa khi rewrite từng screen) ──
  static const Color textWhite     = Color(0xFFFFFFFF);
  static const Color textPrimary   = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color accent        = primaryContainer;
  static const Color border        = outlineVariant;
  static const Color darkBackground = Color(0xFF1D2125); // kept for old code
  static const Color cardBackground = surfaceContainer;
  static const Color iconColor      = onSurfaceVariant;
}
