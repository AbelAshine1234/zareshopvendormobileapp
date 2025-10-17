import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    Widget card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppTheme.spaceL),
      margin: margin,
      decoration: AppTheme.cardDecoration.copyWith(
        color: color ?? AppTheme.backgroundSecondary,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
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
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppTheme.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceM),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppTheme.spaceXS),
                      Text(subtitle!, style: AppTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spaceL),
          
          // Content
          child,
        ],
      ),
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
    final cardColor = color ?? AppTheme.primaryGreen;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: cardColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceS),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.spaceS),
              ),
              child: Icon(
                icon,
                size: 16,
                color: cardColor,
              ),
            ),
            const SizedBox(width: AppTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: cardColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
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
    final progress = (currentStep + 1) / totalSteps;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
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
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spaceS),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.spaceXS),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryGreen,
              ),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: AppTheme.spaceS),
          
          // Current Step Title
          if (currentStep < stepTitles.length)
            Text(
              stepTitles[currentStep],
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
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
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(color: color),
                ),
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
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            message,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppTheme.spaceL),
            AppTextButton(
              text: actionText!,
              onPressed: onAction,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}
