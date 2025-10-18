import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/theme/app_themes.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print('🎯 [SPLASH_SCREEN] initState() called');
    print('🎯 [SPLASH_SCREEN] Splash screen is loading...');
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Check authentication status when splash screen loads
    print('🎯 [SPLASH_SCREEN] Checking authentication status...');
    context.read<AuthBloc>().add(const CheckAuthenticationStatus());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    print('🎯 [SPLASH_SCREEN] Login button pressed, navigating to /login');
    context.go('/login');
  }

  void _navigateToSignup() {
    print('🎯 [SPLASH_SCREEN] Sign up button pressed, navigating to /onboarding');
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 [SPLASH_SCREEN] build() called - rendering splash screen UI');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🎯 [SPLASH_SCREEN] Auth state changed: ${state.runtimeType}');
        if (state is AuthAuthenticated) {
          print('🎯 [SPLASH_SCREEN] User is authenticated, redirecting to dashboard');
          context.go('/');
        } else if (state is AuthUnauthenticated) {
          print('🎯 [SPLASH_SCREEN] User is not authenticated, showing splash screen');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('🎯 [SPLASH_SCREEN] Building with auth state: ${state.runtimeType}');
          
          if (state is AuthChecking) {
            print('🎯 [SPLASH_SCREEN] Checking authentication, showing loading');
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // Show splash screen for unauthenticated users or any other state
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              print('🎯 [SPLASH_SCREEN] Theme loaded: ${theme.runtimeType}');
              
              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primary.withOpacity(0.1),
                        theme.background,
                        theme.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Spacer(),
                          
                          // Animated Logo Section
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Column(
                                children: [
                                  // App Logo with splash image
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primary.withOpacity(0.3),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.asset(
                                        'assets/logo/logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('❌ [SPLASH_SCREEN] Error loading logo image: $error');
                                          // Fallback to icon if image not found
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: theme.primary,
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // App Name with beautiful typography
                                  Text(
                                    'ZareShop',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: theme.textPrimary,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: theme.primary.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    'Vendor Portal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 80),
                          
                          // Action Buttons with beautiful design
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                // Login Button
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [theme.primary, theme.primary.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: _navigateToLogin,
                                      child: const Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1,
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
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.primary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primary.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: _navigateToSignup,
                                      child: Center(
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: theme.primary,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Footer with theme selection
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Choose your theme',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Theme selection buttons
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildThemeButton(
                                      context,
                                      themeProvider,
                                      'Coffee',
                                      AppThemeType.coffee,
                                      '☕️',
                                    ),
                                    _buildThemeButton(
                                      context,
                                      themeProvider,
                                      'Green',
                                      AppThemeType.green,
                                      '🌿',
                                    ),
                                    _buildThemeButton(
                                      context,
                                      themeProvider,
                                      'Basic',
                                      AppThemeType.basic,
                                      '⚪',
                                    ),
                                    _buildThemeButton(
                                      context,
                                      themeProvider,
                                      'Mustard',
                                      AppThemeType.mustard,
                                      '🟡',
                                    ),
                                    _buildThemeButton(
                                      context,
                                      themeProvider,
                                      'Beige',
                                      AppThemeType.beige,
                                      '🟤',
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                Text(
                                  'Manage your shop and grow your business',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textSecondary.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 24),
                              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? themeProvider.currentTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? themeProvider.currentTheme.primary
                : themeProvider.currentTheme.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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