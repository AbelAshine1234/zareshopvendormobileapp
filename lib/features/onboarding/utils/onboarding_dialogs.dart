import 'package:flutter/material.dart';
import '../../../shared/shared.dart';

class OnboardingDialogs {
  /// Show privacy policy dialog
  static void showPrivacyDialog(BuildContext context) {
    AppDialogs.showPrivacyDialog(context);
  }

  /// Show success dialog
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onContinue,
  }) {
    AppDialogs.showSuccessDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onContinue: onContinue,
    );
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    AppDialogs.showErrorDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onRetry: onRetry,
    );
  }

  /// Show confirmation dialog
  static void showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    AppDialogs.showConfirmationDialog(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
