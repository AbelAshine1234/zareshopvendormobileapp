import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class BusinessNameConflictScreen extends StatefulWidget {
  final OnboardingBusinessNameConflict state;

  const BusinessNameConflictScreen({
    super.key,
    required this.state,
  });

  @override
  State<BusinessNameConflictScreen> createState() => _BusinessNameConflictScreenState();
}

class _BusinessNameConflictScreenState extends State<BusinessNameConflictScreen> {
  late TextEditingController _businessNameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.state.suggestedName);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'onboarding.businessNameConflict.title'.tr(),
          style: AppThemes.titleLarge(theme),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(theme),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Conflict Message
              _buildConflictMessage(theme),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Business Name Input
              _buildBusinessNameInput(theme),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Action Buttons
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemes.spaceXL),
      decoration: AppThemes.cardDecoration(theme),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            decoration: BoxDecoration(
              color: theme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            ),
            child: Icon(
              Icons.business_center_outlined,
              color: theme.warning,
              size: 32,
            ),
          ),
          const SizedBox(width: AppThemes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'onboarding.businessNameConflict.headerTitle'.tr(),
                  style: AppThemes.headlineMedium(theme),
                ),
                const SizedBox(height: AppThemes.spaceS),
                Text(
                  'onboarding.businessNameConflict.headerDesc'.tr(),
                  style: AppThemes.bodyLarge(theme).copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictMessage(AppThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemes.spaceL),
      decoration: BoxDecoration(
        color: theme.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppThemes.borderRadius),
        border: Border.all(
          color: theme.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.warning,
                size: 24,
              ),
              const SizedBox(width: AppThemes.spaceM),
              Expanded(
                child: Text(
                  'onboarding.businessNameConflict.conflictTitle'.tr(),
                  style: AppThemes.titleMedium(theme).copyWith(
                    color: theme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceM),
          Text(
            'onboarding.businessNameConflict.conflictDesc'.tr().replaceAll('{originalName}', widget.state.originalName),
            style: AppThemes.bodyMedium(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNameInput(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'onboarding.businessNameConflict.newNameLabel'.tr(),
          style: AppThemes.titleMedium(theme).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppThemes.spaceM),
        AppTextField(
          controller: _businessNameController,
          label: 'onboarding.businessNameConflict.newNameLabel'.tr(),
          hint: 'onboarding.businessNameConflict.newNameHint'.tr(),
          onChanged: (value) {},
          maxLines: 1,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'onboarding.businessNameConflict.nameRequired'.tr();
            }
            if (value.trim().length < 3) {
              return 'onboarding.businessNameConflict.nameTooShort'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: AppThemes.spaceS),
        Text(
          'onboarding.businessNameConflict.nameHelp'.tr(),
          style: AppThemes.bodySmall(theme).copyWith(
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppPrimaryButton(
            text: 'onboarding.businessNameConflict.retryButton'.tr(),
            onPressed: _isSubmitting ? null : _handleRetry,
            isLoading: _isSubmitting,
          ),
        ),
        const SizedBox(height: AppThemes.spaceM),
        SizedBox(
          width: double.infinity,
          child: AppSecondaryButton(
            text: 'onboarding.businessNameConflict.backButton'.tr(),
            onPressed: _isSubmitting ? null : _handleGoBack,
          ),
        ),
      ],
    );
  }

  void _handleRetry() {
    final newName = _businessNameController.text.trim();
    if (newName.isEmpty || newName.length < 3) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Submit with new name and automatically retry vendor creation
    context.read<OnboardingBloc>().add(RetryWithNewBusinessName(newName));
  }

  void _handleGoBack() {
    // Go back to basic info step
    context.read<OnboardingBloc>().add(GoToStep(2));
  }
}
