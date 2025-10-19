import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

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
        'Terms and Conditions',
        style: AppThemes.titleLarge(theme),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Subscription Terms',
              style: AppThemes.titleMedium(theme).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppThemes.spaceS),
            Text(
              'By subscribing to our service, you agree to the following terms:',
              style: AppThemes.bodyMedium(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            _buildTermsSection(
              '1. Subscription Plans',
              '• You can upgrade or downgrade your plan at any time\n• Changes take effect at the next billing cycle\n• Prorated charges may apply for upgrades',
            ),
            
            _buildTermsSection(
              '2. Payment Terms',
              '• All payments are processed securely\n• Billing occurs automatically on your subscription date\n• Failed payments may result in service suspension',
            ),
            
            _buildTermsSection(
              '3. Cancellation Policy',
              '• You can cancel your subscription at any time\n• No cancellation fees apply\n• Access continues until the end of your billing period',
            ),
            
            _buildTermsSection(
              '4. Service Availability',
              '• We strive for 99.9% uptime\n• Scheduled maintenance will be announced in advance\n• We are not liable for temporary service interruptions',
            ),
            
            _buildTermsSection(
              '5. Data and Privacy',
              '• Your data is protected according to our Privacy Policy\n• We do not sell your personal information\n• You retain ownership of your business data',
            ),
            
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'By checking the agreement box, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions.',
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
            'Close',
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

