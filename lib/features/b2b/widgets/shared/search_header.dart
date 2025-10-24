import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/utils/theme/app_themes.dart';
import '../../../../shared/utils/theme/theme_provider.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/services/cart_service.dart';

class B2BSearchHeader extends StatelessWidget {
  final AppThemeData theme;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const B2BSearchHeader({
    super.key,
    required this.theme,
    required this.searchController,
    required this.onSearchChanged,
  });

  void _showLanguageSelector(BuildContext context, ThemeProvider themeProvider, RenderBox button) {
    final currentLanguage = LocalizationService.instance.currentLanguage;
    final buttonPosition = button.localToGlobal(Offset.zero);
    final buttonSize = button.size;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + 200,
        buttonPosition.dy,
      ),
      items: LocalizationService.instance.supportedLanguages.map((lang) {
        final isSelected = lang['code'] == currentLanguage;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(
            children: [
              Icon(
                Icons.language_outlined,
                size: 20,
                color: isSelected ? themeProvider.currentTheme.primary : themeProvider.currentTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                lang['name']!,
                style: TextStyle(
                  color: isSelected ? themeProvider.currentTheme.primary : themeProvider.currentTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: themeProvider.currentTheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedCode) {
      if (selectedCode != null) {
        LocalizationService.instance.loadLanguage(selectedCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.primary,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.inputBorder),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.search, color: theme.primary, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: theme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: theme.textHint),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language Selector
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.language_outlined, color: Colors.white, size: 22),
                    onPressed: () {
                      final RenderBox button = context.findRenderObject() as RenderBox;
                      _showLanguageSelector(context, themeProvider, button);
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 4),
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: Colors.white, size: 22),
                onPressed: () {
                  context.go('/messages?tab=2');
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Cart Icon - Dynamic
          Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                    onPressed: () {
                      context.go('/cart');
                    },
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
