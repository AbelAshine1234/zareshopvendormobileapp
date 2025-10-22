import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OtpInput(
              theme: widget.theme,
              otpCountdown: widget.otpCountdown,
              onResend: widget.onResendOTP,
              onChanged: (otp) => context.read<OnboardingBloc>().add(UpdateOTP(otp)),
              // map any OnboardingError code if needed in the future
            ),
          ],
        );
      },
    );
  }
}
