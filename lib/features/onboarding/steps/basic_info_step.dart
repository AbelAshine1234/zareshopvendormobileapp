import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/category_selection_widget.dart';

class BasicInfoStep extends StatefulWidget {
  final AppThemeData theme;
  final List<Map<String, dynamic>> categories;
  final bool loadingCategories;

  const BasicInfoStep({
    super.key,
    required this.theme,
    required this.categories,
    required this.loadingCategories,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<int> _selectedCategories = [];
  bool _initializedFromState = false;

  /// Convert Map categories to CategoryModel objects
  List<CategoryModel> get _categoryModels {
    return widget.categories.map((cat) {
      return CategoryModel(
        id: cat['id'] as int,
        name: cat['name'] as String,
        description: cat['description'] as String? ?? '',
        status: true,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        if (!_initializedFromState) {
          _businessNameController.text = state.data.businessName;
          _descriptionController.text = state.data.businessDescription;
          _selectedCategories = state.data.categories
              .map((id) {
                try {
                  return int.parse(id);
                } catch (_) {
                  return null;
                }
              })
              .whereType<int>()
              .toList();
          _initializedFromState = true;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'onboarding.basicInfo.title'.tr(),
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'onboarding.basicInfo.subtitle'.tr(),
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Business Name
            Text(
              'onboarding.basicInfo.businessName'.tr(),
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _businessNameController,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateBusinessName(value));
              },
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'onboarding.basicInfo.nameHint'.tr(),
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Business Categories
            widget.loadingCategories
                ? Container(
                    height: 200,
                    decoration: AppThemes.cardDecoration(widget.theme),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(widget.theme.primary),
                            ),
                          ),
                          const SizedBox(width: AppThemes.spaceM),
                          Text(
                            'common.loading'.tr(),
                            style: AppThemes.bodyMedium(widget.theme),
                          ),
                        ],
                      ),
                    ),
                  )
                : CategorySelectionWidget(
                    categories: _categoryModels,
                    selectedCategoryIds: _selectedCategories,
                    onCategoriesChanged: (categoryIds) {
                      setState(() {
                        _selectedCategories = categoryIds;
                      });
                      // Update BLoC with selected category IDs as strings
                      final categoryIdsAsStrings = categoryIds.map((id) => id.toString()).toList();
                      context.read<OnboardingBloc>().add(UpdateCategories(categoryIdsAsStrings));
                    },
                    theme: widget.theme,
                    isLoading: widget.loadingCategories,
                  ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Business Description
            Text(
              'onboarding.basicInfo.businessDescription'.tr(),
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _descriptionController,
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateBusinessDescription(value));
              },
              maxLines: 4,
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'onboarding.basicInfo.descriptionHint'.tr(),
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: widget.theme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: widget.theme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Text(
                      'onboarding.basicInfo.helperDescription'.tr(),
                      style: AppThemes.bodySmall(widget.theme).copyWith(
                        color: widget.theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
