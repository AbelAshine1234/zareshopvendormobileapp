import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../bloc/onboarding_event.dart';

class OnboardingBottomNavigation extends StatelessWidget {
  final OnboardingInProgress state;

  const OnboardingBottomNavigation({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          color: theme.surface,
          child: Row(
            children: [
              // Previous button (only show if not on first step)
              if (state.currentStep > 0) ...[
                Expanded(
                  flex: 1,
                  child: AppSecondaryButton(
                    text: 'common.back'.tr(),
                    onPressed: () {
                      print('🎯 [ONBOARDING_MAIN] Previous button pressed');
                      print('🎯 [ONBOARDING_MAIN] Current step: ${state.currentStep}');
                      print('🎯 [ONBOARDING_MAIN] Dispatching PreviousStep event');
                      context.read<OnboardingBloc>().add(const PreviousStep());
                    },
                    height: 52,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
              ],
              // Continue/Finish button
              Expanded(
                flex: state.currentStep > 0 ? 2 : 1,
                child: AppPrimaryButton(
                  text: state.isLastStep
                      ? 'onboarding.progress.finishSetup'.tr()
                      : 'common.continue'.tr(),
                  onPressed: state.canProceed
                      ? () {
                          print('🎯 [ONBOARDING_MAIN] Continue button pressed');
                          print('🎯 [ONBOARDING_MAIN] Current step: ${state.currentStep}');
                          print('🎯 [ONBOARDING_MAIN] Is last step: ${state.isLastStep}');
                          print('🎯 [ONBOARDING_MAIN] Can proceed: ${state.canProceed}');
                          print('🎯 [ONBOARDING_MAIN] Dispatching NextStep event');
                          context.read<OnboardingBloc>().add(const NextStep());
                        }
                      : null,
                  enabled: state.canProceed,
                  height: 52,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
