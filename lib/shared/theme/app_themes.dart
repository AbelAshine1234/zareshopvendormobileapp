import 'package:flutter/material.dart';

enum AppThemeType {
  coffee,
  green,
  basic,
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
  
  // Button colors
  final Color buttonBackground;
  final Color buttonHover;
  
  // Input colors
  final Color inputBackground;
  final Color inputBorder;
  final Color inputFocus;
  
  // Label colors
  final Color labelText;
  final Color subtext;
  
  // Interactive colors
  final Color linkText;
  
  // UI elements
  final Color divider;
  final Color shadowColor;

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
    required this.buttonBackground,
    required this.buttonHover,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputFocus,
    required this.labelText,
    required this.subtext,
    required this.linkText,
    required this.divider,
    required this.shadowColor,
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
      color: shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: shadowColor,
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
  // 1️⃣ COFFEE – Restaurants / Cafés
  static const AppThemeData coffee = AppThemeData(
    name: 'Coffee',
    emoji: '☕️',
    description: 'Restaurants / Cafés - Warm & Cozy',
    background: Color(0xFFF9F5EF),
    primary: Color(0xFF4B2E05),
    secondary: Color(0xFFA47551),
    accent: Color(0xFFD7B89C),
    surface: Color(0xFFF3ECE2),
    buttonBackground: Color(0xFFA47551),
    buttonHover: Color(0xFF8C5E3C),
    inputBackground: Color(0xFFF3ECE2),
    inputBorder: Color(0xFF8C5E3C),
    inputFocus: Color(0xFF4B2E05),
    labelText: Color(0xFF2E1C0F),
    textPrimary: Color(0xFF2E1C0F),
    textSecondary: Color(0xFF7B5A45),
    textHint: Color(0xFF7B5A45),
    subtext: Color(0xFF7B5A45),
    linkText: Color(0xFFD7B89C),
    divider: Color(0xFFCFC0A8),
    shadowColor: Color(0x1A4B2E05), // rgba(75,46,5,0.1)
    error: Color(0xFFD32F2F),
    success: Color(0xFF4B7C59),
    warning: Color(0xFFE65100),
    info: Color(0xFF1976D2),
    isDark: false,
  );

  // 2️⃣ GREEN – Organic / Wellness / Eco Businesses
  static const AppThemeData green = AppThemeData(
    name: 'Green',
    emoji: '🌿',
    description: 'Organic / Wellness / Eco - Fresh & Natural',
    background: Color(0xFFE6F2EB),
    primary: Color(0xFF145A32),
    secondary: Color(0xFF27AE60),
    accent: Color(0xFFABEBC6),
    surface: Color(0xFFDFF2E5),
    buttonBackground: Color(0xFF27AE60),
    buttonHover: Color(0xFF0F3D1A),
    inputBackground: Color(0xFFDFF2E5),
    inputBorder: Color(0xFF145A32),
    inputFocus: Color(0xFF0F3D1A),
    labelText: Color(0xFF0D2A16),
    textPrimary: Color(0xFF0D2A16),
    textSecondary: Color(0xFF4C8C5A),
    textHint: Color(0xFF4C8C5A),
    subtext: Color(0xFF4C8C5A),
    linkText: Color(0xFFABEBC6),
    divider: Color(0xFFC1E2CD),
    shadowColor: Color(0x1A145A32), // rgba(20,90,50,0.1)
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFEA580C),
    info: Color(0xFF0284C7),
    isDark: false,
  );

  // 3️⃣ BASIC / AMAZON-LIKE – Shops / Marketplaces / B2B Vendors
  static const AppThemeData basic = AppThemeData(
    name: 'Basic',
    emoji: '📦',
    description: 'Shops / Marketplaces - Professional & Clean',
    background: Color(0xFFF5F7FA),
    primary: Color(0xFF2C3E50),
    secondary: Color(0xFF34495E),
    accent: Color(0xFFFF9900),
    surface: Color(0xFFECF0F1),
    buttonBackground: Color(0xFFFF9900),
    buttonHover: Color(0xFFE68A00),
    inputBackground: Color(0xFFECF0F1),
    inputBorder: Color(0xFFBDC3C7),
    inputFocus: Color(0xFF2C3E50),
    labelText: Color(0xFF1B2838),
    textPrimary: Color(0xFF1B2838),
    textSecondary: Color(0xFF7F8C8D),
    textHint: Color(0xFF7F8C8D),
    subtext: Color(0xFF7F8C8D),
    linkText: Color(0xFFFF9900),
    divider: Color(0xFFD6D9DC),
    shadowColor: Color(0x1A2C3E50), // rgba(44,62,80,0.1)
    error: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFFF9800),
    info: Color(0xFF1976D2),
    isDark: false,
  );


  // Get all available themes
  static List<AppThemeData> get allThemes => [
    coffee,
    green,
    basic,
  ];

  // Get theme by type
  static AppThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.coffee:
        return coffee;
      case AppThemeType.green:
        return green;
      case AppThemeType.basic:
        return basic;
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
    backgroundColor: theme.buttonBackground,
    foregroundColor: theme.isDark ? theme.textPrimary : Colors.white,
    elevation: 2,
    shadowColor: theme.shadowColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceL,
      vertical: spaceM,
    ),
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return theme.buttonHover;
        }
        if (states.contains(MaterialState.pressed)) {
          return theme.buttonHover;
        }
        return null;
      },
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
        borderSide: BorderSide(color: theme.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: theme.inputFocus, width: 2),
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
      fillColor: theme.inputBackground,
    );
  }

  // Card Decoration
  static BoxDecoration cardDecoration(AppThemeData theme) => BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(largeBorderRadius),
    boxShadow: theme.cardShadow,
    border: Border.all(
      color: theme.divider,
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

// Backward compatibility layer for old AppTheme references
class AppTheme {
  // Colors - using green theme as default for compatibility
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

  // Gradients
  static LinearGradient get successGradient => LinearGradient(
    colors: [successGreen, emeraldGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static TextStyle get titleLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(largeBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(
      color: dividerColor.withOpacity(0.5),
      width: 0.5,
    ),
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
}
