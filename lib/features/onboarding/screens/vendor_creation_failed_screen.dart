import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../bloc/onboarding_event.dart';

class VendorCreationFailedScreen extends StatelessWidget {
  final OnboardingVendorSubmissionFailed state;

  const VendorCreationFailedScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppThemes.spaceL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 60,
                      color: theme.error,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Error Title
                  Text(
                    'onboarding.submissionFailed.title'.tr(),
                    style: AppThemes.displayLarge(theme).copyWith(
                      color: theme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  
                  // Error Message
                  Text(
                    state.error,
                    style: AppThemes.bodyLarge(theme),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    decoration: BoxDecoration(
                      color: theme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                      border: Border.all(
                        color: theme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: theme.error,
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        Text(
                          'onboarding.submissionFailed.whatNext'.tr(),
                          style: AppThemes.titleMedium(theme).copyWith(
                            color: theme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceS),
                        Text(
                          'onboarding.submissionFailed.hint'.tr(),
                          style: AppThemes.bodyMedium(theme),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Action Buttons
                  Column(
                    children: [
                      AppPrimaryButton(
                        text: 'onboarding.submissionFailed.tryAgain'.tr(),
                        onPressed: () {
                          context.read<OnboardingBloc>().add(const RetryVendorSubmission());
                        },
                        width: double.infinity,
                        height: 52,
                      ),
                      const SizedBox(height: AppThemes.spaceM),
                      AppSecondaryButton(
                        text: 'onboarding.submissionFailed.contactSupport'.tr(),
                        onPressed: () {
                          ContactHelpDialog.show(context, theme);
                        },
                        width: double.infinity,
                        height: 52,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
