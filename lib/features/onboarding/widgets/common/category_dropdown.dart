import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/onboarding_bloc.dart';
import '../../bloc/onboarding_event.dart';
import '../../bloc/onboarding_state.dart';
import '../../core/onboarding_constants.dart';
import '../../core/onboarding_theme.dart';

class CategoryDropdown extends StatefulWidget {
  const CategoryDropdown({super.key});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Electronics', 'icon': Icons.devices},
    {'id': 2, 'name': 'Clothing', 'icon': Icons.checkroom},
    {'id': 3, 'name': 'Food & Beverages', 'icon': Icons.restaurant},
    {'id': 4, 'name': 'Home & Garden', 'icon': Icons.home},
    {'id': 5, 'name': 'Health & Beauty', 'icon': Icons.spa},
    {'id': 6, 'name': 'Sports & Recreation', 'icon': Icons.sports},
    {'id': 7, 'name': 'Books & Media', 'icon': Icons.book},
    {'id': 8, 'name': 'Automotive', 'icon': Icons.directions_car},
    {'id': 9, 'name': 'Toys & Games', 'icon': Icons.toys},
    {'id': 10, 'name': 'Services', 'icon': Icons.build},
  ];

  bool _isExpanded = false;
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingInProgress) {
          // Parse current selected categories
          final currentCategory = state.data.category;
          if (currentCategory.isNotEmpty && _selectedCategories.isEmpty) {
            _selectedCategories = currentCategory.contains(',')
                ? currentCategory.split(',').map((e) => e.trim()).toList()
                : [currentCategory];
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            RichText(
              text: const TextSpan(
                text: 'Business Category',
                style: OnboardingTheme.labelMedium,
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: OnboardingConstants.errorRed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OnboardingConstants.spaceS),
            
            // Category Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: OnboardingConstants.borderColor),
                borderRadius: BorderRadius.circular(OnboardingConstants.borderRadius),
              ),
              child: Column(
                children: [
                  // Header - shows selected categories or placeholder
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(OnboardingConstants.spaceM),
                      decoration: BoxDecoration(
                        color: OnboardingConstants.backgroundLight,
                        borderRadius: BorderRadius.circular(OnboardingConstants.borderRadius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: OnboardingConstants.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: OnboardingConstants.spaceM),
                          Expanded(
                            child: _selectedCategories.isEmpty
                                ? Text(
                                    'Select business categories',
                                    style: OnboardingTheme.bodyMedium.copyWith(
                                      color: OnboardingConstants.textSecondary,
                                    ),
                                  )
                                : Wrap(
                                    spacing: OnboardingConstants.spaceS,
                                    runSpacing: OnboardingConstants.spaceXS,
                                    children: _selectedCategories.map((category) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: OnboardingConstants.spaceS,
                                          vertical: OnboardingConstants.spaceXS,
                                        ),
                                        decoration: BoxDecoration(
                                          color: OnboardingConstants.primaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(OnboardingConstants.spaceS),
                                          border: Border.all(
                                            color: OnboardingConstants.primaryGreen.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: OnboardingConstants.fontSizeSmall,
                                            color: OnboardingConstants.primaryGreen,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: OnboardingConstants.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Expanded Category List
                  if (_isExpanded) ...[
                    const Divider(height: 1),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategories.contains(category['name']);
                            
                            return GestureDetector(
                              onTap: () => _toggleCategory(category['name']),
                              child: Container(
                                padding: const EdgeInsets.all(OnboardingConstants.spaceM),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? OnboardingConstants.primaryGreen.withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      category['icon'],
                                      color: isSelected 
                                          ? OnboardingConstants.primaryGreen
                                          : OnboardingConstants.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: OnboardingConstants.spaceM),
                                    Expanded(
                                      child: Text(
                                        category['name'],
                                        style: OnboardingTheme.bodyMedium.copyWith(
                                          color: isSelected 
                                              ? OnboardingConstants.primaryGreen
                                              : OnboardingConstants.textPrimary,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: OnboardingConstants.primaryGreen,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Helper Text
            if (_selectedCategories.isNotEmpty) ...[
              const SizedBox(height: OnboardingConstants.spaceS),
              Text(
                '${_selectedCategories.length} categor${_selectedCategories.length == 1 ? 'y' : 'ies'} selected',
                style: OnboardingTheme.bodyMedium.copyWith(
                  color: OnboardingConstants.primaryGreen,
                  fontSize: OnboardingConstants.fontSizeSmall,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      if (_selectedCategories.contains(categoryName)) {
        _selectedCategories.remove(categoryName);
      } else {
        _selectedCategories.add(categoryName);
      }
    });
    
    // Update bloc with new selection
    final categoryString = _selectedCategories.join(',');
    context.read<OnboardingBloc>().add(UpdateCategory(categoryString));
  }
}
