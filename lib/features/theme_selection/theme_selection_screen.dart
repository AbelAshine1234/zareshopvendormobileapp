import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/theme/app_themes.dart';
import '../onboarding/screens/onboarding_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _buttonController;
  
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsFade;
  late Animation<double> _buttonScale;

  AppThemeType? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));
    
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );
    
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsController.forward();
  }

  void _onThemeSelected(AppThemeType themeType) {
    setState(() {
      _selectedTheme = themeType;
    });
    _buttonController.forward();
    
    // Apply theme immediately for preview
    context.read<ThemeProvider>().setTheme(themeType);
  }

  void _continueToOnboarding() {
    if (_selectedTheme != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _buttonController.dispose();
    super.dispose();
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
                    AnimatedBuilder(
                      animation: _headerController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _headerSlide,
                          child: FadeTransition(
                            opacity: _headerFade,
                            child: Column(
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
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppThemes.spaceXXL),
                    
                    // Theme Cards
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _cardsController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _cardsFade,
                            child: ListView.builder(
                              itemCount: AppThemes.allThemes.length,
                              itemBuilder: (context, index) {
                                final themeData = AppThemes.allThemes[index];
                                final themeType = AppThemeType.values[index];
                                final isSelected = _selectedTheme == themeType;
                                
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(
                                    milliseconds: 300 + (index * 100),
                                  ),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: _buildThemeCard(
                                          themeData,
                                          themeType,
                                          isSelected,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Continue Button
                    if (_selectedTheme != null)
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonScale.value,
                            child: Container(
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
                          );
                        },
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
