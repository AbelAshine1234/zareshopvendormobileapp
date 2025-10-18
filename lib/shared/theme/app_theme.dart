import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF4CAF50);
  
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF1976D2);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color emeraldGreen = Color(0xFF50C878);
  
  // Additional color aliases for compatibility
  static const Color successColor = successGreen;
  static const Color primaryColor = primaryGreen;
  static const Color errorColor = errorRed;
  static const Color warningColor = warningOrange;
  static const Color borderColor = dividerColor;
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border Radius
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeHero = 32.0;
  static const double fontSizeRegular = 16.0;

  // Button
  static const double buttonHeight = 48.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: [
      Colors.white,
      lightGreen.withOpacity(0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => LinearGradient(
    colors: [successGreen, emeraldGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Animation Durations
  static const Duration celebrationAnimation = Duration(milliseconds: 1200);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // Text Styles
  static TextStyle get displayLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontSize: fontSizeXXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get buttonText => const TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: primaryGreen.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    side: const BorderSide(color: primaryGreen, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: textHint,
        fontSize: fontSizeMedium,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(
        color: errorRed,
        fontSize: fontSizeSmall,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceM,
        vertical: spaceM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      filled: true,
      fillColor: backgroundSecondary,
    );
  }

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(largeBorderRadius),
    boxShadow: cardShadow,
    border: Border.all(
      color: dividerColor.withOpacity(0.5),
      width: 0.5,
    ),
  );

  // App Bar Theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: backgroundSecondary,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: titleLarge,
    iconTheme: const IconThemeData(color: textPrimary),
  );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundPrimary,
    appBarTheme: appBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(largeBorderRadius),
      ),
    ),
  );
}
