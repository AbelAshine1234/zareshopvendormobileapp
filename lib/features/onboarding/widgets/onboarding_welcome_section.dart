import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';

class OnboardingWelcomeSection extends StatelessWidget {
  final bool isHeaderCollapsed;

  const OnboardingWelcomeSection({
    super.key,
    required this.isHeaderCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isHeaderCollapsed ? 0.0 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isHeaderCollapsed ? 0 : null,
            child: isHeaderCollapsed
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'onboarding.welcome.title'.tr(),
                        style: AppThemes.displayLarge(theme),
                      ),
                      const SizedBox(height: AppThemes.spaceM),
                      Text(
                        'onboarding.welcome.subtitle'.tr(),
                        style: AppThemes.bodyLarge(theme),
                      ),
                      const SizedBox(height: AppThemes.spaceM),
                      Text(
                        'onboarding.welcome.description'.tr(),
                        style: AppThemes.bodyLarge(theme),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
