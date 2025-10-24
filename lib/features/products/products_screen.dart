import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/utils/theme/theme_provider.dart';
import '../../shared/utils/theme/app_themes.dart';
import '../../core/services/localization_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    // Mock products data
    final products = [
      {
        'name': 'Premium Arabica Coffee Beans',
        'price': 'ETB 450/kg',
        'stock': '500 kg',
        'status': 'In Stock',
        'image': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      },
      {
        'name': 'Ethiopian Yirgacheffe Coffee',
        'price': 'ETB 520/kg',
        'stock': '300 kg',
        'status': 'In Stock',
        'image': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200',
      },
      {
        'name': 'Sidamo Coffee Beans',
        'price': 'ETB 480/kg',
        'stock': '150 kg',
        'status': 'Low Stock',
        'image': 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=200',
      },
      {
        'name': 'Harar Coffee Beans',
        'price': 'ETB 500/kg',
        'stock': 'Out of Stock',
        'status': 'Out of Stock',
        'image': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=200',
      },
    ];

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'My Products',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(theme),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, theme);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Promotions Button
          FloatingActionButton.extended(
            onPressed: () => _showPromotionsDialog(context, theme),
            backgroundColor: theme.secondary,
            heroTag: 'promotions',
            icon: const Icon(Icons.local_offer, color: Colors.white),
            label: const Text(
              'Promotions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Add Product Button
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );
            },
            backgroundColor: theme.primary,
            heroTag: 'addProduct',
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Product',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, AppThemeData theme) {
    final isOutOfStock = product['status'] == 'Out of Stock';
    final isLowStock = product['status'] == 'Low Stock';
    
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(
              bottom: BorderSide(color: theme.divider.withOpacity(0.5), width: 1),
            ),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name and Edit Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Edit Button
                IconButton(
                  icon: Icon(Icons.edit, color: theme.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductScreen(product: product),
                      ),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Price and Stock Info
          Row(
            children: [
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product['price'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Stock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.inputBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.divider),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product['stock'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? Colors.red.withOpacity(0.1)
                      : isLowStock
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product['status'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock
                        ? Colors.red
                        : isLowStock
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppThemeData theme) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.language_outlined, color: theme.textPrimary, size: 22),
              onPressed: () {
                final RenderBox button = context.findRenderObject() as RenderBox;
                _showLanguageMenu(context, themeProvider, button);
              },
            );
          },
        );
      },
    );
  }

  void _showLanguageMenu(BuildContext context, ThemeProvider themeProvider, RenderBox button) {
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

  // Promotions & Discounts Dialog
  void _showPromotionsDialog(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Row(
          children: [
            Icon(Icons.local_offer, color: theme.primary),
            const SizedBox(width: 12),
            Text(
              'Promotions & Discounts',
              style: TextStyle(color: theme.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage your product promotions and discounts',
                style: TextStyle(color: theme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Promotion Options
              _buildPromotionOption(
                theme,
                icon: Icons.discount,
                title: 'Create Discount Code',
                subtitle: 'Generate coupon codes',
                badge: '3 Active',
                onTap: () {
                  Navigator.pop(context);
                  _showCreateDiscountDialog(context, theme);
                },
              ),
              const SizedBox(height: 12),
              _buildPromotionOption(
                theme,
                icon: Icons.flash_on,
                title: 'Flash Sales',
                subtitle: 'Limited time offers',
                badge: '1 Active',
                onTap: () {
                  Navigator.pop(context);
                  _showFlashSaleDialog(context, theme);
                },
              ),
              const SizedBox(height: 12),
              _buildPromotionOption(
                theme,
                icon: Icons.shopping_cart,
                title: 'Bulk Discounts',
                subtitle: 'Discounts for large orders',
                onTap: () {
                  Navigator.pop(context);
                  _showBulkDiscountDialog(context, theme);
                },
              ),
              const SizedBox(height: 12),
              _buildPromotionOption(
                theme,
                icon: Icons.calendar_today,
                title: 'Seasonal Promotions',
                subtitle: 'Holiday & seasonal offers',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Seasonal promotions screen'),
                      backgroundColor: theme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionOption(
    AppThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: theme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  // Create Discount Code Dialog
  void _showCreateDiscountDialog(BuildContext context, AppThemeData theme) {
    final codeController = TextEditingController();
    final percentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Create Discount Code',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.labelText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'e.g., SAVE20',
                  hintStyle: TextStyle(color: theme.textHint),
                  filled: true,
                  fillColor: theme.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.inputBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Discount Percentage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.labelText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: percentController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 20',
                  suffixText: '%',
                  hintStyle: TextStyle(color: theme.textHint),
                  filled: true,
                  fillColor: theme.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.inputBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Discount code created!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Flash Sale Dialog
  void _showFlashSaleDialog(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.orange),
            const SizedBox(width: 12),
            Text(
              'Flash Sale',
              style: TextStyle(color: theme.textPrimary),
            ),
          ],
        ),
        content: Text(
          'Create limited-time flash sales with countdown timers to boost urgency and sales.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Flash sale feature coming soon!'),
                  backgroundColor: theme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Create Flash Sale', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Bulk Discount Dialog
  void _showBulkDiscountDialog(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Bulk Discount Tiers',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set discounts based on order quantity',
                style: TextStyle(color: theme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildBulkTier(theme, '10-49 units', '5% off'),
              _buildBulkTier(theme, '50-99 units', '10% off'),
              _buildBulkTier(theme, '100+ units', '15% off'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bulk discounts saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkTier(AppThemeData theme, String quantity, String discount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            quantity,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              discount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
