import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App text styles matching web theme
class AppTextStyles {
  // Display/Heading styles (Poppins-like, matching web h1-h6)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 52, // 5xl in web (3.25rem)
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.02,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 40, // 4xl in web (2.5rem)
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.02,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 32, // 3xl in web (2rem)
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24, // 2xl in web (1.5rem)
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20, // xl in web (1.25rem)
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18, // lg in web (1.125rem)
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: -0.02,
  );

  // Body text styles (Inter-like, matching web body text)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, // base in web (1rem)
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, // sm in web (0.875rem)
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, // xs in web (0.75rem)
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Button text styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );
}

/// App decorations matching web theme
class AppDecorations {
  // Card decorations with elevated shadow (matching web shadow-lg and shadow-2xl)
  static BoxDecoration cardElevated = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: BorderRadius.circular(16), // rounded-2xl (20px in web)
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ],
  );

  static BoxDecoration cardElevatedLarge = BoxDecoration(
    color: AppColors.surfaceCard,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: 48,
        offset: const Offset(0, 16),
        spreadRadius: -8,
      ),
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
    ],
  );

  // Input field decoration (matching web input-field)
  static InputDecoration inputField({
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // rounded-lg
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary600, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  // Button decorations (matching web btn-primary, btn-secondary, btn-outline)
  static BoxDecoration buttonPrimary = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(8), // rounded-lg
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration buttonSecondary = BoxDecoration(
    gradient: AppColors.secondaryGradient,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration buttonOutline = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.primary600,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

/// App spacing constants (matching web 8px grid system and golden ratio)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Golden ratio based spacing (matching web)
  static const double golden13 = 52.0; // 3.25rem
  static const double golden21 = 84.0; // 5.25rem
  static const double golden34 = 136.0; // 8.5rem
  static const double golden55 = 220.0; // 13.75rem
  static const double golden89 = 356.0; // 22.25rem

  // Padding presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // Common button padding (matching web py-3 px-8 = 12px 32px)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 12,
  );

  // Common card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(16);
}

/// Border radius constants
class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0; // rounded-lg in web
  static const double lg = 16.0; // rounded-2xl in web (actually 20px but 16 is close)
  static const double xl = 24.0;
  static const double full = 9999.0; // rounded-full

  static BorderRadius radiusSm = BorderRadius.circular(sm);
  static BorderRadius radiusMd = BorderRadius.circular(md);
  static BorderRadius radiusLg = BorderRadius.circular(lg);
  static BorderRadius radiusXl = BorderRadius.circular(xl);
  static BorderRadius radiusFull = BorderRadius.circular(full);
}
