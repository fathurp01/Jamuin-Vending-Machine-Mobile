import 'package:flutter/material.dart';

/// App color constants matching web theme
/// Based on Tailwind CSS color palette from vending-machine-web
class AppColors {
  // Primary Colors - Orange/Golden palette (matching web primary)
  static const Color primary50 = Color(0xFFFEF3E2);
  static const Color primary100 = Color(0xFFFDE7C5);
  static const Color primary200 = Color(0xFFFBCF8B);
  static const Color primary300 = Color(0xFFF9B751);
  static const Color primary400 = Color(0xFFF79F17);
  static const Color primary500 = Color(0xFFD68508);
  static const Color primary600 = Color(0xFFA66906); // Main primary color
  static const Color primary700 = Color(0xFF764C04);
  static const Color primary800 = Color(0xFF463002);
  static const Color primary900 = Color(0xFF161401);

  // Secondary Colors - Green palette (matching web secondary)
  static const Color secondary50 = Color(0xFFE8F5E9);
  static const Color secondary100 = Color(0xFFC8E6C9);
  static const Color secondary200 = Color(0xFFA5D6A7);
  static const Color secondary300 = Color(0xFF81C784);
  static const Color secondary400 = Color(0xFF66BB6A);
  static const Color secondary500 = Color(0xFF4CAF50);
  static const Color secondary600 = Color(0xFF43A047); // Main secondary color
  static const Color secondary700 = Color(0xFF388E3C);
  static const Color secondary800 = Color(0xFF2E7D32);
  static const Color secondary900 = Color(0xFF1B5E20);

  // Neutral Colors - Gray palette
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Semantic Colors
  static const Color success = secondary600;
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFDC2626); // red-600
  static const Color info = Color(0xFF3B82F6); // blue-500

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA); // gray-50
  static const Color surfaceCard = Color(0xFFFFFFFF); // white
  static const Color surfaceContainer = Color(0xFFF5F5F5); // gray-100

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // gray-400

  // Gradient Definitions (matching web)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary400, primary600],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary400, secondary600],
  );

  static const LinearGradient mixedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary500, secondary500],
  );

  // Shadow Colors with opacity
  static Color shadowLight = Colors.black.withValues(alpha: 0.08);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.12);
  static Color shadowDark = Colors.black.withValues(alpha: 0.18);
}
