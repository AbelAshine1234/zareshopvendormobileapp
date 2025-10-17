import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class CategoryDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? selectedCategory;
  final Function(Map<String, dynamic>?) onChanged;
  final AppThemeData theme;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    required this.theme,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.theme.accent),
        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
        color: widget.theme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: widget.selectedCategory,
          hint: Padding(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            child: Text(
              'Select a category',
              style: AppThemes.bodyMedium(widget.theme).copyWith(
                color: widget.theme.textHint,
              ),
            ),
          ),
          isExpanded: true,
          items: widget.categories.map((category) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.all(AppThemes.spaceM),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] ?? Icons.category,
                      color: widget.theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppThemes.spaceM),
                    Text(
                      category['name'] ?? 'Unknown',
                      style: AppThemes.bodyMedium(widget.theme),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
