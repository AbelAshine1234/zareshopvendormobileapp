import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/buttons/app_buttons.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/change_password_bloc.dart';
import '../bloc/change_password_event.dart';
import '../bloc/change_password_state.dart';

class CurrentPasswordCard extends StatefulWidget {
  final AppThemeData theme;
  final ChangePasswordState state;
  final TextEditingController currentPasswordController;

  const CurrentPasswordCard({
    super.key,
    required this.theme,
    required this.state,
    required this.currentPasswordController,
  });

  @override
  State<CurrentPasswordCard> createState() => _CurrentPasswordCardState();
}

class _CurrentPasswordCardState extends State<CurrentPasswordCard> {
  bool _obscureCurrentPassword = true;

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
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.theme.primary.withOpacity(0.1),
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
          Text(
            'changePassword.currentPassword'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              hintText: 'changePassword.currentPasswordHint'.tr(),
              hintStyle: TextStyle(
                color: widget.theme.textSecondary.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.theme.primary,
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
                  color: widget.theme.textSecondary,
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
                return 'changePassword.currentPasswordError'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            text: widget.state is OtpSending ? 'changePassword.sendingOtp'.tr() : 'changePassword.sendOtp'.tr(),
            onPressed: widget.state is OtpSending ? null : () {
              if (widget.currentPasswordController.text.isNotEmpty) {
                context.read<ChangePasswordBloc>().add(
                  SendOtp(currentPassword: widget.currentPasswordController.text),
                );
              }
            },
            isLoading: widget.state is OtpSending,
          ),
        ],
      ),
    );
  }
}
