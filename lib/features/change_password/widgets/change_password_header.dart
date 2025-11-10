import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';

class ChangePasswordHeader extends StatelessWidget {
  final AppThemeData theme;
  final AppThemeType themeType;

  const ChangePasswordHeader({
    super.key,
    required this.theme,
    required this.themeType,
  });

  @override
  Widget build(BuildContext context) {
    String _logoForTheme(AppThemeType t) {
      switch (t) {
        case AppThemeType.coffee:
          return 'assets/logo/logo-coffe.png';
        case AppThemeType.green:
          return 'assets/logo/logo-green.png';
        case AppThemeType.basic:
          return 'assets/logo/logo-basic.png';
      }
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                _logoForTheme(themeType),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'changePassword.title'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'changePassword.subtitle'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
