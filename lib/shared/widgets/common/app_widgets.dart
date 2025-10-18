import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_themes.dart';
import '../../theme/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.primary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppThemes.spaceM),
                Text(
                  message!,
                  style: AppThemes.bodyMedium(theme),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
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
              color: color ?? const Color(0xFFE0E0E0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceM),
            child: Text(
              text!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575)).copyWith(
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: height ?? 1,
              color: color ?? const Color(0xFFE0E0E0),
            ),
          ),
        ],
      );
    }

    return Divider(
      height: height ?? 1,
      color: color ?? const Color(0xFFE0E0E0),
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
        horizontal: AppThemes.spaceS,
        vertical: AppThemes.spaceXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor ?? const Color(0xFF2E7D32),
            ),
            const SizedBox(width: AppThemes.spaceXS),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: AppThemes.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: textColor ?? const Color(0xFF2E7D32),
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
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    const SizedBox(width: AppThemes.spaceXS),
                ],
              ),
            );
          }),
        ),
        if (stepLabels != null) ...[
          const SizedBox(height: AppThemes.spaceS),
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: Text(
                  stepLabels![index],
                  style: const TextStyle(fontSize: 12).copyWith(
                    color: index <= currentStep
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF9E9E9E),
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
      padding: const EdgeInsets.all(AppThemes.spaceM),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: AppThemes.spaceS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: AppThemes.spaceXS),
                  Text(subtitle!, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
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
          topLeft: Radius.circular(AppThemes.largeBorderRadius),
          topRight: Radius.circular(AppThemes.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppThemes.spaceM),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
              padding: const EdgeInsets.all(AppThemes.spaceM),
              child: child,
            ),
          ),
          
          // Actions
          if (actions != null) ...[
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              child: Row(
                children: actions!
                    .expand((widget) => [widget, const SizedBox(width: AppThemes.spaceS)])
                    .take(actions!.length * 2 - 1)
                    .toList(),
              ),
            ),
          ],
          
          // Safe area bottom
          const SizedBox(height: AppThemes.spaceM),
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
        backgroundColor = const Color(0xFF388E3C);
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFD32F2F);
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFFF9800);
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = const Color(0xFF1976D2);
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppThemes.spaceS),
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
          borderRadius: BorderRadius.circular(AppThemes.borderRadius),
        ),
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }
