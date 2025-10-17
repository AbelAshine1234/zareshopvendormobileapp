import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/shared.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../bloc/onboarding_state.dart';

class PhoneNumberStep extends StatefulWidget {
  const PhoneNumberStep({super.key});

  @override
  State<PhoneNumberStep> createState() => _PhoneNumberStepState();
}

class _PhoneNumberStepState extends State<PhoneNumberStep> {
  String? _phoneError;

  void _validateEthiopianPhone(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _phoneError = null;
      } else if (phone.length != 9) {
        _phoneError = 'Phone number must be 9 digits';
      } else if (!phone.startsWith('9')) {
        _phoneError = 'Ethiopian mobile numbers start with 9';
      } else {
        _phoneError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();

        return AppStepCard(
          title: 'Phone Number Verification',
          subtitle: 'Enter your Ethiopian mobile number to get started',
          icon: Icons.phone,
          child: Column(
            children: [
              // Phone Number Input with Country Code
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  color: AppTheme.backgroundSecondary,
                  border: Border.all(
                    color: _phoneError != null 
                        ? AppTheme.errorRed 
                        : AppTheme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    // Country Flag and Code
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spaceM),
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
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryGreen,
                                          AppTheme.darkGreen
                                        ],
                                      ),
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
                          const SizedBox(width: AppTheme.spaceS),
                          const Text(
                            '+251',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.dividerColor,
                    ),
                    
                    // Phone Input
                    Expanded(
                      child: AppPhoneField(
                        label: '',
                        onChanged: (value) {
                          _validateEthiopianPhone(value);
                          context.read<OnboardingBloc>().add(
                            UpdatePhoneNumber('+251$value'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Error Message
              if (_phoneError != null) ...[
                const SizedBox(height: AppTheme.spaceS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spaceM),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.spaceS),
                    border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spaceS),
                      Expanded(
                        child: Text(
                          _phoneError!,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppTheme.spaceL),
              
              // Password Field
              AppPasswordField(
                label: 'Create Password',
                onChanged: (value) => context.read<OnboardingBloc>().add(
                  UpdatePassword(value),
                ),
              ),
              
              const SizedBox(height: AppTheme.spaceXL),
              
              // Continue Button
              AppPrimaryButton(
                text: 'Continue',
                icon: Icons.arrow_forward,
                enabled: state.data.phoneNumber.isNotEmpty && 
                         state.data.password.isNotEmpty && 
                         _phoneError == null,
                onPressed: () {
                  context.read<OnboardingBloc>().add(const NextStep());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
