import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OTPStep extends StatefulWidget {
  final AppThemeData theme;
  final int otpCountdown;
  final VoidCallback onResendOTP;

  const OTPStep({
    super.key,
    required this.theme,
    required this.otpCountdown,
    required this.onResendOTP,
  });

  @override
  State<OTPStep> createState() => _OTPStepState();
}

class _OTPStepState extends State<OTPStep> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Combine all OTP digits
    String otp = _otpControllers.map((controller) => controller.text).join();
    context.read<OnboardingBloc>().add(UpdateOTP(otp));
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
              'Verify Your Phone Number',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'We\'ve sent a 6-digit verification code to your phone number.',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            Text(
              'Enter Verification Code',
              style: AppThemes.titleLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onOTPChanged(index, value),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                        borderSide: BorderSide(color: widget.theme.accent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                        borderSide: BorderSide(color: widget.theme.accent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                        borderSide: BorderSide(color: widget.theme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: widget.theme.surface,
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.textPrimary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Center(
              child: widget.otpCountdown > 0
                  ? Text(
                      'Resend code in ${widget.otpCountdown}s',
                      style: AppThemes.bodyMedium(widget.theme),
                    )
                  : AppTextButton(
                      text: 'Resend Code',
                      onPressed: widget.onResendOTP,
                    ),
            ),
            const SizedBox(height: AppThemes.spaceL),
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
                    child: Text(
                      'Didn\'t receive the code? Check your SMS messages or try resending.',
                      style: AppThemes.bodySmall(widget.theme).copyWith(
                        color: widget.theme.info,
                      ),
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
