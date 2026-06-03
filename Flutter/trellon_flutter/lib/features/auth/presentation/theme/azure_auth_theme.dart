import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AzureAuthTheme {
  // ── Colors ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF003FB1);
  static const Color primaryContainer = Color(0xFF1A56DB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFD4DCFF);
  
  static const Color secondary = Color(0xFF566068);
  static const Color secondaryContainer = Color(0xFFDAE4EE); // Tint for secondary buttons
  static const Color onSecondaryContainer = Color(0xFF5C666E);
  
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // White card
  static const Color surfaceContainerLow = Color(0xFFF3F4F5); // Input field background
  static const Color background = Color(0xFFF8F9FA); // Screen background
  
  static const Color onSurface = Color(0xFF191C1D); // Main text
  static const Color onSurfaceVariant = Color(0xFF434654); // Soft/metadata text
  static const Color outline = Color(0xFF737686); 
  static const Color outlineVariant = Color(0xFFC3C5D7); // 1px borders
  
  static const Color error = Color(0xFFBA1A1A);
  
  // Specific required colors
  static const Color azureBlue = Color(0xFF1A56DB); 
  static const Color azureTint = Color(0xFFEBF5FF);
  static const Color textDeepGray = Color(0xFF111827);
  static const Color textMidGray = Color(0xFF6B7280);

  // ── Shadows ───────────────────────────────────────────────────────
  static const List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: Color(0x141A56DB), // rgba(26, 86, 219, 0.08) -> 0.08 * 255 = ~20 -> 0x14
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  // ── Typography ────────────────────────────────────────────────────
  static TextStyle headlineLg = GoogleFonts.manrope(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 38 / 30,
    letterSpacing: -0.02 * 30,
    color: textDeepGray,
  );

  static TextStyle headlineLgMobile = GoogleFonts.manrope(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    letterSpacing: -0.02 * 26,
    color: textDeepGray,
  );

  static TextStyle headlineMd = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: textDeepGray,
  );

  static TextStyle bodyLg = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: textMidGray,
  );

  static TextStyle bodyMd = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: textMidGray,
  );

  static TextStyle labelMd = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: textDeepGray,
  );

  static TextStyle buttonText = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.01 * 16,
    color: onPrimary,
  );
}
