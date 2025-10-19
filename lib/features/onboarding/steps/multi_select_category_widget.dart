import 'package:flutter/material.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';

class MultiSelectCategoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;
  final AppThemeData theme;

  const MultiSelectCategoryWidget({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onChanged,
    required this.theme,
  });

  @override
  State<MultiSelectCategoryWidget> createState() => _MultiSelectCategoryWidgetState();
}

class _MultiSelectCategoryWidgetState extends State<MultiSelectCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selectedCategories.isNotEmpty) ...[
            Text(
              '${'onboarding.basicInfo.selectedCategories'.tr()} (${widget.selectedCategories.length})',
              style: AppThemes.titleMedium(widget.theme),
            ),
          const SizedBox(height: AppThemes.spaceS),
          Wrap(
            spacing: AppThemes.spaceS,
            runSpacing: AppThemes.spaceS,
            children: widget.selectedCategories.map((categoryId) {
              final category = widget.categories.firstWhere(
                (cat) => cat['id'].toString() == categoryId,
                orElse: () => {'name': 'onboarding.basicInfo.unknown'.tr(), 'icon': Icons.category, 'color': widget.theme.primary},
              );
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceM,
                  vertical: AppThemes.spaceS,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(color: widget.theme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] ?? Icons.category,
                      color: widget.theme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppThemes.spaceS),
                    Text(
                      category['name'] ?? 'onboarding.basicInfo.unknown'.tr(),
                      style: AppThemes.bodySmall(widget.theme).copyWith(
                        color: widget.theme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppThemes.spaceS),
                    GestureDetector(
                      onTap: () {
                        final updatedCategories = List<String>.from(widget.selectedCategories);
                        updatedCategories.remove(categoryId);
                        widget.onChanged(updatedCategories);
                      },
                      child: Icon(
                        Icons.close,
                        color: widget.theme.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppThemes.spaceM),
        ],
        Text(
          'onboarding.basicInfo.selectCategories'.tr(),
          style: AppThemes.titleMedium(widget.theme),
        ),
        const SizedBox(height: AppThemes.spaceS),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: AppThemes.spaceS,
            mainAxisSpacing: AppThemes.spaceS,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final category = widget.categories[index];
            final categoryId = category['id'].toString();
            final isSelected = widget.selectedCategories.contains(categoryId);
            return GestureDetector(
              onTap: () {
                final updatedCategories = List<String>.from(widget.selectedCategories);
                if (isSelected) {
                  updatedCategories.remove(categoryId);
                } else {
                  updatedCategories.add(categoryId);
                }
                widget.onChanged(updatedCategories);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? widget.theme.primary.withOpacity(0.1)
                      : widget.theme.surface,
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(
                    color: isSelected 
                        ? widget.theme.primary
                        : widget.theme.accent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppThemes.spaceS),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] ?? Icons.category,
                        color: isSelected 
                            ? widget.theme.primary
                            : widget.theme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: AppThemes.spaceS),
                      Expanded(
                        child: Text(
                          category['name'] ?? 'onboarding.basicInfo.unknown'.tr(),
                          style: AppThemes.bodySmall(widget.theme).copyWith(
                            color: isSelected 
                                ? widget.theme.primary
                                : widget.theme.textPrimary,
                            fontWeight: isSelected 
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: widget.theme.primary,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.selectedCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppThemes.spaceS),
            child: Text(
              'onboarding.basicInfo.selectAtLeastOne'.tr(),
              style: AppThemes.bodySmall(widget.theme).copyWith(
                color: widget.theme.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}


