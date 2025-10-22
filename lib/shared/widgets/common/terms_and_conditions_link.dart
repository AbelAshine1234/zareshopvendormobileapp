import 'package:flutter/material.dart';
import '../../utils/theme/app_themes.dart';
import '../dialogs/terms_and_conditions_dialog.dart';
import '../../../core/services/localization_service.dart';

class TermsAndConditionsLink extends StatelessWidget {
  final AppThemeData theme;
  final String? prefixText;
  final String? suffixText;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;

  const TermsAndConditionsLink({
    super.key,
    required this.theme,
    this.prefixText,
    this.suffixText,
    this.textStyle,
    this.linkStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = textStyle ?? AppThemes.bodyMedium(theme);
    final defaultLinkStyle = linkStyle ?? AppThemes.bodyMedium(theme).copyWith(
      color: theme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return RichText(
      text: TextSpan(
        children: [
          if (prefixText != null) ...[
            TextSpan(
              text: prefixText,
              style: defaultTextStyle,
            ),
            const TextSpan(text: ' '),
          ],
          WidgetSpan(
            child: GestureDetector(
              onTap: () => TermsAndConditionsDialog.show(context, theme),
              child: Text(
                'onboarding.subscription.termsLink'.tr(),
                style: defaultLinkStyle,
              ),
            ),
          ),
          if (suffixText != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: suffixText,
              style: defaultTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

