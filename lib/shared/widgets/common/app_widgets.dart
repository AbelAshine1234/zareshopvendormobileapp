import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryGreen,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spaceM),
            Text(
              message!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AppDivider extends StatelessWidget {
  final String? text;
  final double? height;
  final Color? color;

  const AppDivider({
    super.key,
    this.text,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return Row(
        children: [
          Expanded(
            child: Divider(
              height: height ?? 1,
              color: color ?? AppTheme.dividerColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceM),
            child: Text(
              text!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textHint,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: height ?? 1,
              color: color ?? AppTheme.dividerColor,
            ),
          ),
        ],
      );
    }

    return Divider(
      height: height ?? 1,
      color: color ?? AppTheme.dividerColor,
    );
  }
}

class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceS,
        vertical: AppTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor ?? AppTheme.primaryGreen,
            ),
            const SizedBox(width: AppTheme.spaceXS),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class AppStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppTheme.primaryGreen
                            : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    const SizedBox(width: AppTheme.spaceXS),
                ],
              ),
            );
          }),
        ),
        if (stepLabels != null) ...[
          const SizedBox(height: AppTheme.spaceS),
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: Text(
                  stepLabels![index],
                  style: AppTheme.bodySmall.copyWith(
                    color: index <= currentStep
                        ? AppTheme.primaryGreen
                        : AppTheme.textHint,
                    fontWeight: index == currentStep
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: AppTheme.spaceS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(subtitle!, style: AppTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.largeBorderRadius),
          topRight: Radius.circular(AppTheme.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const AppDivider(),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              child: child,
            ),
          ),
          
          // Actions
          if (actions != null) ...[
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              child: Row(
                children: actions!
                    .expand((widget) => [widget, const SizedBox(width: AppTheme.spaceS)])
                    .take(actions!.length * 2 - 1)
                    .toList(),
              ),
            ),
          ],
          
          // Safe area bottom
          const SizedBox(height: AppTheme.spaceM),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        actions: actions,
        child: child,
      ),
    );
  }
}

class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = AppTheme.errorRed;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = AppTheme.warningOrange;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = AppTheme.infoBlue;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppTheme.spaceS),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }
