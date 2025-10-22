import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _phoneError;
  String? _inlineErrorMessage; // persist banner even if bloc resets to initial

  @override
  void initState() {
    super.initState();
    // Remove complex animations for better performance
  }

  Widget _maybeErrorBanner(AppThemeData theme) {
    return GlobalErrorWidget(
      errorMessage: _inlineErrorMessage,
      onRetry: _inlineErrorMessage != null ? () {
        setState(() {
          _inlineErrorMessage = null;
        });
      } : null,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEthiopianPhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = null;
      } else if (value.length != 9) {
        _phoneError = 'validation.phone'.tr();
      } else if (!value.startsWith('9')) {
        _phoneError = 'validation.phone'.tr();
      } else {
        _phoneError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate to dashboard
          context.go('/');
          setState(() { _inlineErrorMessage = null; });
        } else if (state is AuthSignupRequested) {
          context.go('/onboarding');
        } else if (state is AuthError) {
          // final errorKey = GlobalErrorHandler.getErrorKey(state.message);
          setState(() { _inlineErrorMessage = "Error occurred"; });
          // GlobalErrorHandler.showError(
          //   context,
          //   state.message,
          //   onRetry: () {
          //     setState(() {
          //       _inlineErrorMessage = null;
          //     });
          //   },
          // );
        } else if (state is AuthLoginResponse) {
          final user = state.data['user'] as Map<String, dynamic>?;
          final vendorVerified = (user?['vendor_verified'] == true) || (user?['vendorApproved'] == true);
          if (vendorVerified) {
            context.go('/');
          } else {
            context.go('/admin-approval');
          }
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
                            onPressed: () => context.go('/splash'),
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
                      _buildBrandHeader(theme, themeProvider.currentThemeType),

                      const SizedBox(height: 16),

                      // Headline & subtitle
                      _buildIntroText(theme),

                      const SizedBox(height: 20),

                      // Inline error banner if any
                      _maybeErrorBanner(theme),

                      // If we have a raw login response, show it for testing
                      Builder(builder: (_) {
                        final state = context.read<AuthBloc>().state;
                        if (state is AuthLoginResponse) {
                          const encoder = JsonEncoder.withIndent('  ');
                          final pretty = encoder.convert(state.data);
                          return Column(children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.info.withValues(alpha: 0.08),
                                border: Border.all(color: theme.info.withValues(alpha: 0.35), width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: theme.info, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Login Response (testing)', style: TextStyle(color: theme.info, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(pretty, style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ]);
                        }
                        return const SizedBox.shrink();
                      }),

                      // Card with form
                      _buildLoginCard(theme),

                      const SizedBox(height: 16),

                      _buildSignupPrompt(theme),

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

  Widget _buildBrandHeader(AppThemeData theme, AppThemeType themeType) {
    String _logoForTheme(AppThemeType t) {
      switch (t) {
        case AppThemeType.coffee:
          return 'assets/logo/logo-coffe.png';
        case AppThemeType.green:
          return 'assets/logo/logo-green.png';
        case AppThemeType.basic:
          return 'assets/logo/logo-basic.png';
      }
    }
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Image.asset(
            _logoForTheme(themeType),
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
      ],
    );
  }

  Widget _buildIntroText(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'auth.login.welcome'.tr(),
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
          'auth.login.subtitle'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AppThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isPasswordVisible =
            state is AuthInitial ? state.isPasswordVisible : false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.divider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                 
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'auth.login.title'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'auth.login.subtitle'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

                      // Phone Number Input
                      Text(
                        'auth.login.phoneNumber'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.labelText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PhoneInput(
                        theme: theme,
                        controller: _phoneController,
                        errorText: _phoneError,
                        onChangedDigitsOnly: _validateEthiopianPhone,
                        countryCode: '+251',
                        hintDigits: 'auth.login.phoneHint'.tr(),
                        label: 'auth.login.phoneLabel'.tr(),
                      ),

              const SizedBox(height: 14),

              // Password Input
              Text(
                'auth.login.password'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.labelText,
                ),
              ),
              const SizedBox(height: 8),
              PasswordInput(
                theme: theme,
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                onToggleVisibility: () {
                  context.read<AuthBloc>().add(const TogglePasswordVisibility());
                },
                hintText: 'auth.login.passwordHint'.tr(),
              ),

              const SizedBox(height: 10),

              // Forgot Password + Remember me
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_outlined, color: theme.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'auth.login.secureLogin'.tr(),
                            style: TextStyle(fontSize: 12, color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'auth.login.forgotPassword'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.linkText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Login Button
              AppPrimaryButton(
                text: 'auth.login.loginButton'.tr(),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_phoneError == null &&
                            _phoneController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          context.read<AuthBloc>().add(
                                LoginRequested(
                                  phoneNumber: '+251${_phoneController.text}',
                                  password: _passwordController.text,
                                ),
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('auth.login.fillFields'.tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                isLoading: isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignupPrompt(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'auth.login.noAccount'.tr(),
            style: TextStyle(
              fontSize: 15,
              color: theme.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(const SignupRequested());
            },
            child: Text(
              'auth.login.signUp'.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
