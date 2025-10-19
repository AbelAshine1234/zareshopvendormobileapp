import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/theme/app_themes.dart';
import '../../core/services/localization_service.dart';
import '../../shared/widgets/language_selector/language_switcher_button.dart';
import '../onboarding/screens/onboarding_main_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  AppThemeType? _selectedTheme;

  @override
  void initState() {
    super.initState();
    // Remove animations for better performance
  }

  void _onThemeSelected(AppThemeType themeType) {
    setState(() {
      _selectedTheme = themeType;
    });
    
    // Apply theme immediately for preview
    context.read<ThemeProvider>().setTheme(themeType);
  }

  void _continueToOnboarding() {
    if (_selectedTheme != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingMainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.background,
                  theme.accent.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppThemes.spaceL),
                child: Column(
                  children: [
                    // Header
                    Column(
                      children: [
                                const SizedBox(height: AppThemes.spaceXL),
                                Icon(
                                  Icons.palette_outlined,
                                  size: 64,
                                  color: theme.primary,
                                ),
                                const SizedBox(height: AppThemes.spaceL),
                                Text(
                                  'Choose Your Style',
                                  style: AppThemes.displayMedium(theme),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppThemes.spaceS),
                                Text(
                                  'Select a theme that matches your personality',
                                  style: AppThemes.bodyMedium(theme),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                      ),
                    
                    const SizedBox(height: AppThemes.spaceXXL),
                    
                    // Theme Cards
                    Expanded(
                      child: ListView.builder(
                              itemCount: AppThemes.allThemes.length,
                              itemBuilder: (context, index) {
                                final themeData = AppThemes.allThemes[index];
                                // Map theme data to theme type
                                AppThemeType themeType;
                                switch (index) {
                                  case 0:
                                    themeType = AppThemeType.coffee;
                                    break;
                                  case 1:
                                    themeType = AppThemeType.green;
                                    break;
                                  case 2:
                                    themeType = AppThemeType.basic;
                                    break;
                                  default:
                                    themeType = AppThemeType.basic;
                                }
                                final isSelected = _selectedTheme == themeType;
                                
                                return _buildThemeCard(
                                  themeData,
                                  themeType,
                                  isSelected,
                                );
                              },
                            ),
                      ),
                    
                    // Continue Button
                    if (_selectedTheme != null)
                      Container(
                              width: double.infinity,
                              height: AppThemes.buttonHeight,
                              margin: const EdgeInsets.only(top: AppThemes.spaceL),
                              child: ElevatedButton(
                                onPressed: _continueToOnboarding,
                                style: AppThemes.primaryButtonStyle(theme),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: AppThemes.buttonText(theme),
                                    ),
                                    const SizedBox(width: AppThemes.spaceS),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: theme.isDark ? theme.textPrimary : Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    AppThemeData themeData,
    AppThemeType themeType,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onThemeSelected(themeType),
          borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(AppThemes.spaceL),
            decoration: BoxDecoration(
              gradient: themeData.cardGradient,
              borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
              border: Border.all(
                color: isSelected ? themeData.primary : themeData.accent,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: themeData.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : themeData.cardShadow,
            ),
            child: Row(
              children: [
                // Theme Preview
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: themeData.primaryGradient,
                    borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      themeData.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppThemes.spaceL),
                
                // Theme Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            themeData.name,
                            style: AppThemes.titleLarge(themeData).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: AppThemes.spaceS),
                            Icon(
                              Icons.check_circle,
                              color: themeData.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppThemes.spaceXS),
                      Text(
                        themeData.description,
                        style: AppThemes.bodySmall(themeData),
                      ),
                      const SizedBox(height: AppThemes.spaceS),
                      
                      // Color Preview
                      Row(
                        children: [
                          _buildColorDot(themeData.primary, 'Primary'),
                          const SizedBox(width: AppThemes.spaceS),
                          _buildColorDot(themeData.secondary, 'Secondary'),
                          const SizedBox(width: AppThemes.spaceS),
                          _buildColorDot(themeData.accent, 'Accent'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? themeData.primary : Colors.transparent,
                    border: Border.all(
                      color: themeData.primary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: themeData.isDark ? themeData.textPrimary : Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
