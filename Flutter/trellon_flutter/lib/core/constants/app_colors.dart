import 'package:flutter/material.dart';

// Trello Design System Colors
class AppColors {
  // ── Brand & Background ───────────────────────────────────────────────────
  static const Color primary            = Color(0xFF0052CC); // Primary Blue
  static const Color blueLight          = Color(0xFF579DFF); // Badge, highlight
  static const Color background         = Color(0xFFF4F5F7); // Screen background
  static const Color surfaceWhite       = Color(0xFFFFFFFF); // Card, sheet, modal

  // ── Priority Labels ──────────────────────────────────────────────────────
  static const Color priorityP1         = Color(0xFFF87462); // High
  static const Color priorityP2         = Color(0xFF388BFF); // Medium
  static const Color priorityP3         = Color(0xFF4BCE97); // Low

  // ── Type Tags ────────────────────────────────────────────────────────────
  static const Color tagFrontend        = Color(0xFF579DFF);
  static const Color tagFullStack       = Color(0xFFF5A623);

  // ── Label Colors (6 standard colors) ─────────────────────────────────────
  static const Color labelGreen         = Color(0xFF4BCE97);
  static const Color labelYellow        = Color(0xFFCCA300);
  static const Color labelOrange        = Color(0xFFF5A623);
  static const Color labelRed           = Color(0xFFF87462);
  static const Color labelPurple        = Color(0xFF9F8FEF);
  static const Color labelBlue          = Color(0xFF579DFF);

  // ── Text Colors ──────────────────────────────────────────────────────────
  static const Color textPrimary        = Color(0xFF172B4D); // Title, main content
  static const Color textSecondary      = Color(0xFF6B778C); // Subtitle, metadata
  static const Color textPlaceholder    = Color(0xFFA5ADBA); // Input placeholder
  static const Color textLink           = Color(0xFF0052CC); // Link, action text
  static const Color textDestructive    = Color(0xFFCA3521); // Delete, warning
  static const Color textDisabled       = Color(0xFFC1C7D0); // Disabled state

  // ── Status Colors ────────────────────────────────────────────────────────
  static const Color success            = Color(0xFF22A06B);
  static const Color warning            = Color(0xFFFF8B00);
  static const Color error              = Color(0xFFDE350B);
  static const Color info               = Color(0xFF0065FF);
  static const Color unreadIndicator    = Color(0xFF0052CC);

  // ── Component Specific Colors (Derived) ──────────────────────────────────
  static const Color badgeP1Bg          = Color(0xFFFFEBE6);
  static const Color badgeP2Bg          = Color(0xFFDEEBFF);
  static const Color badgeP3Bg          = Color(0xFFE3FCEF);
  static const Color badgeFullStackBg   = Color(0xFFFFF0B3);

  static const Color navBackground      = Color(0xFFFFFFFF);
  static const Color navSelected        = Color(0xFF0052CC);
  static const Color navSelectedBg      = Color(0xFFEAF2FF);
  static const Color navUnselected      = Color(0xFF6B778C);
  
  static const Color outline            = Color(0xFFE3E6EA); // default border

  // ── Legacy Aliases (to prevent compilation errors during refactoring) ─────
  static const Color primaryContainer   = primary;
  static const Color onPrimary          = surfaceWhite;
  static const Color onPrimaryContainer = textPrimary;
  static const Color secondary          = textSecondary;
  static const Color backgroundOld      = background;
  static const Color surface            = background;
  static const Color onSurface          = textPrimary;
  static const Color onSurfaceVariant   = textSecondary;
  static const Color outlineVariant     = outline;
  static const Color surfaceContainerLow = Color(0xFFF3F4F6);
  static const Color surfaceContainerHighest = Color(0xFFE1E2E4);
  static const Color surfaceContainerLowest = surfaceWhite;
  static const Color surfaceContainer = background;
  static const Color surfaceContainerHigh = Color(0xFFE7E8EA);
  static const Color surfaceVariant = Color(0xFFE2E2E9);
  static const Color border = outline;
  static const Color textWhite = surfaceWhite;
  static const Color primaryFixed = Color(0xFFCCE5FF);
  
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F3);
  static const Color inversePrimary = Color(0xFFB2C5FF);
  static const Color surfaceTint = primary;
  static const Color accent = primary;

  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = surfaceWhite;
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F191C1E),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
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
}
