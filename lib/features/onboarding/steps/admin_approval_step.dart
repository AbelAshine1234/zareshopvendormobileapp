import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class AdminApprovalStep extends StatelessWidget {
  final AppThemeData theme;

  const AdminApprovalStep({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to Submit',
              style: AppThemes.headlineLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'Review your information and submit your application for admin approval.',
              style: AppThemes.bodyLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Pending Approval Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppThemes.spaceXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary.withValues(alpha: 0.1),
                    theme.accent.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_empty_rounded,
                      size: 50,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceL),
                  Text(
                    'Awaiting Admin Approval',
                    style: AppThemes.headlineMedium(theme).copyWith(
                      color: theme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'Your application will be reviewed by our admin team within 24-48 hours. You\'ll receive a notification once approved.',
                    style: AppThemes.bodyMedium(theme),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceXL),
            
            // What Happens Next
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceL),
              decoration: AppThemes.cardDecoration(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.success,
                        size: 24,
                      ),
                      const SizedBox(width: AppThemes.spaceM),
                      Text(
                        'What Happens Next?',
                        style: AppThemes.titleLarge(theme).copyWith(
                          color: theme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  _buildTimelineItem(
                    icon: Icons.upload_file,
                    title: 'Application Submitted',
                    description: 'Your vendor application has been submitted successfully',
                    isCompleted: true,
                  ),
                  _buildTimelineItem(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Review',
                    description: 'Our team will review your documents and business information',
                    isCompleted: false,
                  ),
                  _buildTimelineItem(
                    icon: Icons.notifications_active,
                    title: 'Approval Notification',
                    description: 'You\'ll receive an email and app notification when approved',
                    isCompleted: false,
                  ),
                  _buildTimelineItem(
                    icon: Icons.store,
                    title: 'Start Selling',
                    description: 'Begin adding products and managing your store',
                    isCompleted: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceXL),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    text: 'Contact Help',
                    icon: Icons.support_agent,
                    onPressed: () {
                      ContactHelpDialog.show(context, theme);
                    },
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: AppPrimaryButton(
                    text: 'Submit Application',
                    onPressed: () {
                      context.read<OnboardingBloc>().add(const CompleteOnboarding());
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? theme.success : theme.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isCompleted ? Colors.white : theme.textSecondary,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: theme.accent,
                margin: const EdgeInsets.symmetric(vertical: AppThemes.spaceXS),
              ),
          ],
        ),
        const SizedBox(width: AppThemes.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppThemes.titleMedium(theme).copyWith(
                  color: isCompleted ? theme.success : theme.textPrimary,
                ),
              ),
              const SizedBox(height: AppThemes.spaceXS),
              Text(
                description,
                style: AppThemes.bodySmall(theme),
              ),
              if (!isLast) const SizedBox(height: AppThemes.spaceM),
            ],
          ),
        ),
      ],
    );
  }
}
