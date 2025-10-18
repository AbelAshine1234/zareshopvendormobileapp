import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/theme/app_themes.dart';
import '../auth/screens/login_screen.dart';
import '../../core/services/api_service.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../onboarding/screens/onboarding_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check if user has a valid token
      final token = await ApiService.getToken();
      
      if (token != null) {
        // Verify token is still valid by getting current user
        final userResult = await ApiService.getCurrentUser();
        
        if (userResult['success'] == true) {
          setState(() {
            _isAuthenticated = true;
            _isCheckingAuth = false;
          });
          
          // Navigate to dashboard
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }
          return;
        }
      }
      
      // No valid token or user data
      setState(() {
        _isAuthenticated = false;
        _isCheckingAuth = false;
      });
    } catch (e) {
      // Error checking auth, show login screen
      setState(() {
        _isAuthenticated = false;
        _isCheckingAuth = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OnboardingMainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Logo Section
                  Column(
                    children: [
                      // App Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Name
                      Text(
                        'ZareShop',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Vendor Portal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Action Buttons (only show when not checking auth)
                  if (!_isCheckingAuth) ...[
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _navigateToSignup,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(
                            color: theme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Loading indicator (only show when checking auth)
                  if (_isCheckingAuth) ...[
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Footer
                  Text(
                    'Manage your shop and grow your business',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
