import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordOtpScreen extends StatelessWidget {
  final String phoneNumber;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: _ForgotPasswordOtpView(phoneNumber: phoneNumber, otpCountdown: 60),
    );
  }
}

class _ForgotPasswordOtpView extends StatefulWidget {
  final String phoneNumber;
  final int otpCountdown;

  const _ForgotPasswordOtpView({required this.phoneNumber, this.otpCountdown = 60});

  @override
  State<_ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<_ForgotPasswordOtpView> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
      } else if (value.length < 6) {
        _passwordError = 'auth.verifyOtp.passwordError'.tr();
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
      } else if (value != _newPasswordController.text) {
        _confirmPasswordError = 'auth.verifyOtp.passwordMismatch'.tr();
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.verifyOtp.resetSuccess'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login');
        } else if (state is AuthError) {
          setState(() {});
        }
      },
      child: Consumer2<ThemeProvider, LocalizationService>(
        builder: (context, themeProvider, localization, child) {
          final theme = themeProvider.currentTheme;
          
          return Scaffold(
            backgroundColor: theme.background,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top utilities row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/forgot-password');
                              }
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: theme.textPrimary,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.surface,
                              foregroundColor: theme.textPrimary,
                              padding: const EdgeInsets.all(8),
                              side: BorderSide(color: theme.divider, width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LanguageSwitcherButton(),
                              SizedBox(width: 8),
                              ThemeSelectorButton(),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Brand header
                      SizedBox(
                        height: 64,
                        child: Image.asset(
                          'assets/logo/logo-green.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ZareShop',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: theme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Inline error
                      _maybeErrorBanner(theme),

                      // Headline & subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'auth.verifyOtp.title'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'auth.verifyOtp.subtitle'.tr(params: {'phoneNumber': widget.phoneNumber}),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildOtpVerificationCard(theme),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Column(
      children: [
        // Header row with back button and title
        Row(
          children: [
            const SizedBox(width: 0),
            // Title (left-aligned, pushed further down)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      'auth.verifyOtp.title'.tr(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'auth.verifyOtp.subtitle'.tr(params: {'phoneNumber': widget.phoneNumber}),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.verifyOtp.description'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'auth.verifyOtp.descriptionText'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: theme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationCard(AppThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = 28.0; // matches container padding
        final gap = 10.0; // Wrap spacing
        final available = screenWidth - (24 * 2) - (horizontalPadding * 2); // page horizontal padding + card padding
        final computedWidth = (available - gap * 5) / 6;
        final boxWidth = computedWidth.clamp(44.0, 56.0);

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top label and inputs
              Text(
                'auth.verifyOtp.verificationCode'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              
              OtpInput(
                theme: theme,
                otpCountdown: widget.otpCountdown,
                onResend: () {
                  context.read<AuthBloc>().add(
                        ForgotPasswordRequested(
                          phoneNumber: widget.phoneNumber,
                        ),
                      );
                },
                onChanged: (otp) {
                  _otpCode = otp;
                },
              ),
              const SizedBox(height: 24),

              // New Password Input
              Text(
                'auth.verifyOtp.newPassword'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              PasswordInput(
                theme: theme,
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                hintText: 'auth.verifyOtp.newPasswordHint'.tr(),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _passwordError!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Confirm Password Input
              Text(
                'auth.verifyOtp.confirmPassword'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              PasswordInput(
                theme: theme,
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                hintText: 'auth.verifyOtp.confirmPasswordHint'.tr(),
              ),
              if (_confirmPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _confirmPasswordError!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Reset Password Button
              AppPrimaryButton(
                text: 'auth.verifyOtp.resetPassword'.tr(),
                onPressed: isLoading
                    ? null
                    : () {
                        // Read OTP from the global input by focusing its controllers is not necessary.
                        // Instead, require AuthBloc to keep latest OTP from onChanged if needed.
                        final otpCode = _otpCode;
                        if (otpCode.length == 6 &&
                            _passwordError == null &&
                            _confirmPasswordError == null &&
                            _newPasswordController.text.isNotEmpty) {
                          context.read<AuthBloc>().add(
                                ResetPasswordRequested(
                                  phoneNumber: widget.phoneNumber,
                                  otp: otpCode,
                                  newPassword: _newPasswordController.text,
                                ),
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('auth.verifyOtp.fillFields'.tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                isLoading: isLoading,
              ),

              const SizedBox(height: 20),
              Divider(color: theme.border),
              const SizedBox(height: 12),
              // Resend OTP Widget
              OTPTimerWithResendWidget(
                onResendPressed: () {
                  context.read<AuthBloc>().add(
                        ForgotPasswordRequested(
                          phoneNumber: widget.phoneNumber,
                        ),
                      );
                },
                initialDuration: widget.otpCountdown,
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _maybeErrorBanner(AppThemeData theme) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthError) {
      final msgKey = authState.message.contains('invalid')
          ? 'errors.invalidOtp'
          : authState.message.contains('exists')
              ? 'errors.userExists'
              : 'errors.unknownError';
      return Column(
        children: [
          InlineErrorBanner(
            theme: theme,
            message: msgKey.tr(),
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
