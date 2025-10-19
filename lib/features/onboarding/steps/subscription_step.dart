import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class SubscriptionStep extends StatefulWidget {
  final AppThemeData theme;
  final List<Map<String, dynamic>> subscriptions;
  final bool loadingSubscriptions;
  final VoidCallback onFetchSubscriptions;

  const SubscriptionStep({
    super.key,
    required this.theme,
    required this.subscriptions,
    required this.loadingSubscriptions,
    required this.onFetchSubscriptions,
  });

  @override
  State<SubscriptionStep> createState() => _SubscriptionStepState();
}

class _SubscriptionStepState extends State<SubscriptionStep> {
  int? _selectedSubscriptionId;
  bool _agreeTermsCheck = false;

  @override
  void initState() {
    super.initState();
    print('🎯 [SUBSCRIPTION_STEP] Widget initialized');
    print('🎯 [SUBSCRIPTION_STEP] Selected subscription: $_selectedSubscriptionId');
    print('🎯 [SUBSCRIPTION_STEP] Agree terms: $_agreeTermsCheck');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync with BLoC state when widget is built
    final currentState = context.read<OnboardingBloc>().state;
    if (currentState is OnboardingInProgress) {
      if (mounted) {
        setState(() {
          _selectedSubscriptionId = currentState.data.selectedSubscriptionId;
          _agreeTermsCheck = currentState.data.agreeTermsCheck;
        });
      }
    }
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final bool isSelected = _selectedSubscriptionId == subscription['id'];
    final features = subscription['features'] as List<dynamic>? ?? [];
    
    return GestureDetector(
      onTap: () {
        print('🎯 [SUBSCRIPTION_STEP] Subscription card tapped');
        print('🎯 [SUBSCRIPTION_STEP] Subscription ID: ${subscription['id']}');
        print('🎯 [SUBSCRIPTION_STEP] Subscription name: ${subscription['name']}');
        setState(() {
          _selectedSubscriptionId = subscription['id'];
        });
        print('🎯 [SUBSCRIPTION_STEP] Updated selected subscription: $_selectedSubscriptionId');
        context.read<OnboardingBloc>().add(UpdateSubscription(subscription['id']));
        print('🎯 [SUBSCRIPTION_STEP] UpdateSubscription event dispatched');
      },
      child: Container(
        padding: const EdgeInsets.all(AppThemes.spaceL),
        decoration: BoxDecoration(
          color: isSelected ? widget.theme.primary.withValues(alpha: 0.1) : widget.theme.surface,
          borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
          border: Border.all(
            color: isSelected ? widget.theme.primary : widget.theme.accent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: widget.theme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription['name'] ?? 'Unknown Plan',
                  style: AppThemes.titleLarge(widget.theme).copyWith(
                    color: isSelected ? widget.theme.primary : widget.theme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.theme.primary : widget.theme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? widget.theme.primary : widget.theme.accent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.white : widget.theme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSelected ? 'Selected' : 'Select',
                        style: AppThemes.bodySmall(widget.theme).copyWith(
                          color: isSelected ? Colors.white : widget.theme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subscription['price']?.toString() ?? '0'}',
                  style: AppThemes.displayMedium(widget.theme).copyWith(
                    color: isSelected ? widget.theme.primary : widget.theme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceXS),
                Text(
                  'ETB',
                  style: AppThemes.bodyLarge(widget.theme).copyWith(
                    color: widget.theme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceXS),
                Text(
                  '/ ${subscription['duration'] ?? 'month'}',
                  style: AppThemes.bodyMedium(widget.theme).copyWith(
                    color: widget.theme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'Features:',
              style: AppThemes.labelLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppThemes.spaceXS),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: widget.theme.success,
                    size: 16,
                  ),
                  const SizedBox(width: AppThemes.spaceS),
                  Expanded(
                    child: Text(
                      feature.toString(),
                      style: AppThemes.bodySmall(widget.theme),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
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
              'Choose Your Plan',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            Text(
              'Select a subscription plan to get started',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            if (widget.loadingSubscriptions) ...[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(widget.theme.primary),
                    ),
                    const SizedBox(height: AppThemes.spaceM),
                    Text(
                      'Loading subscription plans...',
                      style: AppThemes.bodyMedium(widget.theme),
                    ),
                  ],
                ),
              ),
            ] else if (widget.subscriptions.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceXL),
                decoration: AppThemes.cardDecoration(widget.theme),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: widget.theme.error,
                    ),
                    const SizedBox(height: AppThemes.spaceM),
                    Text(
                      'Failed to load subscription plans',
                      style: AppThemes.titleMedium(widget.theme).copyWith(
                        color: widget.theme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppThemes.spaceS),
                    Text(
                      'Please check your internet connection and try again',
                      style: AppThemes.bodyMedium(widget.theme),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppThemes.spaceM),
                    AppPrimaryButton(
                      text: 'Retry',
                      onPressed: widget.onFetchSubscriptions,
                      width: 120,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.subscriptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppThemes.spaceM),
                    child: _buildSubscriptionCard(widget.subscriptions[index]),
                  );
                },
              ),
            ],
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Terms Agreement Checkbox
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.surface,
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: _agreeTermsCheck ? widget.theme.primary : widget.theme.accent,
                  width: _agreeTermsCheck ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreeTermsCheck,
                    onChanged: (value) {
                      print('🎯 [SUBSCRIPTION_STEP] Terms checkbox changed: $value');
                      setState(() {
                        _agreeTermsCheck = value ?? false;
                      });
                      print('🎯 [SUBSCRIPTION_STEP] Updated agree terms: $_agreeTermsCheck');
                      context.read<OnboardingBloc>().add(ToggleTermsAgreement(_agreeTermsCheck));
                      print('🎯 [SUBSCRIPTION_STEP] ToggleTermsAgreement event dispatched');
                    },
                    activeColor: widget.theme.primary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: AppThemes.bodyMedium(widget.theme),
                          ),
                          TextSpan(
                            text: 'subscription terms and conditions',
                            style: AppThemes.bodyMedium(widget.theme).copyWith(
                              color: widget.theme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: widget.theme.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.theme.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Benefits',
                          style: AppThemes.labelLarge(widget.theme).copyWith(
                            color: widget.theme.info,
                          ),
                        ),
                        const SizedBox(height: AppThemes.spaceXS),
                        Text(
                          '• You can upgrade or downgrade your plan anytime\n• All plans include customer support\n• Payment is processed securely\n• Cancel anytime with no hidden fees',
                          style: AppThemes.bodySmall(widget.theme).copyWith(
                            color: widget.theme.info,
                          ),
                        ),
                      ],
                    ),
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
