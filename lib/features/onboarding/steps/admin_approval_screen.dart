import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/app_themes.dart';
import '../../../shared/widgets/dialogs/contact_help_dialog.dart';
import '../../../shared/shared.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppThemes.spaceL),
              child: Column(
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          print('🔙 [ADMIN_APPROVAL] Back button pressed, navigating to splash');
                          context.go('/splash');
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.textPrimary,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.surface,
                          foregroundColor: theme.textPrimary,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Admin Approval',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                  // Approval Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_empty_rounded,
                      size: 60,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Title
                  Text(
                    'Awaiting Admin Approval',
                    style: AppThemes.displayLarge(theme).copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  
                  // Description
                  Text(
                    'Your vendor application is being reviewed by our admin team. You\'ll receive a notification once approved.',
                    style: AppThemes.bodyLarge(theme),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(AppThemes.spaceL),
                    decoration: BoxDecoration(
                      color: theme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                      border: Border.all(
                        color: theme.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: theme.info,
                        ),
                        const SizedBox(height: AppThemes.spaceM),
                        Text(
                          'What Happens Next?',
                          style: AppThemes.titleLarge(theme).copyWith(
                            color: theme.info,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppThemes.spaceS),
                        Text(
                          'Our team will review your documents and business information within 24-48 hours. You\'ll receive an email and app notification when approved.',
                          style: AppThemes.bodyMedium(theme),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXL),
                  
                  // Action Buttons
                  Column(
                    children: [
                      AppPrimaryButton(
                        text: 'Contact Support',
                        icon: Icons.support_agent,
                        onPressed: () {
                          ContactHelpDialog.show(context, theme);
                        },
                        width: double.infinity,
                        height: 52,
                      ),
                      const SizedBox(height: AppThemes.spaceM),
                      AppSecondaryButton(
                        text: 'Logout',
                        icon: Icons.logout,
                        onPressed: () {
                          // TODO: Implement logout functionality
                          context.go('/splash');
                        },
                        width: double.infinity,
                        height: 52,
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
}
