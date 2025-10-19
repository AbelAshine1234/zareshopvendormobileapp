import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/language_selector/language_switcher_button.dart';
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

  @override
  void initState() {
    super.initState();
    // Remove complex animations for better performance
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
        } else if (state is AuthSignupRequested) {
          context.go('/onboarding');
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          // Top bar space
                          const SizedBox(height: 48),
                          _buildHeader(theme),
                          const SizedBox(height: 10),
                          _buildWelcomeText(theme),
                          const SizedBox(height: 20),
                          _buildLoginCard(theme),
                          const SizedBox(height: 16),
                          _buildSignupPrompt(theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: IconButton(
                    onPressed: () {
                      context.go('/splash');
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
                ),
                Positioned(
                  top: 12,
                  right: 12,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZARESHOP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'VENDOR PORTAL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.login.welcome'.tr(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'auth.login.subtitle'.tr(),
          style: TextStyle(
            fontSize: 15,
            color: theme.textSecondary,
            height: 1.4,
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
                      Text(
                        'auth.login.title'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Number Input
                      Text(
                        'auth.login.phoneNumber'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.labelText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.inputBackground,
                          border: Border.all(
                            color: _phoneError != null ? theme.error : theme.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, top: 16, bottom: 16, right: 12),
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: theme.successGradient,
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
                                  const SizedBox(width: 8),
                                  Text(
                                    '+251',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.labelText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.divider,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                onChanged: _validateEthiopianPhone,
                                keyboardType: TextInputType.number,
                                maxLength: 9,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(9),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'auth.login.phoneHint'.tr(),
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  hintStyle: TextStyle(
                                    color: theme.textHint,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
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

                      const SizedBox(height: 16),

                      // Password Input
                      Text(
                        'auth.login.password'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.labelText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.inputBackground,
                          border: Border.all(
                            color: theme.inputBorder,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'auth.login.passwordHint'.tr(),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintStyle: TextStyle(
                              color: theme.textHint,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.textSecondary,
                              ),
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const TogglePasswordVisibility());
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

                      const SizedBox(height: 8),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            print('🔑 [LOGIN] Forgot password pressed, navigating to forgot password');
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.linkText,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_phoneError == null &&
                                      _phoneController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty) {
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            phoneNumber:
                                                '+251${_phoneController.text}',
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.buttonBackground,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor:
                                theme.buttonBackground.withValues(alpha: 0.6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                      : Text(
                          'auth.login.loginButton'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
