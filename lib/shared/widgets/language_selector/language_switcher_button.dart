import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/localization_service.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_themes.dart';

/// Language switcher button that appears next to the theme selector
class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.language,
              color: theme.secondary,
              size: 20,
            ),
          ),
          onPressed: () => _showLanguageSelector(context, themeProvider),
          tooltip: 'Change Language',
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, ThemeProvider themeProvider) {
    final currentLanguage = LocalizationService.instance.currentLanguage;
    
    showDialog(
      context: context,
      builder: (context) => _LanguageSelectorDialog(
        currentLanguage: currentLanguage,
        themeProvider: themeProvider,
      ),
    );
  }
}

class _LanguageSelectorDialog extends StatelessWidget {
  final String currentLanguage;
  final ThemeProvider themeProvider;

  const _LanguageSelectorDialog({
    required this.currentLanguage,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeProvider.currentTheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppThemes.spaceL),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppThemes.spaceS),
                  decoration: BoxDecoration(
                    color: theme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppThemes.spaceS),
                  ),
                  child: Icon(
                    Icons.language,
                    color: theme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'themes.selectTheme'.tr(),
                        style: AppThemes.titleLarge(theme),
                      ),
                      const SizedBox(height: AppThemes.spaceXS),
                      Text(
                        'themes.themeDescription'.tr(),
                        style: AppThemes.bodySmall(theme),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Language Options
            ...LocalizationService.instance.supportedLanguages.map((lang) {
              final isSelected = lang['code'] == currentLanguage;
              
              return _LanguageOption(
                languageCode: lang['code']!,
                languageName: lang['name']!,
                isSelected: isSelected,
                onTap: () async {
                  await LocalizationService.instance.loadLanguage(lang['code']!);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageCode,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppThemes.spaceM),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1) 
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Language Flag/Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppThemes.spaceS),
                ),
                child: Icon(
                  Icons.public,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: AppThemes.spaceM),
              
              // Language Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppThemes.spaceXS),
                    Text(
                      languageCode.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selected Indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(AppThemes.spaceXS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
