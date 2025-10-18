import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Vendor Registration',
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
                          'Business Account',
                          style: AppThemes.titleMedium(widget.theme).copyWith(
                            color: widget.theme.labelText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppThemes.spaceXS),
                        Text(
                          'Register your business to start selling',
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
              'Phone Number',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                color: widget.theme.inputBackground,
                border: Border.all(
                  color: widget.phoneError != null ? widget.theme.error : widget.theme.inputBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Country code with flag
                  Padding(
                    padding: const EdgeInsets.only(left: AppThemes.spaceM, top: AppThemes.spaceM, bottom: AppThemes.spaceM, right: AppThemes.spaceM),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://flagcdn.com/w40/et.png',
                              width: 28,
                              height: 20,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: widget.theme.successGradient,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'ET',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppThemes.spaceS),
                        Text(
                          '+251',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: widget.theme.labelText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: widget.theme.divider,
                  ),
                  // Phone number input
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        widget.onValidatePhone(value);
                        context.read<OnboardingBloc>().add(UpdatePhoneNumber('+251$value'));
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: InputDecoration(
                        hintText: '912345678',
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceM, vertical: AppThemes.spaceM),
                        hintStyle: TextStyle(
                          color: widget.theme.textHint,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
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
              'We\'ll send a 6-digit OTP for verification.',
              style: TextStyle(
                fontSize: 14,
                color: widget.phoneError != null ? widget.theme.error.withOpacity(0.7) : widget.theme.textSecondary,
              ),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'Password',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                color: widget.theme.inputBackground,
                border: Border.all(
                  color: widget.theme.inputBorder,
                  width: 1.5,
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  context.read<OnboardingBloc>().add(UpdatePassword(value));
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceM, vertical: AppThemes.spaceM),
                  hintStyle: TextStyle(
                    color: widget.theme.textHint,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: widget.theme.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
