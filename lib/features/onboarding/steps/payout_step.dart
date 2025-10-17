import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class PayoutStep extends StatefulWidget {
  final AppThemeData theme;

  const PayoutStep({
    super.key,
    required this.theme,
  });

  @override
  State<PayoutStep> createState() => _PayoutStepState();
}

class _PayoutStepState extends State<PayoutStep> {
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  String _selectedPaymentMethod = 'telebirr';
  bool _confirmDetailsCheck = false;
  bool _authorizePayoutCheck = false;
  bool _useRegistrationPhone = false;

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        context.read<OnboardingBloc>().add(UpdatePaymentMethod(method));
      },
      child: Container(
        padding: const EdgeInsets.all(AppThemes.spaceM),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : widget.theme.surface,
          borderRadius: BorderRadius.circular(AppThemes.borderRadius),
          border: Border.all(
            color: isSelected ? color : widget.theme.accent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppThemes.spaceS),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppThemes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppThemes.titleMedium(widget.theme).copyWith(
                      color: isSelected ? color : widget.theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXS),
                  Text(
                    description,
                    style: AppThemes.bodySmall(widget.theme),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
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
              'Payment Method',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'Choose how you\'d like to receive payments from customers.',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Payment Method Selection
            Text(
              'Select Payment Method',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            _buildPaymentMethodCard(
              method: 'telebirr',
              title: 'Telebirr',
              description: 'Mobile wallet payment system',
              icon: Icons.phone_android,
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            _buildPaymentMethodCard(
              method: 'cbe_birr',
              title: 'CBE Birr',
              description: 'Commercial Bank of Ethiopia mobile banking',
              icon: Icons.account_balance,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            _buildPaymentMethodCard(
              method: 'bank_account',
              title: 'Bank Account',
              description: 'Traditional bank account transfer',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF7B1FA2),
            ),
            
            const SizedBox(height: AppThemes.spaceXL),
            
            // Account Details
            Text(
              'Account Details',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Account Holder Name
            Text(
              'Account Holder Name',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _accountHolderController,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateAccountHolder(value));
              },
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'Enter account holder name',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Account Number
            Text(
              _selectedPaymentMethod == 'bank_account' 
                  ? 'Bank Account Number'
                  : 'Phone Number',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            
            // Phone number suggestion for telebirr/cbe_birr
            if (_selectedPaymentMethod == 'telebirr' || _selectedPaymentMethod == 'cbe_birr') ...[
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceM),
                decoration: BoxDecoration(
                  color: widget.theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(
                    color: widget.theme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: widget.theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppThemes.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Registration Phone?',
                            style: AppThemes.titleMedium(widget.theme).copyWith(
                              color: widget.theme.primary,
                            ),
                          ),
                          const SizedBox(height: AppThemes.spaceXS),
                          Text(
                            'You can use the same phone number from your registration',
                            style: AppThemes.bodySmall(widget.theme).copyWith(
                              color: widget.theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useRegistrationPhone,
                      onChanged: (value) {
                        setState(() {
                          _useRegistrationPhone = value;
                          if (value) {
                            // Get phone from state and set it
                            final currentState = context.read<OnboardingBloc>().state;
                            if (currentState is OnboardingInProgress) {
                              _accountNumberController.text = currentState.data.phoneNumber;
                              context.read<OnboardingBloc>().add(UpdateAccountNumber(currentState.data.phoneNumber));
                            }
                          } else {
                            _accountNumberController.clear();
                            context.read<OnboardingBloc>().add(const UpdateAccountNumber(''));
                          }
                        });
                      },
                      activeColor: widget.theme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppThemes.spaceM),
            ],
            
            TextField(
              controller: _accountNumberController,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateAccountNumber(value));
              },
              keyboardType: _selectedPaymentMethod == 'bank_account' 
                  ? TextInputType.number
                  : TextInputType.phone,
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: _selectedPaymentMethod == 'bank_account'
                    ? 'Enter bank account number'
                    : (_selectedPaymentMethod == 'telebirr' || _selectedPaymentMethod == 'cbe_birr') && !_useRegistrationPhone 
                        ? 'Enter phone number (+251...)'
                        : 'Enter phone number',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Agreement Checkboxes
            Text(
              'Payment Agreement',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Confirm Details Checkbox
            Row(
              children: [
                Checkbox(
                  value: _confirmDetailsCheck,
                  onChanged: (value) {
                    setState(() {
                      _confirmDetailsCheck = value ?? false;
                    });
                    context.read<OnboardingBloc>().add(UpdatePayoutCheckboxes(
                      confirmDetailsCheck: _confirmDetailsCheck,
                      authorizePayoutCheck: _authorizePayoutCheck,
                    ));
                  },
                  activeColor: widget.theme.primary,
                ),
                Expanded(
                  child: Text(
                    'I confirm that the payment details provided are accurate and belong to me',
                    style: AppThemes.bodyMedium(widget.theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceS),
            
            // Authorize Payout Checkbox
            Row(
              children: [
                Checkbox(
                  value: _authorizePayoutCheck,
                  onChanged: (value) {
                    setState(() {
                      _authorizePayoutCheck = value ?? false;
                    });
                    context.read<OnboardingBloc>().add(UpdatePayoutCheckboxes(
                      confirmDetailsCheck: _confirmDetailsCheck,
                      authorizePayoutCheck: _authorizePayoutCheck,
                    ));
                  },
                  activeColor: widget.theme.primary,
                ),
                Expanded(
                  child: Text(
                    'I authorize ZareShop to process payments to the account details provided',
                    style: AppThemes.bodyMedium(widget.theme),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Security Notice
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: widget.theme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: widget.theme.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure & Protected',
                          style: AppThemes.labelLarge(widget.theme).copyWith(
                            color: widget.theme.success,
                          ),
                        ),
                        const SizedBox(height: AppThemes.spaceXS),
                        Text(
                          'Your payment information is encrypted and securely stored. We never share your financial details with third parties.',
                          style: AppThemes.bodySmall(widget.theme).copyWith(
                            color: widget.theme.success,
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
