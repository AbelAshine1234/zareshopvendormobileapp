import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';

/// Model for category data from API
class CategoryModel {
  final int id;
  final String name;
  final String description;
  final bool status;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Removed separate card/grid widgets to keep a single, clean widget

/// Widget for selecting categories with icon display
class CategorySelectionWidget extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<int> selectedCategoryIds;
  final Function(List<int>) onCategoriesChanged;
  final AppThemeData theme;
  final bool isLoading;
  final String? errorMessage;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onCategoriesChanged,
    required this.theme,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<CategorySelectionWidget> createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (widget.isLoading) _buildLoadingBox(),
        if (!widget.isLoading && widget.errorMessage != null) _buildErrorBox(widget.errorMessage!),
        if (!widget.isLoading && widget.errorMessage == null && widget.categories.isEmpty)
          _buildEmptyBox(),
        if (!widget.isLoading && widget.errorMessage == null && widget.categories.isNotEmpty)
          _buildChips(),
        if (widget.selectedCategoryIds.isNotEmpty) _buildSelectionCount(),
      ],
    );
  }

  void _onCategorySelected(CategoryModel category) {
    final updatedIds = List<int>.from(widget.selectedCategoryIds);
    
    if (updatedIds.contains(category.id)) {
      updatedIds.remove(category.id);
    } else {
      updatedIds.add(category.id);
    }
    
    widget.onCategoriesChanged(updatedIds);
  }

  // UI helpers
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Categories', style: AppThemes.titleMedium(widget.theme)),
        const SizedBox(height: AppThemes.spaceS),
        Text(
          'Choose the categories that best describe your business',
          style: AppThemes.bodyMedium(widget.theme).copyWith(color: widget.theme.textSecondary),
        ),
        const SizedBox(height: AppThemes.spaceL),
      ],
    );
  }

  Widget _buildLoadingBox() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
        border: Border.all(color: widget.theme.inputBorder, width: 1),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: widget.theme.primary, strokeWidth: 2),
            ),
            const SizedBox(width: AppThemes.spaceS),
            Text('Loading categories...', style: AppThemes.bodyMedium(widget.theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemes.spaceM),
      decoration: BoxDecoration(
        color: widget.theme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
        border: Border.all(color: widget.theme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: widget.theme.error, size: 20),
          const SizedBox(width: AppThemes.spaceS),
          Expanded(
            child: Text(message, style: AppThemes.bodySmall(widget.theme).copyWith(color: widget.theme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(AppThemes.largeBorderRadius),
        border: Border.all(color: widget.theme.inputBorder, width: 1),
      ),
      child: Center(
        child: Text('No categories available', style: AppThemes.bodyMedium(widget.theme)),
      ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.categories.map((category) {
        final isSelected = widget.selectedCategoryIds.contains(category.id);
        final borderColor = isSelected ? widget.theme.primary : widget.theme.inputBorder;
        final backgroundColor = isSelected 
            ? widget.theme.primary.withOpacity(0.1) 
            : widget.theme.surface;
        
        return GestureDetector(
          onTap: () => _onCategorySelected(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: widget.theme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(category),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatCategoryName(category.name),
                    style: AppThemes.bodyMedium(widget.theme).copyWith(
                      color: isSelected ? widget.theme.primary : widget.theme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: widget.theme.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionCount() {
    return Padding(
      padding: const EdgeInsets.only(top: AppThemes.spaceM),
      child: Text(
        '${widget.selectedCategoryIds.length} categories selected',
        style: AppThemes.bodySmall(widget.theme).copyWith(color: widget.theme.primary, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAvatar(CategoryModel category) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: widget.theme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _iconFor(category.name),
        color: widget.theme.primary,
        size: 14,
      ),
    );
  }

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    
    // Food & Beverages
    if (n.contains('food') || n.contains('restaurant') || n.contains('cafe') || 
        n.contains('beverage') || n.contains('drink') || n.contains('coffee') || 
        n.contains('tea') || n.contains('juice') || n.contains('snack')) {
      return Icons.restaurant;
    }
    
    // Fashion & Clothing
    if (n.contains('fashion') || n.contains('cloth') || n.contains('apparel') || 
        n.contains('dress') || n.contains('shirt') || n.contains('shoes') || 
        n.contains('accessories') || n.contains('jewelry') || n.contains('bag')) {
      return Icons.checkroom;
    }
    
    // Electronics & Technology
    if (n.contains('electronic') || n.contains('tech') || n.contains('phone') || 
        n.contains('computer') || n.contains('laptop') || n.contains('tablet') || 
        n.contains('gadget') || n.contains('device') || n.contains('camera') || 
        n.contains('headphone') || n.contains('speaker')) {
      return Icons.phone_android;
    }
    
    // Beauty & Health
    if (n.contains('beauty') || n.contains('health') || n.contains('cosmetic') || 
        n.contains('skincare') || n.contains('makeup') || n.contains('perfume') || 
        n.contains('wellness') || n.contains('supplement') || n.contains('vitamin')) {
      return Icons.spa;
    }
    
    // Home & Garden
    if (n.contains('home') || n.contains('furniture') || n.contains('decor') || 
        n.contains('garden') || n.contains('kitchen') || n.contains('bedroom') || 
        n.contains('living') || n.contains('outdoor') || n.contains('plant')) {
      return Icons.home;
    }
    
    // Sports & Fitness
    if (n.contains('sport') || n.contains('fitness') || n.contains('gym') || 
        n.contains('exercise') || n.contains('outdoor') || n.contains('equipment') || 
        n.contains('bike') || n.contains('running') || n.contains('swimming')) {
      return Icons.fitness_center;
    }
    
    // Education & Books
    if (n.contains('book') || n.contains('education') || n.contains('school') || 
        n.contains('learning') || n.contains('course') || n.contains('training') || 
        n.contains('academic') || n.contains('study')) {
      return Icons.school;
    }
    
    // Automotive
    if (n.contains('auto') || n.contains('car') || n.contains('vehicle') || 
        n.contains('motorcycle') || n.contains('bike') || n.contains('truck') || 
        n.contains('parts') || n.contains('accessories')) {
      return Icons.directions_car;
    }
    
    // Manufacturing & Industrial
    if (n.contains('manufactur') || n.contains('factory') || n.contains('production') || 
        n.contains('industrial') || n.contains('machinery') || n.contains('equipment') || 
        n.contains('tools') || n.contains('construction')) {
      return Icons.factory;
    }
    
    // Services
    if (n.contains('service') || n.contains('consulting') || n.contains('repair') || 
        n.contains('maintenance') || n.contains('cleaning') || n.contains('delivery') || 
        n.contains('transport') || n.contains('logistics')) {
      return Icons.build;
    }
    
    // Arts & Crafts
    if (n.contains('art') || n.contains('craft') || n.contains('handmade') || 
        n.contains('creative') || n.contains('design') || n.contains('painting') || 
        n.contains('sculpture') || n.contains('pottery')) {
      return Icons.palette;
    }
    
    // Toys & Games
    if (n.contains('toy') || n.contains('game') || n.contains('puzzle') || 
        n.contains('board') || n.contains('video') || n.contains('entertainment') || 
        n.contains('music') || n.contains('movie')) {
      return Icons.toys;
    }
    
    // Pet Supplies
    if (n.contains('pet') || n.contains('animal') || n.contains('dog') || 
        n.contains('cat') || n.contains('fish') || n.contains('bird') || 
        n.contains('supplies') || n.contains('food')) {
      return Icons.pets;
    }
    
    // Baby & Kids
    if (n.contains('baby') || n.contains('kid') || n.contains('child') || 
        n.contains('infant') || n.contains('toddler') || n.contains('diaper') || 
        n.contains('stroller') || n.contains('car seat')) {
      return Icons.child_care;
    }
    
    // Office & Stationery
    if (n.contains('office') || n.contains('stationery') || n.contains('paper') || 
        n.contains('pen') || n.contains('pencil') || n.contains('notebook') || 
        n.contains('supplies') || n.contains('business')) {
      return Icons.business;
    }
    
    return Icons.category;
  }

  String _formatCategoryName(String name) {
    // Convert to title case and clean up common formatting issues
    final words = name.toLowerCase().split(' ');
    final formattedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    
    return formattedWords.join(' ');
  }
}