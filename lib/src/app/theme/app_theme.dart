import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  // Primary Color - Orange/Golden (matching web primary-600)
  static const _primaryOrange = Color(0xFFA66906); // primary-700
  static const _primaryLight = Color(0xFFF79F17); // primary-400
  
  // Secondary Color - Green (matching web secondary-600)
  static const _secondaryGreen = Color(0xFF43A047); // secondary-600
  static const _secondaryLight = Color(0xFF66BB6A); // secondary-400
  static const _secondaryDark = Color(0xFF388E3C); // secondary-700
  
  // Surface Colors - Light neutral tones
  static const _lightSurface = Color(0xFFFAFAFA);
  static const _cardSurface = Color(0xFFFFFFFF);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryOrange,
        brightness: Brightness.light,
        primary: _primaryOrange,
        secondary: _secondaryGreen,
      ),
    );

    final scheme = base.colorScheme.copyWith(
      surface: _lightSurface,
      surfaceContainerHighest: _cardSurface,
      primary: _primaryOrange,
      primaryContainer: _primaryLight,
      secondary: _secondaryGreen,
      secondaryContainer: _secondaryLight,
      tertiary: _secondaryDark,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Use Google Fonts to match web (Inter for body, Poppins for display/headings)
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        // Display/Heading text with Poppins (matching web font-display)
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: -0.02,
          color: scheme.onSurface,
        ),
        // Body text with Inter (matching web font-sans)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: scheme.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: scheme.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: scheme.onSurface,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8, // Enhanced elevation matching web shadow-lg
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: scheme.surfaceContainerHighest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Matching web rounded-2xl (20px)
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.02,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryOrange, // primary-600
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Matching web rounded-lg
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          elevation: 4, // shadow-lg effect
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryGreen, // secondary-600
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          elevation: 4,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryOrange,
          side: BorderSide(color: _primaryOrange, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Matching web rounded-lg
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
