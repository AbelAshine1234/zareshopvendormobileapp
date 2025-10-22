import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/app_themes.dart';
import '../../utils/theme/theme_provider.dart';
import '../../buttons/app_buttons.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        Widget card = Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(AppThemes.spaceL),
          margin: margin,
          decoration: AppThemes.cardDecoration(theme).copyWith(
            color: color ?? theme.surface,
          ),
          child: this.child,
        );

        if (onTap != null) {
          return GestureDetector(
            onTap: onTap,
            child: card,
          );
        }

        return card;
      },
    );
  }
}

class AppStepCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final EdgeInsets? padding;

  const AppStepCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;
        
        return AppCard(
          padding: padding ?? const EdgeInsets.all(AppThemes.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppThemes.spaceM),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                      ),
                      child: Icon(
                        icon,
                        color: theme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppThemes.spaceM),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppThemes.titleMedium(theme)),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppThemes.spaceXS),
                          Text(subtitle!, style: AppThemes.bodyMedium(theme)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppThemes.spaceL),
              
              // Content
              child,
            ],
          ),
        );
      },
    );
  }
}

class AppInfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const AppInfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;
        final cardColor = color ?? theme.primary;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadius),
              border: Border.all(color: cardColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppThemes.spaceS),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppThemes.spaceS),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: cardColor,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppThemes.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: cardColor,
                        ),
                      ),
                      const SizedBox(height: AppThemes.spaceXS),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: AppThemes.fontSizeSmall,
                          color: cardColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: cardColor.withOpacity(0.6),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppProgressCard extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const AppProgressCard({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;
        final progress = (currentStep + 1) / totalSteps;
        
        return Container(
          padding: const EdgeInsets.all(AppThemes.spaceM),
          decoration: BoxDecoration(
            gradient: theme.cardGradient,
            borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            border: Border.all(
              color: theme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${currentStep + 1} of $totalSteps',
                    style: AppThemes.labelMedium(theme).copyWith(
                      color: theme.primary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppThemes.labelMedium(theme).copyWith(
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppThemes.spaceS),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppThemes.spaceXS),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
              
              const SizedBox(height: AppThemes.spaceS),
              
              // Current Step Title
              if (currentStep < stepTitles.length)
                Text(
                  stepTitles[currentStep],
                  style: AppThemes.bodyMedium(theme).copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AppStatusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget? action;

  const AppStatusCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;
        
        return AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppThemes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppThemes.titleMedium(theme).copyWith(color: color),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppThemes.spaceXS),
                      Text(subtitle!, style: AppThemes.bodyMedium(theme)),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
        );
      },
    );
  }
}

class AppEmptyCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;
        
        return AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.textHint,
              ),
              const SizedBox(height: AppThemes.spaceM),
              Text(
                title,
                style: AppThemes.titleMedium(theme).copyWith(
                  color: theme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceS),
              Text(
                message,
                style: AppThemes.bodyMedium(theme),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppThemes.spaceL),
                AppTextButton(
                  text: actionText!,
                  onPressed: onAction,
                  width: 200,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
