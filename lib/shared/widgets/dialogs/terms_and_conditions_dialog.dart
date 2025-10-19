import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../../core/services/localization_service.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  final AppThemeData theme;

  const TermsAndConditionsDialog({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'onboarding.terms.title'.tr(),
        style: AppThemes.titleLarge(theme),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'onboarding.terms.subscriptionTerms'.tr(),
              style: AppThemes.titleMedium(theme).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppThemes.spaceS),
            Text(
              'onboarding.terms.agreeLine'.tr(),
              style: AppThemes.bodyMedium(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            _buildTermsSection(
              'onboarding.terms.section1.title'.tr(),
              'onboarding.terms.section1.content'.tr(),
            ),
            
            _buildTermsSection(
              'onboarding.terms.section2.title'.tr(),
              'onboarding.terms.section2.content'.tr(),
            ),
            
            _buildTermsSection(
              'onboarding.terms.section3.title'.tr(),
              'onboarding.terms.section3.content'.tr(),
            ),
            
            _buildTermsSection(
              'onboarding.terms.section4.title'.tr(),
              'onboarding.terms.section4.content'.tr(),
            ),
            
            _buildTermsSection(
              'onboarding.terms.section5.title'.tr(),
              'onboarding.terms.section5.content'.tr(),
            ),
            
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'onboarding.terms.footer'.tr(),
              style: AppThemes.bodySmall(theme).copyWith(
                fontStyle: FontStyle.italic,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'common.close'.tr(),
            style: TextStyle(color: theme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppThemes.titleMedium(theme).copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: AppThemes.spaceXS),
          Text(
            content,
            style: AppThemes.bodySmall(theme),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TermsAndConditionsDialog(theme: theme);
      },
    );
  }
}

