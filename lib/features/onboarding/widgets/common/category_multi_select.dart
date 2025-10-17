import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class CategoryMultiSelect extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> selectedCategories;
  final Function(List<Map<String, dynamic>>) onChanged;
  final AppThemeData theme;

  const CategoryMultiSelect({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onChanged,
    required this.theme,
  });

  @override
  State<CategoryMultiSelect> createState() => _CategoryMultiSelectState();
}

class _CategoryMultiSelectState extends State<CategoryMultiSelect> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Categories (${widget.selectedCategories.length} selected)',
          style: AppThemes.titleMedium(widget.theme),
        ),
        const SizedBox(height: AppThemes.spaceS),
        Text(
          'Choose all categories that apply to your business',
          style: AppThemes.bodySmall(widget.theme).copyWith(
            color: widget.theme.textHint,
          ),
        ),
        const SizedBox(height: AppThemes.spaceM),
        
        // Categories Grid
        Wrap(
          spacing: AppThemes.spaceS,
          runSpacing: AppThemes.spaceS,
          children: widget.categories.map((category) {
            final bool isSelected = widget.selectedCategories.any(
              (selected) => selected['id'] == category['id']
            );
            
            return GestureDetector(
              onTap: () {
                List<Map<String, dynamic>> newSelection = List.from(widget.selectedCategories);
                
                if (isSelected) {
                  newSelection.removeWhere((selected) => selected['id'] == category['id']);
                } else {
                  newSelection.add(category);
                }
                
                widget.onChanged(newSelection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceM,
                  vertical: AppThemes.spaceS,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? widget.theme.primary.withValues(alpha: 0.1)
                      : widget.theme.surface,
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(
                    color: isSelected 
                        ? widget.theme.primary
                        : widget.theme.accent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] ?? Icons.category,
                      color: isSelected 
                          ? widget.theme.primary
                          : widget.theme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: AppThemes.spaceXS),
                    Text(
                      category['name'] ?? 'Unknown',
                      style: AppThemes.bodySmall(widget.theme).copyWith(
                        color: isSelected 
                            ? widget.theme.primary
                            : widget.theme.textPrimary,
                        fontWeight: isSelected 
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: AppThemes.spaceXS),
                      Icon(
                        Icons.check_circle,
                        color: widget.theme.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        // Selected Categories Summary
        if (widget.selectedCategories.isNotEmpty) ...[
          const SizedBox(height: AppThemes.spaceM),
          Container(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            decoration: BoxDecoration(
              color: widget.theme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadius),
              border: Border.all(
                color: widget.theme.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: widget.theme.success,
                  size: 20,
                ),
                const SizedBox(width: AppThemes.spaceM),
                Expanded(
                  child: Text(
                    'Selected: ${widget.selectedCategories.map((cat) => cat['name']).join(', ')}',
                    style: AppThemes.bodySmall(widget.theme).copyWith(
                      color: widget.theme.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
