import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../core/services/localization_service.dart';
import '../../core/services/cart_service.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  
  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/suppliers')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/messages')) return 3;
    if (location.startsWith('/products')) return 4;
    if (location.startsWith('/settings') || location.startsWith('/my-zare') || location.startsWith('/profile')) return 5;
    return 0; // Home (B2B Market) is default
  }

  String _getLocalizedText(String key, String fallback) {
    try {
      final localization = LocalizationService.instance;
      final translated = localization.translate(key);
      
      // If translation returns the key itself, use fallback
      if (translated == key) {
        return fallback;
      }
      return translated;
    } catch (e) {
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
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              index: 0,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/b2b-market'),
            ),
            _buildNavItem(
              icon: Icons.local_shipping_outlined,
              selectedIcon: Icons.local_shipping,
              label: 'Suppliers',
              index: 1,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/suppliers'),
            ),
            _buildCartNavItem(
              index: 2,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/cart'),
            ),
            _buildNavItem(
              icon: Icons.message_outlined,
              selectedIcon: Icons.message,
              label: 'Messenger',
              index: 3,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/messages'),
            ),
            _buildNavItem(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              label: 'My Products',
              index: 4,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/products'),
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'Settings',
              index: 5,
              currentIndex: currentIndex,
              theme: theme,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem({
    required int index,
    required int currentIndex,
    required AppThemeData theme,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected 
                ? theme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                      size: 20,
                      color: isSelected 
                        ? theme.primary 
                        : Colors.grey[600],
                    ),
                    if (cartService.itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartService.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                      ? theme.primary 
                      : Colors.grey[600],
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 20,
              color: isSelected 
                ? theme.primary 
                : Colors.grey[600],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                  ? theme.primary 
                  : Colors.grey[600],
                letterSpacing: 0,
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