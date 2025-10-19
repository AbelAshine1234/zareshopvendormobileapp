import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                            'Use Registration Number?',
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
                              String phoneNumber = currentState.data.phoneNumber;
                              // Remove +251 prefix to show only the 9 digits in the input
                              if (phoneNumber.startsWith('+251')) {
                                phoneNumber = phoneNumber.substring(4);
                              } else if (phoneNumber.startsWith('251')) {
                                phoneNumber = phoneNumber.substring(3);
                              }
                              _accountNumberController.text = phoneNumber;
                              // Send the full phone number with +251 to the bloc
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
            
            // Phone number input with +251 constant for mobile wallets
            if (_selectedPaymentMethod == 'telebirr' || _selectedPaymentMethod == 'cbe_birr') ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  color: widget.theme.inputBackground,
                  border: Border.all(
                    color: widget.theme.inputBorder,
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
                        controller: _accountNumberController,
                        onChanged: (value) {
                          // Only add +251 if the value doesn't already start with it
                          String phoneNumber = value;
                          if (!phoneNumber.startsWith('+251') && !phoneNumber.startsWith('251')) {
                            phoneNumber = '+251$value';
                          } else if (phoneNumber.startsWith('251')) {
                            phoneNumber = '+$value';
                          }
                          context.read<OnboardingBloc>().add(UpdateAccountNumber(phoneNumber));
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
            ] else ...[
              // Bank account number input
              TextField(
                controller: _accountNumberController,
                onChanged: (value) {
                  context.read<OnboardingBloc>().add(UpdateAccountNumber(value));
                },
                keyboardType: TextInputType.number,
                decoration: AppThemes.inputDecoration(
                  widget.theme,
                  hintText: 'Enter bank account number',
                ),
                style: AppThemes.bodyMedium(widget.theme),
              ),
            ],
            
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
