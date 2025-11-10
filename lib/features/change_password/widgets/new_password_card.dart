import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/change_password_state.dart';

class NewPasswordCard extends StatefulWidget {
  final AppThemeData theme;
  final ChangePasswordState state;
  final TextEditingController newPasswordController;

  const NewPasswordCard({
    super.key,
    required this.theme,
    required this.state,
    required this.newPasswordController,
  });

  @override
  State<NewPasswordCard> createState() => _NewPasswordCardState();
}

class _NewPasswordCardState extends State<NewPasswordCard> {
  bool _obscureNewPassword = true;

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
            'changePassword.newPassword'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.theme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              hintText: 'changePassword.newPasswordHint'.tr(),
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
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: widget.theme.textSecondary,
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
                return 'changePassword.newPasswordError'.tr();
              }
              if (value.length < 8) {
                return 'changePassword.newPasswordLengthError'.tr();
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
