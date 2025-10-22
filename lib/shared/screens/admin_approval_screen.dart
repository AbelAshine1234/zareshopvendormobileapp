import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../shared.dart';
import '../../core/services/localization_service.dart';
import '../utils/theme/theme_provider.dart';
import '../../features/onboarding/bloc/onboarding_bloc.dart';
import '../../features/onboarding/bloc/onboarding_event.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight,
        maxHeight: screenHeight,
      ),
      child: Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'onboarding.adminApproval.readyTitle'.tr(),
          style: AppThemes.titleLarge(theme),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate explicitly since admin-approval was opened via context.go
                  context.go('/login');
                },
              )
            : null,
        // Removed theme and language selectors
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content - Made scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppThemes.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(theme),
                    const SizedBox(height: AppThemes.spaceXL),
                    
                    // Pending Approval Card
                    _buildPendingApprovalCard(theme),
                    const SizedBox(height: AppThemes.spaceXL),
                    
                    // What Happens Next
                    _buildWhatHappensNext(theme),
                    
                    // Add extra space at bottom to account for fixed buttons
                    const SizedBox(height: AppThemes.spaceXL * 2),
                  ],
                ),
              ),
            ),
            
            // Action Buttons - Fixed at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppThemes.spaceL),
              decoration: BoxDecoration(
                color: theme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppSecondaryButton(
                      text: 'onboarding.vendorSubmitted.contactHelp'.tr(),
                      icon: Icons.support_agent,
                      onPressed: () {
                        ContactHelpDialog.show(context, theme);
                      },
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
  }

  Widget _buildHeaderSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemes.spaceXL),
      decoration: AppThemes.cardDecoration(theme),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            ),
            child: Center(
              child: Icon(
                Icons.hourglass_empty_rounded,
                color: theme.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: AppThemes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'onboarding.adminApproval.readyTitle'.tr(),
                  style: AppThemes.headlineMedium(theme),
                ),
                const SizedBox(height: AppThemes.spaceS),
                Text(
                  'onboarding.adminApproval.reviewIntro'.tr(),
                  style: AppThemes.bodyLarge(theme).copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalCard(AppThemeData theme) {
    return Container(
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
            width: 80, // Reduced size
            height: 80, // Reduced size
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 40, // Reduced size
                color: theme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppThemes.spaceL),
          Text(
            'onboarding.adminApproval.awaitingTitle'.tr(),
            style: AppThemes.titleLarge(theme).copyWith( // Reduced text size
              color: theme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppThemes.spaceM),
          Text(
            'onboarding.adminApproval.awaitingDesc'.tr(),
            style: AppThemes.bodyMedium(theme),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWhatHappensNext(AppThemeData theme) {
    return Container(
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
              Expanded(
                child: Text(
                  'onboarding.adminApproval.whatNext'.tr(),
                  style: AppThemes.titleLarge(theme).copyWith(
                    color: theme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceM),
          _buildTimelineItem(
            theme,
            icon: Icons.upload_file,
            title: 'onboarding.adminApproval.timelineSubmittedTitle'.tr(),
            description: 'onboarding.adminApproval.timelineSubmittedDesc'.tr(),
            isCompleted: true,
          ),
          _buildTimelineItem(
            theme,
            icon: Icons.admin_panel_settings,
            title: 'onboarding.adminApproval.timelineReviewTitle'.tr(),
            description: 'onboarding.adminApproval.timelineReviewDesc'.tr(),
            isCompleted: false,
          ),
          _buildTimelineItem(
            theme,
            icon: Icons.notifications_active,
            title: 'onboarding.adminApproval.timelineNotifyTitle'.tr(),
            description: 'onboarding.adminApproval.timelineNotifyDesc'.tr(),
            isCompleted: false,
          ),
          _buildTimelineItem(
            theme,
            icon: Icons.store,
            title: 'onboarding.adminApproval.timelineStartTitle'.tr(),
            description: 'onboarding.adminApproval.timelineStartDesc'.tr(),
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    AppThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppThemes.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28, // Reduced size
                height: 28, // Reduced size
                decoration: BoxDecoration(
                  color: isCompleted ? theme.success : theme.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : icon,
                    color: isCompleted ? Colors.white : theme.textSecondary,
                    size: 14, // Reduced size
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32, // Reduced height
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
                  style: AppThemes.titleMedium(theme).copyWith( // Reduced text size
                    color: isCompleted ? theme.success : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXS),
                Text(
                  description,
                  style: AppThemes.bodySmall(theme).copyWith(
                    fontSize: 12, // Smaller font
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}