import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';

class TermsDialog {
  /// Show terms and conditions dialog
  static void show(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.largeRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.all(AppConstants.largeSpace),
                    decoration: BoxDecoration(
                      color: theme.backgroundGray,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.largeRadius),
                        topRight: Radius.circular(AppConstants.largeRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppConstants.mediumSpace),
                        Expanded(
                          child: Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.largeSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By using our service, you agree to the following terms:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textDark,
                          ),
                        ),
                        const SizedBox(height: AppConstants.mediumSpace),
                        
                        // Terms list
                        _buildTermsItem(theme, 'Payment Processing', 'All payments are processed securely through our payment partners. We do not store your payment information.'),
                        const SizedBox(height: AppConstants.mediumSpace),
                        _buildTermsItem(theme, 'Fees and Charges', 'We charge a small commission on each sale to cover platform costs and services. All fees are clearly displayed before checkout.'),
                        const SizedBox(height: AppConstants.mediumSpace),
                        _buildTermsItem(theme, 'Verification', 'We may require identity verification for security purposes. This helps protect both buyers and sellers on our platform.'),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.largeSpace,
                      0,
                      AppConstants.largeSpace,
                      AppConstants.largeSpace,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                          ),
                        ),
                        child: const Text(
                          'I Understand',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  /// Helper method to build terms items
  static Widget _buildTermsItem(AppThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: theme.textGray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
