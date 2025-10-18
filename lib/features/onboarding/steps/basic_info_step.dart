import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/common/category_dropdown.dart';

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
  Map<String, dynamic>? _selectedCategory;

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
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Text(
              'Tell us about your business to help customers find you.',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Business Name
            Text(
              'Business Name',
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
                hintText: 'Enter your business name',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Business Category
            Text(
              'Business Category',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            widget.loadingCategories
                ? Container(
                    height: 56,
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
                            'Loading categories...',
                            style: AppThemes.bodyMedium(widget.theme),
                          ),
                        ],
                      ),
                    ),
                  )
                : CategoryDropdown(
                    categories: widget.categories,
                    selectedCategory: _selectedCategory,
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      // Update BLoC with category ID
                      if (category != null) {
                        context.read<OnboardingBloc>().add(UpdateBusinessCategory(category['id']));
                      }
                    },
                    theme: widget.theme,
                  ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Business Description
            Text(
              'Business Description',
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
                hintText: 'Describe your business, products, and services...',
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
                      'A good description helps customers understand what you offer and builds trust.',
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
