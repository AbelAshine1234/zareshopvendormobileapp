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

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _phoneError;
  String? _inlineErrorMessage;

  @override
  void initState() {
    super.initState();
    // No animations for better performance
    // Ensure latest localization assets (newly added keys) are loaded
    LocalizationService.instance.loadLanguage(
      LocalizationService.instance.currentLanguage,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _validateEthiopianPhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = null;
      } else if (value.length != 9) {
        _phoneError = 'auth.forgotPassword.phoneError'.tr();
      } else if (!value.startsWith('9')) {
        _phoneError = 'auth.forgotPassword.phoneErrorStart'.tr();
      } else {
        _phoneError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.forgotPassword.otpSent'.tr(params: {
                'phoneNumber': state.phoneNumber,
              })),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          // Navigate to OTP verification screen
          context.go('/forgot-password-otp', extra: state.phoneNumber);
          setState(() { _inlineErrorMessage = null; });
        } else if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.verifyOtp.resetSuccess'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login');
        } else if (state is AuthError) {
          final lower = state.message.toLowerCase();
          final msgKey = lower.contains('user not found')
              ? 'errors.userNotFound'
              : lower.contains('otp')
                  ? 'errors.invalidOtp'
                  : lower.contains('exists')
                      ? 'errors.userExists'
                      : 'errors.unknownError';
          setState(() { _inlineErrorMessage = msgKey.tr(); });
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
                              context.go('/login');
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

                      // Brand header (reuse pattern from login)
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
                      if (_inlineErrorMessage != null) ...[
                        InlineErrorBanner(
                          theme: theme,
                          message: _inlineErrorMessage!,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Headline & subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'auth.forgotPassword.title'.tr(),
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
                            'auth.forgotPassword.subtitle'.tr(),
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

                      _buildForgotPasswordCard(theme),

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
                    'auth.forgotPassword.title'.tr(),
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
                      'auth.forgotPassword.subtitle'.tr(),
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
          'auth.forgotPassword.description'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'auth.forgotPassword.descriptionText'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: theme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordCard(AppThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'auth.forgotPassword.title'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Phone Number Input
              Text(
                'auth.forgotPassword.phoneNumber'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              PhoneInput(
                theme: theme,
                controller: _phoneController,
                errorText: _phoneError,
                onChangedDigitsOnly: _validateEthiopianPhone,
                countryCode: '+251',
                hintDigits: 'auth.forgotPassword.phoneHint'.tr(),
                label: 'auth.forgotPassword.phoneLabel'.tr(),
              ),
              if (_phoneError != null)
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
                        _phoneError!,
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

              // Send Reset Code Button
              AppPrimaryButton(
                text: 'auth.forgotPassword.sendCode'.tr(),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_phoneError == null &&
                            _phoneController.text.isNotEmpty) {
                          context.read<AuthBloc>().add(
                                ForgotPasswordRequested(
                                  phoneNumber: '+251${_phoneController.text}',
                                ),
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('auth.forgotPassword.invalidPhone'.tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }

  // removed old banner helper; now using persisted _inlineErrorMessage
}
