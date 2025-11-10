import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/selectors/language_switcher_button.dart';
import '../../../shared/widgets/selectors/theme_selector_button.dart';
import '../widgets/widgets.dart';
import '../bloc/change_password_bloc.dart';
import '../bloc/change_password_event.dart';
import '../bloc/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
        builder: (context, localization, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              
              return Scaffold(
                backgroundColor: theme.background,
                appBar: AppBar(
                  title: Text('changePassword.title'.tr()),
                  elevation: 0,
                  actions: [
                    const LanguageSwitcherButton(),
                    const ThemeSelectorButton(),
                    const SizedBox(width: 8),
                  ],
                ),
                body: BlocListener<ChangePasswordBloc, ChangePasswordState>(
                  listener: (context, state) {
                    if (state is OtpSent) {
                      GlobalSnackBar.showSuccess(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is OtpVerified) {
                      GlobalSnackBar.showSuccess(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is PasswordChanged) {
                      GlobalSnackBar.showSuccess(
                        context: context,
                        message: state.message,
                      );
                      Navigator.pop(context);
                    } else if (state is ChangePasswordError) {
                      GlobalSnackBar.showError(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is OtpSendError) {
                      GlobalSnackBar.showError(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is OtpVerifyError) {
                      GlobalSnackBar.showError(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is PasswordChangeError) {
                      GlobalSnackBar.showError(
                        context: context,
                        message: state.message,
                      );
                    }
                  },
                  child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ChangePasswordHeader(
                                theme: theme,
                                themeType: themeProvider.currentThemeType,
                              ),
                              const SizedBox(height: 24),
                              // Only show current password card if OTP is not sent yet
                              if (state is! OtpSent && state is! OtpVerified) ...[
                                CurrentPasswordCard(
                                  theme: theme,
                                  state: state,
                                  currentPasswordController: _currentPasswordController,
                                ),
                                const SizedBox(height: 24),
                              ],
                              // Show OTP verification when OTP is sent
                              if (state is OtpSent) OtpVerificationCard(
                                theme: theme,
                                state: state,
                                otpController: _otpController,
                              ),
                              // Show new password fields when OTP is verified
                              if (state is OtpVerified) ...[
                                const SizedBox(height: 24),
                                NewPasswordCard(
                                  theme: theme,
                                  state: state,
                                  newPasswordController: _newPasswordController,
                                ),
                                const SizedBox(height: 24),
                                ConfirmPasswordCard(
                                  theme: theme,
                                  state: state,
                                  confirmPasswordController: _confirmPasswordController,
                                  newPasswordController: _newPasswordController,
                                ),
                                const SizedBox(height: 32),
                                ChangePasswordButton(
                                  theme: theme,
                                  state: state,
                                  formKey: _formKey,
                                  newPasswordController: _newPasswordController,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
    );
  }

}
