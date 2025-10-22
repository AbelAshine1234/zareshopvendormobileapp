import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_state.dart';

class OnboardingProgressSection extends StatelessWidget {
  final OnboardingInProgress state;

  const OnboardingProgressSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'onboarding.progress.step'.tr()} ${(state.currentStep + 1)}',
                  style: AppThemes.titleLarge(theme),
                ),
                Row(
                  children: List.generate(state.totalSteps, (index) {
                    final isActive = index == state.currentStep;
                    final isCompleted = index < state.currentStep;
                    return Container(
                      margin: const EdgeInsets.only(left: AppThemes.spaceS),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive ? theme.primary : theme.accent,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceM),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: theme.accent,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                minHeight: 8,
              ),
            ),
          ],
        );
      },
    );
  }
}
