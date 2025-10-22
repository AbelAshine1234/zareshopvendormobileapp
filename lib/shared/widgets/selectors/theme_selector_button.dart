import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme/theme_provider.dart';
import '../../utils/theme/app_themes.dart';

/// Global theme selector button that appears in the top-right corner
/// Similar to dark mode toggles in other apps
class ThemeSelectorButton extends StatelessWidget {
  const ThemeSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: theme.primary,
              size: 20,
            ),
          ),
          onPressed: () => _showThemeSelector(context, themeProvider),
          tooltip: 'Change Theme',
          alignment: Alignment.center,
          style: IconButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => _ThemeSelectorDialog(themeProvider: themeProvider),
    );
  }
}

class _ThemeSelectorDialog extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeSelectorDialog({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final currentTheme = themeProvider.currentTheme;
    
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
                    color: currentTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppThemes.spaceS),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: currentTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Theme',
                        style: AppThemes.titleLarge(currentTheme),
                      ),
                      const SizedBox(height: AppThemes.spaceXS),
                      Text(
                        'Select a theme that matches your business',
                        style: AppThemes.bodySmall(currentTheme),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: currentTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Theme Options
            ...AppThemes.allThemes.map((themeData) {
              final isSelected = themeProvider.isThemeSelected(
                AppThemeType.values[AppThemes.allThemes.indexOf(themeData)]
              );
              
              return _ThemeOption(
                theme: themeData,
                isSelected: isSelected,
                onTap: () {
                  themeProvider.setTheme(
                    AppThemeType.values[AppThemes.allThemes.indexOf(themeData)]
                  );
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

class _ThemeOption extends StatelessWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
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
                ? theme.primary.withOpacity(0.1) 
                : theme.surface,
            borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            border: Border.all(
              color: isSelected 
                  ? theme.primary 
                  : theme.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Color Preview
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppThemes.spaceS),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: AppThemes.spaceM),
              
              // Theme Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: AppThemes.spaceS),
                        Text(
                          theme.name,
                          style: AppThemes.titleMedium(theme).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppThemes.spaceXS),
                    Text(
                      theme.description,
                      style: AppThemes.bodySmall(theme).copyWith(
                        color: theme.subtext,
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
                    color: theme.primary,
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
