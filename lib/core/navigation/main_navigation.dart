import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../core/services/localization_service.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/wallet')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  String _getLocalizedText(String key, String fallback) {
    try {
      final localization = LocalizationService.instance;
      print('🌐 [NAVIGATION] Attempting to translate: $key');
      print('🌐 [NAVIGATION] Current language: ${localization.currentLanguage}');
      
      final translated = localization.translate(key);
      print('🌐 [NAVIGATION] Translation result: $translated');
      
      // If translation returns the key itself, use fallback
      if (translated == key) {
        print('🌐 [NAVIGATION] Using fallback: $fallback');
        return fallback;
      }
      return translated;
    } catch (e) {
      print('🌐 [NAVIGATION] Error translating $key: $e');
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Consumer<LocalizationService>(
        builder: (context, localization, child) {
          return _buildBottomNavBar(context);
        },
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.currentTheme;
    final currentIndex = _getCurrentIndex(context);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: _getLocalizedText('navigation.home', 'Home'),
              index: 0,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/'),
            ),
            _buildNavItem(
              icon: Icons.pie_chart_outline,
              selectedIcon: Icons.pie_chart,
              label: _getLocalizedText('navigation.portfolio', 'Portfolio'),
              index: 1,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/orders'),
            ),
            _buildNavItem(
              icon: Icons.work_outline,
              selectedIcon: Icons.work,
              label: _getLocalizedText('navigation.feed', 'Feed'),
              index: 2,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/products'),
            ),
            _buildNavItem(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet,
              label: _getLocalizedText('navigation.balance', 'Balance'),
              index: 3,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/wallet'),
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: _getLocalizedText('navigation.settings', 'Settings'),
              index: 4,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
    required AppThemeData theme,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected 
                ? theme.primary 
                : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                  ? theme.primary 
                  : Colors.grey[500],
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}