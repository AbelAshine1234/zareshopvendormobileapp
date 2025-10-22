import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';

class OnboardingCompactHeader extends StatelessWidget {
  final bool isHeaderCollapsed;

  const OnboardingCompactHeader({
    super.key,
    required this.isHeaderCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isHeaderCollapsed ? AppThemes.spaceS : AppThemes.spaceXL,
            horizontal: AppThemes.spaceL,
          ),
          decoration: BoxDecoration(
            color: theme.surface,
            boxShadow: isHeaderCollapsed
                ? [
                    BoxShadow(
                      color: (theme.isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              // Header row with back button and title
              Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () {
                      print('🔙 [ONBOARDING] Back button pressed, navigating to splash');
                      context.go('/splash');
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: theme.textPrimary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.surface,
                      foregroundColor: theme.textPrimary,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: isHeaderCollapsed ? 16 : 28,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                        letterSpacing: 2,
                      ),
                      child: const Text('ZARESHOP'),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: isHeaderCollapsed
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const SizedBox(height: AppThemes.spaceM),
                          Text(
                            'onboarding.welcome.vendorPortal'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
