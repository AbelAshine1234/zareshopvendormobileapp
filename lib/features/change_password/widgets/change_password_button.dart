import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/buttons/app_buttons.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/change_password_bloc.dart';
import '../bloc/change_password_event.dart';
import '../bloc/change_password_state.dart';

class ChangePasswordButton extends StatelessWidget {
  final AppThemeData theme;
  final ChangePasswordState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;

  const ChangePasswordButton({
    super.key,
    required this.theme,
    required this.state,
    required this.formKey,
    required this.newPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      text: state is PasswordChanging ? 'changePassword.changingPassword'.tr() : 'changePassword.changePasswordButton'.tr(),
      onPressed: state is PasswordChanging ? null : () {
        if (formKey.currentState!.validate()) {
          context.read<ChangePasswordBloc>().add(
            ChangePassword(newPassword: newPasswordController.text),
          );
        }
      },
      isLoading: state is PasswordChanging,
    );
  }
}
