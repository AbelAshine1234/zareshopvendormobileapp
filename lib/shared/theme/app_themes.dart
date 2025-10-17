import 'package:flutter/material.dart';

enum AppThemeType {
  coffee,
  black,
  white,
  green,
  ocean,
}

class AppThemeData {
  final String name;
  final String emoji;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final bool isDark;

  const AppThemeData({
    required this.name,
    required this.emoji,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.isDark,
  });

  // Gradients
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get cardGradient => LinearGradient(
    colors: [
      surface,
      accent.withOpacity(0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get successGradient => LinearGradient(
    colors: [success, success.withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppThemes {
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

  // Animation Durations
  static const Duration celebrationAnimation = Duration(milliseconds: 1200);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  static const Duration fastAnimation = Duration(milliseconds: 300);

  // Theme Definitions
  static const AppThemeData coffee = AppThemeData(
    name: 'Coffee',
    emoji: '☕️',
    description: 'Warm, grounded, cozy — great for neutral UI',
    primary: Color(0xFF4B2E05), // Deep Roast
    secondary: Color(0xFFA47551), // Mocha
    accent: Color(0xFFD7B89C), // Latte Cream
    background: Color(0xFFF8F6F3),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2C1810),
    textSecondary: Color(0xFF6B4E3D),
    textHint: Color(0xFF9B8A7A),
    error: Color(0xFFD32F2F),
    success: Color(0xFF4B7C59),
    warning: Color(0xFFE65100),
    info: Color(0xFF1976D2),
    isDark: false,
  );

  static const AppThemeData black = AppThemeData(
    name: 'Black',
    emoji: '⚫️',
    description: 'Sleek, modern, perfect for dark mode',
    primary: Color(0xFF000000), // Pure Black
    secondary: Color(0xFF1C1C1C), // Charcoal
    accent: Color(0xFFFFFFFF), // White Contrast
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3B3B3),
    textHint: Color(0xFF666666),
    error: Color(0xFFFF5252),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    info: Color(0xFF2196F3),
    isDark: true,
  );

  static const AppThemeData white = AppThemeData(
    name: 'White',
    emoji: '⚪️',
    description: 'Clean, minimal, and light-focused',
    primary: Color(0xFFFFFFFF), // White
    secondary: Color(0xFFF5F5F5), // Smoke
    accent: Color(0xFFCFCFCF), // Light Gray
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    textHint: Color(0xFF9E9E9E),
    error: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFFF9800),
    info: Color(0xFF1976D2),
    isDark: false,
  );

  static const AppThemeData green = AppThemeData(
    name: 'Green',
    emoji: '🌿',
    description: 'Fresh, organic, revitalizing',
    primary: Color(0xFF145A32), // Forest
    secondary: Color(0xFF27AE60), // Leaf
    accent: Color(0xFFABEBC6), // Mint
    background: Color(0xFFF0FDF4),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0F2419),
    textSecondary: Color(0xFF166534),
    textHint: Color(0xFF4ADE80),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFEA580C),
    info: Color(0xFF0284C7),
    isDark: false,
  );

  static const AppThemeData ocean = AppThemeData(
    name: 'Ocean',
    emoji: '🌊',
    description: 'Cool, balanced, and modern',
    primary: Color(0xFF003366), // Deep Sea
    secondary: Color(0xFF0077B6), // Aqua
    accent: Color(0xFF90E0EF), // Foam
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0C1821),
    textSecondary: Color(0xFF0369A1),
    textHint: Color(0xFF0EA5E9),
    error: Color(0xFFDC2626),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    info: Color(0xFF0284C7),
    isDark: false,
  );

  // Get all available themes
  static List<AppThemeData> get allThemes => [
    coffee,
    black,
    white,
    green,
    ocean,
  ];

  // Get theme by type
  static AppThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.coffee:
        return coffee;
      case AppThemeType.black:
        return black;
      case AppThemeType.white:
        return white;
      case AppThemeType.green:
        return green;
      case AppThemeType.ocean:
        return ocean;
    }
  }

  // Text Styles (using current theme)
  static TextStyle displayLarge(AppThemeData theme) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: theme.textPrimary,
    height: 1.2,
  );

  static TextStyle displayMedium(AppThemeData theme) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: theme.textPrimary,
    height: 1.2,
  );

  static TextStyle headlineLarge(AppThemeData theme) => TextStyle(
    fontSize: fontSizeXXL,
    fontWeight: FontWeight.w600,
    color: theme.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineMedium(AppThemeData theme) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: theme.textPrimary,
    height: 1.3,
  );

  static TextStyle titleLarge(AppThemeData theme) => TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.w600,
    color: theme.textPrimary,
    height: 1.4,
  );

  static TextStyle titleMedium(AppThemeData theme) => TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: theme.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyLarge(AppThemeData theme) => TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: theme.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium(AppThemeData theme) => TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: theme.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall(AppThemeData theme) => TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: theme.textSecondary,
    height: 1.5,
  );

  static TextStyle labelLarge(AppThemeData theme) => TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: theme.textPrimary,
    height: 1.4,
  );

  static TextStyle labelMedium(AppThemeData theme) => TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: theme.textSecondary,
    height: 1.4,
  );

  static TextStyle buttonText(AppThemeData theme) => TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: theme.isDark ? theme.textPrimary : Colors.white,
    height: 1.2,
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle(AppThemeData theme) => ElevatedButton.styleFrom(
    backgroundColor: theme.primary,
    foregroundColor: theme.isDark ? theme.textPrimary : Colors.white,
    elevation: 2,
    shadowColor: theme.primary.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  static ButtonStyle secondaryButtonStyle(AppThemeData theme) => OutlinedButton.styleFrom(
    foregroundColor: theme.primary,
    side: BorderSide(color: theme.primary, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  static ButtonStyle textButtonStyle(AppThemeData theme) => TextButton.styleFrom(
    foregroundColor: theme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration(
    AppThemeData theme, {
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: theme.textHint,
        fontSize: fontSizeMedium,
      ),
      errorText: errorText,
      errorStyle: TextStyle(
        color: theme.error,
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
        borderSide: BorderSide(color: theme.accent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.accent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.error, width: 2),
      ),
      filled: true,
      fillColor: theme.surface,
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration(AppThemeData theme) => BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(largeBorderRadius),
    boxShadow: theme.cardShadow,
    border: Border.all(
      color: theme.accent.withOpacity(0.5),
      width: 0.5,
    ),
  );

  // Generate Flutter ThemeData
  static ThemeData generateThemeData(AppThemeData themeData) {
    return ThemeData(
      useMaterial3: true,
      brightness: themeData.isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeData.primary,
        brightness: themeData.isDark ? Brightness.dark : Brightness.light,
        primary: themeData.primary,
        secondary: themeData.secondary,
        surface: themeData.surface,
        background: themeData.background,
        error: themeData.error,
      ),
      scaffoldBackgroundColor: themeData.background,
      appBarTheme: AppBarTheme(
        backgroundColor: themeData.surface,
        foregroundColor: themeData.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleLarge(themeData),
        iconTheme: IconThemeData(color: themeData.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(themeData),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle(themeData),
      ),
      textButtonTheme: TextButtonThemeData(
        style: textButtonStyle(themeData),
      ),
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
        color: themeData.surface,
      ),
    );
  }
}
