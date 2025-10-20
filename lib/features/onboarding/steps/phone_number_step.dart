import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/inputs/phone_input.dart';
import '../../../shared/widgets/inputs/password_input.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class PhoneNumberStep extends StatefulWidget {
  final AppThemeData theme;
  final String? phoneError;
  final Function(String) onValidatePhone;

  const PhoneNumberStep({
    super.key,
    required this.theme,
    this.phoneError,
    required this.onValidatePhone,
  });

  @override
  State<PhoneNumberStep> createState() => _PhoneNumberStepState();
}

class _PhoneNumberStepState extends State<PhoneNumberStep> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'onboarding.phoneNumber.title'.tr(),
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: widget.theme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceS),
                    decoration: BoxDecoration(
                      color: widget.theme.primary,
                      borderRadius: BorderRadius.circular(AppThemes.spaceS),
                    ),
                    child: Icon(
                      Icons.business,
                      color: widget.theme.isDark ? widget.theme.textPrimary : Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'onboarding.phoneNumber.subtitle'.tr(),
                          style: AppThemes.titleMedium(widget.theme).copyWith(
                            color: widget.theme.labelText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppThemes.spaceXS),
                        Text(
                          'onboarding.phoneNumber.subtitle'.tr(),
                          style: AppThemes.bodySmall(widget.theme).copyWith(
                            color: widget.theme.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'onboarding.phoneNumber.title'.tr(),
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            PhoneInput(
              theme: widget.theme,
              onChangedDigitsOnly: (value) {
                widget.onValidatePhone(value);
                context.read<OnboardingBloc>().add(UpdatePhoneNumber('+251$value'));
              },
              errorText: widget.phoneError,
              countryCode: '+251',
              hintDigits: 'onboarding.phoneNumber.phoneHint'.tr(),
            ),
            const SizedBox(height: AppThemes.spaceM),
            if (widget.phoneError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppThemes.spaceS),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: widget.theme.error,
                      size: 16,
                    ),
                    const SizedBox(width: AppThemes.spaceXS),
                    Text(
                      widget.phoneError!,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.theme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'onboarding.phoneNumber.infoText'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: widget.phoneError != null ? widget.theme.error.withOpacity(0.7) : widget.theme.textSecondary,
              ),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'onboarding.phoneNumber.passwordLabel'.tr(),
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            PasswordInput(
              theme: widget.theme,
              controller: null,
              obscureText: !_isPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdatePassword(value));
              },
              hintText: 'onboarding.phoneNumber.passwordHint'.tr(),
            ),
          ],
        );
      },
    );
  }
}
