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
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _subcityController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _subcityController.dispose();
    _woredaController.dispose();
    _stateController.dispose();
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
            
            // City and Subcity Row
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
                          hintText: 'e.g., Addis Ababa',
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
                        'Subcity',
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                      const SizedBox(height: AppThemes.spaceS),
                      TextField(
                        controller: _subcityController,
                        onChanged: (value) {
                          context.read<OnboardingBloc>().add(UpdateSubcity(value));
                        },
                        decoration: AppThemes.inputDecoration(
                          widget.theme,
                          hintText: 'e.g., Bole',
                        ),
                        style: AppThemes.bodyMedium(widget.theme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Woreda and State Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Woreda',
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                      const SizedBox(height: AppThemes.spaceS),
                      TextField(
                        controller: _woredaController,
                        onChanged: (value) {
                          context.read<OnboardingBloc>().add(UpdateWoreda(value));
                        },
                        decoration: AppThemes.inputDecoration(
                          widget.theme,
                          hintText: 'e.g., 01',
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
                          hintText: 'e.g., Addis Ababa',
                        ),
                        style: AppThemes.bodyMedium(widget.theme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
