import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildLight();

  static ThemeData _buildLight() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:            AppColors.primary,
        onPrimary:          AppColors.onPrimary,
        primaryContainer:   AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary:          AppColors.secondary,
        onSecondary:        AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary:           AppColors.tertiary,
        onTertiary:         AppColors.onTertiary,
        tertiaryContainer:  AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiary,
        error:              AppColors.error,
        onError:            AppColors.onError,
        errorContainer:     AppColors.errorContainer,
        onErrorContainer:   AppColors.onErrorContainer,
        surface:            AppColors.surface,
        onSurface:          AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant:   AppColors.onSurfaceVariant,
        outline:            AppColors.outline,
        outlineVariant:     AppColors.outlineVariant,
        inverseSurface:     AppColors.inverseSurface,
        onInverseSurface:   AppColors.inverseOnSurface,
        inversePrimary:     AppColors.inversePrimary,
        shadow:             Color(0xFF000000),
        scrim:              Color(0xFF000000),
        surfaceTint:        AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFF1F2F4), // slate-100
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.outlineVariant.withValues(alpha: 0.4),
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E3A8A), // blue-900
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1D4ED8)), // blue-700
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: AppColors.navUnselected,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        shadowColor: Color(0x0F191C1E),
      ),

      // ── Input / TextField ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        labelStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Text ─────────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge:   GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      displayMedium:  GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      displaySmall:   GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      headlineLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineSmall:  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      titleLarge:     GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleMedium:    GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleSmall:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      bodyLarge:      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodyMedium:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
      labelLarge:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
      labelMedium:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
      labelSmall:     GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
    );
  }
}
