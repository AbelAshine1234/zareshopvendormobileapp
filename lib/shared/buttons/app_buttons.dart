import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme/theme_provider.dart';
import '../utils/theme/app_themes.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool enabled;
  final double? width;
  final double? height;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.enabled = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? AppThemes.buttonHeight,
          child: ElevatedButton(
            onPressed: enabled && !isLoading ? onPressed : null,
            style: AppThemes.primaryButtonStyle(theme),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.isDark ? theme.textPrimary : Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20),
                        const SizedBox(width: AppThemes.spaceS),
                      ],
                      Text(text, style: AppThemes.buttonText(theme)),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final double? width;
  final double? height;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? AppThemes.buttonHeight,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: AppThemes.secondaryButtonStyle(theme),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppThemes.spaceS),
                ],
                Text(
                  text,
                  style: AppThemes.buttonText(theme).copyWith(
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final double? width;
  final double? height;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? AppThemes.buttonHeight,
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: AppThemes.textButtonStyle(theme),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppThemes.spaceS),
                ],
                Text(
                  text,
                  style: AppThemes.buttonText(theme).copyWith(
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return IconButton(
          icon: Icon(
            icon,
            color: color ?? theme.primary,
            size: size ?? 24,
          ),
          onPressed: onPressed,
          tooltip: tooltip,
        );
      },
    );
  }
}

class AppFloatingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AppFloatingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppThemes.spaceM),
          decoration: BoxDecoration(
            color: theme.surface,
            boxShadow: theme.cardShadow,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppThemes.largeBorderRadius),
              topRight: Radius.circular(AppThemes.largeBorderRadius),
            ),
          ),
          child: SafeArea(
            child: AppPrimaryButton(
              text: text,
              onPressed: onPressed,
              isLoading: isLoading,
              icon: icon,
            ),
          ),
        );
      },
    );
  }
}

class AppButtonGroup extends StatelessWidget {
  final String primaryText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;
  final bool isLoading;
  final bool primaryEnabled;
  final MainAxisAlignment alignment;

  const AppButtonGroup({
    super.key,
    required this.primaryText,
    this.onPrimaryPressed,
    this.secondaryText,
    this.onSecondaryPressed,
    this.isLoading = false,
    this.primaryEnabled = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPrimaryButton(
          text: primaryText,
          onPressed: onPrimaryPressed,
          isLoading: isLoading,
          enabled: primaryEnabled,
        ),
        if (secondaryText != null) ...[
          const SizedBox(height: AppThemes.spaceM),
          AppTextButton(
            text: secondaryText!,
            onPressed: onSecondaryPressed,
          ),
        ],
      ],
    );
  }
}

class AppChipButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;

  const AppChipButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: AppThemes.spaceXS),
              ],
              Text(text),
            ],
          ),
          selected: isSelected,
          onSelected: onPressed != null ? (_) => onPressed!() : null,
          backgroundColor: theme.surface,
          selectedColor: theme.accent,
          checkmarkColor: theme.primary,
          side: BorderSide(
            color: isSelected ? theme.primary : theme.accent,
          ),
          labelStyle: TextStyle(
            color: isSelected ? theme.primary : theme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      },
    );
  }
}
