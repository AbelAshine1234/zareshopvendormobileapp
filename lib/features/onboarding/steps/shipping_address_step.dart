import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class ShippingAddressStep extends StatefulWidget {
  final AppThemeData theme;

  const ShippingAddressStep({
    super.key,
    required this.theme,
  });

  @override
  State<ShippingAddressStep> createState() => _ShippingAddressStepState();
}

class _ShippingAddressStepState extends State<ShippingAddressStep> {
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Address',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'Where should we deliver orders and send important documents?',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Location Picker
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: AppThemes.cardDecoration(widget.theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: widget.theme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppThemes.spaceM),
                      Text(
                        'Location',
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'Tap to select location on map',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceS),
                  AppPrimaryButton(
                    text: 'Pick Location',
                    icon: Icons.location_on,
                    onPressed: () {
                      // TODO: Open Google Maps picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google Maps picker coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'Address Details',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Address Line 1
            Text(
              'Street Address',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _addressLine1Controller,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateAddressLine1(value));
              },
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'Enter street address',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Address Line 2
            Text(
              'Apartment, suite, etc. (optional)',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _addressLine2Controller,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateAddressLine2(value));
              },
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'Apartment, suite, etc.',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // City and State Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City',
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                      const SizedBox(height: AppThemes.spaceS),
                      TextField(
                        controller: _cityController,
                        onChanged: (value) {
                          context.read<OnboardingBloc>().add(UpdateCity(value));
                        },
                        decoration: AppThemes.inputDecoration(
                          widget.theme,
                          hintText: 'City',
                        ),
                        style: AppThemes.bodyMedium(widget.theme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'State/Region',
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                      const SizedBox(height: AppThemes.spaceS),
                      TextField(
                        controller: _stateController,
                        onChanged: (value) {
                          context.read<OnboardingBloc>().add(UpdateState(value));
                        },
                        decoration: AppThemes.inputDecoration(
                          widget.theme,
                          hintText: 'State/Region',
                        ),
                        style: AppThemes.bodyMedium(widget.theme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Postal Code
            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Postal Code',
                    style: AppThemes.titleMedium(widget.theme),
                  ),
                  const SizedBox(height: AppThemes.spaceS),
                  TextField(
                    controller: _postalCodeController,
                    onChanged: (value) {
                      context.read<OnboardingBloc>().add(UpdatePostalCode(value));
                    },
                    decoration: AppThemes.inputDecoration(
                      widget.theme,
                      hintText: 'Postal Code',
                    ),
                    style: AppThemes.bodyMedium(widget.theme),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
