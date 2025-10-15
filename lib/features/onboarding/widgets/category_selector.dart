import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Color(0xFF6366F1)},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Color(0xFFEC4899)},
    {'name': 'Food & Beverage', 'icon': Icons.restaurant, 'color': Color(0xFFF59E0B)},
    {'name': 'Beauty & Health', 'icon': Icons.spa, 'color': Color(0xFF8B5CF6)},
    {'name': 'Home & Garden', 'icon': Icons.home, 'color': Color(0xFF10B981)},
    {'name': 'Sports & Outdoor', 'icon': Icons.sports_soccer, 'color': Color(0xFF3B82F6)},
    {'name': 'Books & Media', 'icon': Icons.menu_book, 'color': Color(0xFFF97316)},
    {'name': 'Toys & Kids', 'icon': Icons.toys, 'color': Color(0xFFEF4444)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return _AnimatedCategoryTile(
              name: category['name'] as String,
              icon: category['icon'] as IconData,
              color: category['color'] as Color,
              isSelected: isSelected,
              index: index,
              onTap: () => onCategorySelected(category['name'] as String),
            );
          },
        ),
      ],
    );
  }
}

class _AnimatedCategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _AnimatedCategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 0.8, end: isSelected ? 1.0 : 0.8),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected ? color : Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
