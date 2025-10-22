import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/utils/theme/theme_provider.dart';
import '../../shared/utils/theme/app_themes.dart';
import '../../core/services/localization_service.dart';
import '../../shared/widgets/selectors/language_switcher_button.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  int _currentLetterIndex = 0;
  final List<String> _letters = ['Z', 'A', 'R', 'E', 'S', 'H', 'O', 'P'];

  @override
  void initState() {
    super.initState();
    print('🎯 [SPLASH_SCREEN] Initializing new vendor-focused splash screen');
    print('🎯 [SPLASH_SCREEN] Using theme-specific logos from assets/logo/');
    
    _initializeLoading();
    
    // Check authentication status after a delay to ensure splash screen is shown first
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        print('🎯 [SPLASH_SCREEN] Checking authentication status after delay');
        context.read<AuthBloc>().add(const CheckAuthenticationStatus());
      }
    });
  }

  void _initializeLoading() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Start letter animation after loading
      _startLetterAnimation();
    }
  }

  void _startLetterAnimation() async {
    for (int i = 0; i < _letters.length; i++) {
      if (mounted) {
        setState(() {
          _currentLetterIndex = i;
        });
        
        // Wait 100ms before showing next letter
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void _navigateToLogin() {
    print('🎯 [SPLASH_SCREEN] Login button pressed, navigating to /login');
    context.go('/login');
  }

  void _navigateToSignup() {
    print('🎯 [SPLASH_SCREEN] Sign up button pressed, navigating to /onboarding');
    context.go('/onboarding');
  }

  String _getThemeLogoPath(AppThemeType themeType) {
    final path = switch (themeType) {
      AppThemeType.coffee => 'assets/logo/logo-coffe.png',
      AppThemeType.green => 'assets/logo/logo-green.png',
      AppThemeType.basic => 'assets/logo/logo-basic.png',
    };
    print('🎯 [SPLASH_SCREEN] Selected logo path: $path for theme: $themeType');
    return path;
  }


  @override
  Widget build(BuildContext context) {
    print('🎯 [SPLASH_SCREEN] Building splash screen widget');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🎯 [SPLASH_SCREEN] Auth state changed: ${state.runtimeType}');
        
        // Only auto-navigate if we're not already on the splash screen
        // This allows users to manually navigate back to splash screen
        final currentLocation = GoRouterState.of(context).uri.path;
        if (currentLocation != '/splash') {
          if (state is AuthAuthenticated) {
            print('🎯 [SPLASH_SCREEN] User is authenticated and approved, navigating to dashboard');
            context.go('/');
          } else if (state is AuthWaitingApproval) {
            print('🎯 [SPLASH_SCREEN] User is authenticated but waiting for approval, navigating to admin approval');
            context.go('/admin-approval');
          }
        } else {
          print('🎯 [SPLASH_SCREEN] Already on splash screen, not auto-navigating');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              
              // Show loading screen
              if (_isLoading) {
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.background,
                          theme.primary.withValues(alpha: 0.05),
                          theme.background,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: theme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.background,
                        theme.primary.withValues(alpha: 0.05),
                        theme.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          
                          // Logo Section
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: Image.asset(
                              _getThemeLogoPath(themeProvider.currentThemeType),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ [SPLASH_SCREEN] Error loading asset: $error');
                                return Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Icon(
                                    Icons.store_outlined,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 60),
                          
                          // Brand Name with Letter-by-Letter Animation
                          SizedBox(
                            height: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_letters.length, (index) {
                                final letter = _letters[index];
                                final isVisible = index <= _currentLetterIndex;
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      color: isVisible ? theme.textPrimary : Colors.transparent,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Subtitle
                          Text(
                            'splash.subtitlePortal'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Tagline
                          Text(
                            'splash.tagline'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.textSecondary.withValues(alpha: 0.8),
                              letterSpacing: 2.0,
                            ),
                          ),
                          
                          const Spacer(flex: 2),
                          
                          // Action Buttons
                          Column(
                            children: [
                              // Login Button
                              Container(
                                width: double.infinity,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: theme.primary,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: _navigateToLogin,
                                    child: Center(
                                      child: Text(
                                        'splash.loginCta'.tr(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Sign Up Button
                              Container(
                                width: double.infinity,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: theme.primary,
                                    width: 2.5,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: _navigateToSignup,
                                    child: Center(
                                      child: Text(
                                        'splash.signupCta'.tr(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: theme.primary,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Theme Selection
                          Column(
                            children: [
                              Text(
                                'splash.chooseStyle'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Theme selection buttons
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildThemeButton(
                                    context,
                                    themeProvider,
                                    'splash.theme.coffee'.tr(),
                                    AppThemeType.coffee,
                                    '☕',
                                  ),
                                  _buildThemeButton(
                                    context,
                                    themeProvider,
                                    'splash.theme.basic'.tr(),
                                    AppThemeType.basic,
                                    '⚪',
                                  ),
                                  _buildThemeButton(
                                    context,
                                    themeProvider,
                                    'splash.theme.green'.tr(),
                                    AppThemeType.green,
                                    '🌿',
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Text(
                                'splash.footer'.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textSecondary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    ThemeProvider themeProvider,
    String label,
    AppThemeType themeType,
    String emoji,
  ) {
    final isSelected = themeProvider.currentThemeType == themeType;
    
    return GestureDetector(
      onTap: () {
        print('🎨 [SPLASH_SCREEN] Theme changed to: $label');
        themeProvider.setTheme(themeType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? themeProvider.currentTheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? themeProvider.currentTheme.primary
                : themeProvider.currentTheme.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? themeProvider.currentTheme.primary
                    : themeProvider.currentTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}