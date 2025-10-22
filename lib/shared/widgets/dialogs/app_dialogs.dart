import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';

class AppDialogs {
  /// Show privacy policy dialog
  static void showPrivacyDialog(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppThemes.largeBorderRadius),
                        topRight: Radius.circular(AppThemes.largeBorderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.privacy_tip_outlined,
                            color: theme.textPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppThemes.spaceM),
                        Expanded(
                          child: Text(
                            'Privacy Policy',
                            style: AppThemes.titleLarge(theme),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Protection',
                          style: AppThemes.titleMedium(theme),
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        
                        // Privacy points
                        _buildPrivacyPoint(theme, 'We collect only necessary information for service delivery'),
                        _buildPrivacyPoint(theme, 'Your data is encrypted and stored securely'),
                        _buildPrivacyPoint(theme, 'We never share your personal information with third parties'),
                        _buildPrivacyPoint(theme, 'You can request data deletion at any time'),
                        _buildPrivacyPoint(theme, 'We comply with all applicable data protection laws'),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppThemes.spaceL,
                      0,
                      AppThemes.spaceL,
                      AppThemes.spaceL,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                          ),
                        ),
                        child: Text(
                          'I Understand',
                          style: AppThemes.titleMedium(theme).copyWith(
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show success dialog
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onContinue,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.success,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: theme.success,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppThemes.spaceL,
                      0,
                      AppThemes.spaceL,
                      AppThemes.spaceL,
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: AppThemes.titleLarge(theme),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        Text(
                          message,
                          style: AppThemes.bodyMedium(theme).copyWith(
                            color: theme.textPrimary.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceL),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onContinue?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                              ),
                            ),
                            child: Text(
                              buttonText ?? 'Continue',
                              style: AppThemes.titleMedium(theme).copyWith(
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.error,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: theme.error,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppThemes.spaceL,
                      0,
                      AppThemes.spaceL,
                      AppThemes.spaceL,
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: AppThemes.titleLarge(theme),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        Text(
                          message,
                          style: AppThemes.bodyMedium(theme).copyWith(
                            color: theme.textPrimary.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceL),
                        Row(
                          children: [
                            if (onRetry != null) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onRetry.call();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.primary,
                                    side: BorderSide(color: theme.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: AppThemes.titleMedium(theme).copyWith(
                                      color: theme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppThemes.spaceM),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                                  ),
                                ),
                                child: Text(
                                  buttonText ?? 'OK',
                                  style: AppThemes.titleMedium(theme).copyWith(
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: AppThemes.titleLarge(theme),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        Text(
                          message,
                          style: AppThemes.bodyMedium(theme).copyWith(
                            color: theme.textPrimary.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceL),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onCancel?.call();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.textPrimary,
                                  side: BorderSide(color: theme.inputBorder),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                                  ),
                                ),
                                child: Text(
                                  cancelText ?? 'Cancel',
                                  style: AppThemes.titleMedium(theme),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppThemes.spaceM),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onConfirm?.call();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppThemes.buttonBorderRadius),
                                  ),
                                ),
                                child: Text(
                                  confirmText ?? 'Confirm',
                                  style: AppThemes.titleMedium(theme).copyWith(
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper method to build privacy points
  static Widget _buildPrivacyPoint(AppThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: AppThemes.spaceS),
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppThemes.bodyMedium(theme).copyWith(
                color: theme.textPrimary.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
