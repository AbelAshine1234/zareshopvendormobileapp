import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/app_themes.dart';
import '../../../shared/widgets/theme_selector/theme_selector_button.dart';
import '../../../shared/widgets/language_selector/language_switcher_button.dart';
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
      child: _ForgotPasswordOtpView(phoneNumber: phoneNumber),
    );
  }
}

class _ForgotPasswordOtpView extends StatefulWidget {
  final String phoneNumber;

  const _ForgotPasswordOtpView({required this.phoneNumber});

  @override
  State<_ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<_ForgotPasswordOtpView> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;
  String? _confirmPasswordError;
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Consumer2<ThemeProvider, LocalizationService>(
        builder: (context, themeProvider, localization, child) {
          final theme = themeProvider.currentTheme;
          
          return Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(right: 96, left: 56),
                            child: _buildHeader(theme),
                          ),
                          const SizedBox(height: 56),
                          Padding(
                            padding: const EdgeInsets.only(right: 96, left: 56),
                            child: _buildDescription(theme),
                          ),
                          const SizedBox(height: 40),
                          _buildOtpVerificationCard(theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Left-aligned back button at same vertical line as top-right buttons (on top of content)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () {
                      print('🔙 [FORGOT_PASSWORD_OTP] Back button pressed');
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/forgot-password');
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: theme.textPrimary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.surface,
                      foregroundColor: theme.textPrimary,
                      padding: const EdgeInsets.all(8),
                      side: BorderSide(
                        color: theme.border,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Theme selector and language switcher buttons in top-right
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      LanguageSwitcherButton(),
                      SizedBox(width: 8),
                      ThemeSelectorButton(),
                    ],
                  ),
                ),
              ],
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
              
              Center(
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: boxWidth,
                      height: 56,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            } else {
                              _otpFocusNodes[index].unfocus();
                            }
                          } else {
                            if (index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.border,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.background,
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.background,
                  border: Border.all(
                    color: _passwordError != null ? theme.error : theme.border,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  onChanged: _validatePassword,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'auth.verifyOtp.newPasswordHint'.tr(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(
                      color: theme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: theme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.textPrimary,
                  ),
                ),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.background,
                  border: Border.all(
                    color: _confirmPasswordError != null ? theme.error : theme.border,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  onChanged: _validateConfirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'auth.verifyOtp.confirmPasswordHint'.tr(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(
                      color: theme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: theme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.textPrimary,
                  ),
                ),
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final otpCode = _otpControllers.map((controller) => controller.text).join('');
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: theme.primary.withValues(alpha: 0.6),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          'auth.verifyOtp.resetPassword'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: theme.border),
              const SizedBox(height: 12),
              // Resend OTP Button
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                                ForgotPasswordRequested(
                                  phoneNumber: widget.phoneNumber,
                                ),
                              );
                        },
                  child: Text(
                    'auth.verifyOtp.resendCode'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
