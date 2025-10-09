import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home_outlined, 0),
                _buildNavIcon(Icons.shopping_bag_outlined, 1),
                _buildCenterButton(),
                _buildNavIcon(Icons.inventory_2_outlined, 2),
                _buildNavIcon(Icons.account_balance_wallet_outlined, 3),
                _buildNavIcon(Icons.person_outline, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final currentIndex = _getCurrentIndex(context);
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/orders');
            break;
          case 2:
            context.go('/products');
            break;
          case 3:
            context.go('/wallet');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? Colors.black87 : Colors.grey[400],
      ),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          // Add action for center button - could open add product
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
