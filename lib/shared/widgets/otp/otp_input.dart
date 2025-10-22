import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';
import 'otp_timer_widget.dart';

/// A global, reusable OTP input widget with 6 boxes and optional timer+resend.
class OtpInput extends StatefulWidget {
  final AppThemeData theme;
  final int length;
  final int otpCountdown; // seconds
  final VoidCallback? onResend;
  final ValueChanged<String>? onChanged; // emits combined OTP when any box changes

  /// Optional error string or code. If [errorCode] is provided as 'OTP_EXPIRED' or 'INVALID_OTP',
  /// it will be localized here; otherwise [errorText] will be shown as-is.
  final String? errorText;
  final String? errorCode; // 'OTP_EXPIRED' | 'INVALID_OTP' | null

  const OtpInput({
    super.key,
    required this.theme,
    this.length = 6,
    this.otpCountdown = 60,
    this.onResend,
    this.onChanged,
    this.errorText,
    this.errorCode,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onBoxChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);
  }

  String? _localizedError() {
    if (widget.errorCode == 'OTP_EXPIRED') {
      return LocalizationService.instance.get('errors.otpExpired');
    }
    if (widget.errorCode == 'INVALID_OTP') {
      return LocalizationService.instance.get('errors.invalidOtp');
    }
    return widget.errorText; // show raw if provided
  }

  @override
  Widget build(BuildContext context) {
    final error = _localizedError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'otp.title'.tr(),
          style: AppThemes.headlineLarge(widget.theme),
        ),
        const SizedBox(height: AppThemes.spaceM),
        Text(
          'otp.subtitle'.tr(),
          style: AppThemes.bodyLarge(widget.theme),
        ),
        const SizedBox(height: AppThemes.spaceXL),
        Text(
          'otp.verificationCode'.tr(),
          style: AppThemes.titleLarge(widget.theme),
        ),
        const SizedBox(height: AppThemes.spaceM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => _onBoxChanged(index, v),
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
        const SizedBox(height: AppThemes.spaceS),
        Align(
          alignment: Alignment.centerRight,
          child: OTPTimerWithResendWidget(
            onResendPressed: widget.onResend,
            initialDuration: widget.otpCountdown,
            textColor: widget.theme.primary,
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: widget.theme.primary,
            ),
            resendText: 'otp.resendCode'.tr(),
          ),
        ),
        const SizedBox(height: AppThemes.spaceS),
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
                  'otp.didntReceive'.tr(),
                  style: AppThemes.bodySmall(widget.theme).copyWith(
                    color: widget.theme.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null && error.isNotEmpty) ...[
          const SizedBox(height: AppThemes.spaceS),
          Row(
            children: [
              Icon(Icons.error_outline, color: widget.theme.error, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: widget.theme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}


