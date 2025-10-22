import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/validation_utils.dart';
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
  String? _phoneError;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _initializedFromState = false;

  String? _validatePhoneDigits(String digits) {
    // Delegate to global validator for consistency and localization
    return ValidationUtils.validateEthiopianPhone(digits);
  }

  String _digitsOnlyFromStatePhone(String phoneWithCode) {
    if (phoneWithCode.startsWith('+251')) {
      return phoneWithCode.replaceFirst('+251', '');
    }
    return phoneWithCode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        if (!_initializedFromState) {
          final digits = _digitsOnlyFromStatePhone(state.data.phoneNumber);
          _phoneController.text = digits;
          _passwordController.text = state.data.password;
          _initializedFromState = true;
        }
        
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
            PhoneInput(
              theme: widget.theme,
              controller: _phoneController,
              label: 'onboarding.phoneNumber.title'.tr(),
              onChangedDigitsOnly: (value) {
                // Local validation and error display using global theme styles
                final error = _validatePhoneDigits(value);
                setState(() {
                  _phoneError = error;
                });
                widget.onValidatePhone(value);
                context.read<OnboardingBloc>().add(UpdatePhoneNumber('+251$value'));
              },
              errorText: _phoneError ?? widget.phoneError,
              countryCode: '+251',
              hintDigits: 'onboarding.phoneNumber.phoneHint'.tr(),
              helperText: 'onboarding.phoneNumber.infoText'.tr(),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'onboarding.phoneNumber.passwordLabel'.tr(),
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            PasswordInput(
              theme: widget.theme,
              controller: _passwordController,
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
