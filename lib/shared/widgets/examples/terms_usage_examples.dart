// Example usage of the global Terms and Conditions widgets
// This file shows how to use the widgets in different scenarios

import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../dialogs/terms_and_conditions_dialog.dart';
import '../common/terms_and_conditions_link.dart';

class TermsUsageExamples extends StatelessWidget {
  final AppThemeData theme;

  const TermsUsageExamples({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Example 1: Simple link with prefix text
        TermsAndConditionsLink(
          theme: theme,
          prefixText: 'I agree to the',
        ),
        
        const SizedBox(height: 16),
        
        // Example 2: Link with custom styling
        TermsAndConditionsLink(
          theme: theme,
          prefixText: 'By using this service, you agree to our',
          textStyle: AppThemes.bodySmall(theme),
          linkStyle: AppThemes.bodySmall(theme).copyWith(
            color: theme.warning,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Example 3: Direct dialog usage
        ElevatedButton(
          onPressed: () => TermsAndConditionsDialog.show(context, theme),
          child: const Text('View Terms'),
        ),
        
        const SizedBox(height: 16),
        
        // Example 4: Link with suffix text
        TermsAndConditionsLink(
          theme: theme,
          prefixText: 'Please read our',
          suffixText: 'before proceeding.',
        ),
      ],
    );
  }
}
