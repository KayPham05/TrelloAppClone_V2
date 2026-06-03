import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildLight();

  static ThemeData _buildLight() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surfaceWhite,
        secondary: AppColors.blueLight,
        error: AppColors.error,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22, // Title 2
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: AppColors.navUnselected,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Using manual border instead of elevation
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 17),
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 0.5,
        space: 0,
      ),

      textTheme: _buildTextTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displayLarge:   TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 41/34), // Large Title
      displayMedium:  TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 34/28), // Title 1
      displaySmall:   TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 28/22), // Title 2
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 25/20), // Title 3
      titleLarge:     TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 22/17), // Headline
      bodyLarge:      TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 22/17), // Body
      bodyMedium:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 21/16), // Callout
      titleMedium:    TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 20/15, letterSpacing: 0.5), // Subheadline
      bodySmall:      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 18/13), // Footnote
      labelLarge:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 16/12), // Caption 1
      labelSmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 13/11),// Caption 2
    );
  }
}
