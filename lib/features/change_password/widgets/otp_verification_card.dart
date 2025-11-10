import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/buttons/app_buttons.dart';
import '../../../shared/widgets/otp/otp_input.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/change_password_bloc.dart';
import '../bloc/change_password_event.dart';
import '../bloc/change_password_state.dart';

class OtpVerificationCard extends StatelessWidget {
  final AppThemeData theme;
  final ChangePasswordState state;
  final TextEditingController otpController;

  const OtpVerificationCard({
    super.key,
    required this.theme,
    required this.state,
    required this.otpController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'changePassword.otpVerification'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'changePassword.otpDescription'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Use the OtpInput widget for individual digit inputs
          OtpInput(
            theme: theme,
            otpCountdown: 60, // You can get this from the bloc if needed
            showTitleSubtitle: false,
            showVerificationLabel: false,
            onChanged: (otp) {
              // Update the otpController when OTP changes
              otpController.text = otp;
            },
            onResend: () {
              context.read<ChangePasswordBloc>().add(ResendOtp());
            },
          ),
          const SizedBox(height: 24),
          // Verify OTP Button
          AppPrimaryButton(
            text: state is OtpVerifying ? 'changePassword.verifyingOtp'.tr() : 'changePassword.verifyOtp'.tr(),
            onPressed: state is OtpVerifying ? null : () {
              if (otpController.text.isNotEmpty && otpController.text.length == 6) {
                context.read<ChangePasswordBloc>().add(
                  VerifyOtp(otp: otpController.text),
                );
              }
            },
            isLoading: state is OtpVerifying,
          ),
        ],
      ),
    );
  }
}
