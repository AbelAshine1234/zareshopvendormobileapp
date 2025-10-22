import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_state.dart';
import '../steps/steps.dart';
import '../../../shared/screens/admin_approval_screen.dart';

class OnboardingStepCard extends StatelessWidget {
  final OnboardingInProgress state;
  final List<Map<String, dynamic>> subscriptions;
  final bool loadingSubscriptions;
  final List<Map<String, dynamic>> categories;
  final bool loadingCategories;
  final VoidCallback onFetchSubscriptions;

  const OnboardingStepCard({
    super.key,
    required this.state,
    required this.subscriptions,
    required this.loadingSubscriptions,
    required this.categories,
    required this.loadingCategories,
    required this.onFetchSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          padding: const EdgeInsets.all(AppThemes.spaceXL),
          decoration: AppThemes.cardDecoration(theme),
          child: _getStepWidget(state.currentStep, theme),
        );
      },
    );
  }

  Widget _getStepWidget(int step, AppThemeData theme) {
    if (step == 6 && subscriptions.isEmpty && !loadingSubscriptions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onFetchSubscriptions();
      });
    }
    
    switch (step) {
      case 0:
        return PhoneNumberStep(
          theme: theme,
          phoneError: null, // This should be passed from parent
          onValidatePhone: (phone) {}, // This should be passed from parent
        );
      case 1:
        return OTPStep(
          theme: theme,
          otpCountdown: 60, // This should be passed from parent
          onResendOTP: () {}, // This should be passed from parent
        );
      case 2:
        return BasicInfoStep(
          theme: theme,
          categories: categories,
          loadingCategories: loadingCategories,
        );
      case 3:
        return ShippingAddressStep(theme: theme);
      case 4:
        return DocumentsStep(theme: theme);
      case 5:
        return PayoutStep(theme: theme);
      case 6:
        return SubscriptionStep(
          theme: theme,
          subscriptions: subscriptions,
          loadingSubscriptions: loadingSubscriptions,
          onFetchSubscriptions: onFetchSubscriptions,
        );
      case 7:
        return const AdminApprovalScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
