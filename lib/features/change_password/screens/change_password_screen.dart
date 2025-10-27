import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
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
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primary,
                          theme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                              _buildHeaderCard(theme),
                              const SizedBox(height: 24),
                              _buildCurrentPasswordCard(theme, state),
                              const SizedBox(height: 24),
                              if (state is OtpSent) _buildOtpVerificationCard(theme, state),
                              if (state is OtpVerified) ...[
                                const SizedBox(height: 24),
                                _buildNewPasswordCard(theme, state),
                                const SizedBox(height: 24),
                                _buildConfirmPasswordCard(theme, state),
                                const SizedBox(height: 32),
                                _buildChangePasswordButton(theme, state),
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

  Widget _buildHeaderCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Password Change',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We\'ll verify your identity before allowing password change',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordCard(AppThemeData theme, ChangePasswordState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              hintText: 'Enter your current password',
              hintStyle: TextStyle(
                color: theme.textSecondary.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state is OtpSending ? null : () {
                if (_currentPasswordController.text.isNotEmpty) {
                  context.read<ChangePasswordBloc>().add(
                    SendOtp(currentPassword: _currentPasswordController.text),
                  );
                }
              },
              icon: state is OtpSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.send, size: 20),
              label: Text(
                state is OtpSending ? 'Sending OTP...' : 'Send OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.primary.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationCard(AppThemeData theme, ChangePasswordState state) {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Enter the 6-digit code sent to your registered email/phone',
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter 6-digit OTP',
              hintStyle: TextStyle(
                color: theme.textSecondary.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP';
              }
              if (value.length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state is OtpVerifying ? null : () {
                    if (_otpController.text.isNotEmpty) {
                      context.read<ChangePasswordBloc>().add(
                        VerifyOtp(otp: _otpController.text),
                      );
                    }
                  },
                  icon: state is OtpVerifying
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.check, size: 18),
                  label: Text(
                    state is OtpVerifying ? 'Verifying...' : 'Verify OTP',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (state is OtpSent && context.read<ChangePasswordBloc>().isOtpTimerActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Resend in ${context.read<ChangePasswordBloc>().otpTimerSeconds}s',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    context.read<ChangePasswordBloc>().add(ResendOtp());
                  },
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordCard(AppThemeData theme, ChangePasswordState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'New Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              hintText: 'Enter your new password',
              hintStyle: TextStyle(
                color: theme.textSecondary.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordCard(AppThemeData theme, ChangePasswordState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm New Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Confirm your new password',
              hintStyle: TextStyle(
                color: theme.textSecondary.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton(AppThemeData theme, ChangePasswordState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state is PasswordChanging ? null : () {
          if (_formKey.currentState!.validate()) {
            context.read<ChangePasswordBloc>().add(
              ChangePassword(newPassword: _newPasswordController.text),
            );
          }
        },
        icon: state is PasswordChanging
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.check_circle, size: 20),
        label: Text(
          state is PasswordChanging ? 'Changing Password...' : 'Change Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
      ),
    );
  }
}
