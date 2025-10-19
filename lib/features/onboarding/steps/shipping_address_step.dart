import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
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
              'onboarding.shippingAddress.title'.tr(),
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'onboarding.shippingAddress.subtitle'.tr(),
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
                        'onboarding.shippingAddress.location'.tr(),
                        style: AppThemes.titleMedium(widget.theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'onboarding.shippingAddress.tapToSelectOnMap'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceS),
                  AppPrimaryButton(
                    text: 'onboarding.shippingAddress.pickLocation'.tr(),
                    icon: Icons.location_on,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('common.comingSoon'.tr())),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'onboarding.shippingAddress.addressDetails'.tr(),
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
                        'onboarding.shippingAddress.city'.tr(),
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
                          hintText: 'onboarding.shippingAddress.cityHint'.tr(),
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
                        'onboarding.shippingAddress.subcity'.tr(),
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
                          hintText: 'onboarding.shippingAddress.subcityHint'.tr(),
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
                        'onboarding.shippingAddress.woreda'.tr(),
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
                          hintText: 'onboarding.shippingAddress.woredaHint'.tr(),
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
                        'onboarding.shippingAddress.region'.tr(),
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
                          hintText: 'onboarding.shippingAddress.regionHint'.tr(),
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
