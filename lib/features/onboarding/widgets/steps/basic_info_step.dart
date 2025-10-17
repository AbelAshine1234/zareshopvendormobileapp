import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/shared.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../bloc/onboarding_state.dart';
import '../common/category_dropdown.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();

        return AppStepCard(
          title: 'Business Information',
          subtitle: 'Tell us about yourself and your business',
          icon: Icons.business,
          child: Column(
            children: [
              // Name Fields Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'First Name',
                      hint: 'Enter first name',
                      required: true,
                      onChanged: (value) {
                        context.read<OnboardingBloc>().add(UpdateFirstName(value));
                        // Auto-update full name
                        final lastName = state.data.lastName;
                        final fullName = '$value $lastName'.trim();
                        context.read<OnboardingBloc>().add(UpdateFullName(fullName));
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceM),
                  Expanded(
                    child: AppTextField(
                      label: 'Last Name',
                      hint: 'Enter last name',
                      required: true,
                      onChanged: (value) {
                        context.read<OnboardingBloc>().add(UpdateLastName(value));
                        // Auto-update full name
                        final firstName = state.data.firstName;
                        final fullName = '$firstName $value'.trim();
                        context.read<OnboardingBloc>().add(UpdateFullName(fullName));
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spaceM),
              
              // Business Name
              AppTextField(
                label: 'Business Name',
                hint: 'Enter your business name',
                required: true,
                onChanged: (value) => context.read<OnboardingBloc>().add(
                  UpdateBusinessName(value),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Business name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spaceM),
              
              // Email
              AppEmailField(
                onChanged: (value) => context.read<OnboardingBloc>().add(
                  UpdateEmail(value),
                ),
              ),
              
              const SizedBox(height: AppTheme.spaceM),
              
              // Business Description
              AppTextField(
                label: 'Business Description',
                hint: 'Describe what you sell or the services you provide',
                maxLines: 3,
                required: true,
                onChanged: (value) => context.read<OnboardingBloc>().add(
                  UpdateBusinessDescription(value),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spaceM),
              
              // Category Selection
              const CategoryDropdown(),
              
              const SizedBox(height: AppTheme.spaceXL),
              
              // Navigation Buttons
              AppButtonGroup(
                primaryText: 'Continue',
                onPrimaryPressed: () {
                  context.read<OnboardingBloc>().add(const NextStep());
                },
                secondaryText: 'Back',
                onSecondaryPressed: () {
                  context.read<OnboardingBloc>().add(const PreviousStep());
                },
                primaryEnabled: _isStepValid(state.data),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isStepValid(dynamic data) {
    return data.firstName.isNotEmpty &&
           data.lastName.isNotEmpty &&
           data.businessName.isNotEmpty &&
           data.email.isNotEmpty &&
           data.businessDescription.isNotEmpty &&
           data.category.isNotEmpty;
  }
}
