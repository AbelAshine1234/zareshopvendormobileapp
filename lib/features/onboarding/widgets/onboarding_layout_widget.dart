import 'package:flutter/material.dart';
import '../bloc/onboarding_state.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/theme/app_themes.dart';
import 'onboarding_compact_header.dart';
import 'onboarding_welcome_section.dart';
import 'onboarding_progress_section.dart';
import 'onboarding_step_card.dart';
import 'onboarding_bottom_navigation.dart';

/// Main layout widget for the onboarding flow
/// Handles the overall structure with header, scrollable content, and bottom navigation
class OnboardingLayoutWidget extends StatefulWidget {
  /// The current onboarding state
  final OnboardingState state;
  
  /// List of available subscriptions
  final List<dynamic> subscriptions;
  
  /// Whether subscriptions are currently loading
  final bool loadingSubscriptions;
  
  /// List of available categories
  final List<Map<String, dynamic>> categories;
  
  /// Whether categories are currently loading
  final bool loadingCategories;
  
  /// Callback to fetch subscriptions
  final VoidCallback onFetchSubscriptions;
  
  /// Inline error message to display
  final String? inlineErrorMessage;
  
  /// Callback when error retry is pressed
  final VoidCallback? onErrorRetry;
  
  /// Whether the header should be collapsed
  final bool isHeaderCollapsed;
  
  /// Scroll controller for the main content
  final ScrollController scrollController;
  
  /// Animation for content slide transitions
  final Animation<Offset> contentSlideAnimation;
  
  /// Animation for content fade transitions
  final Animation<double> contentFadeAnimation;

  const OnboardingLayoutWidget({
    super.key,
    required this.state,
    required this.subscriptions,
    required this.loadingSubscriptions,
    required this.categories,
    required this.loadingCategories,
    required this.onFetchSubscriptions,
    this.inlineErrorMessage,
    this.onErrorRetry,
    required this.isHeaderCollapsed,
    required this.scrollController,
    required this.contentSlideAnimation,
    required this.contentFadeAnimation,
  });

  @override
  State<OnboardingLayoutWidget> createState() => _OnboardingLayoutWidgetState();
}

class _OnboardingLayoutWidgetState extends State<OnboardingLayoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        OnboardingCompactHeader(
          isHeaderCollapsed: widget.isHeaderCollapsed,
        ),
        
        // Main Content Section
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceL),
            children: [
              const SizedBox(height: AppThemes.spaceL),
              
              // Welcome Section
              OnboardingWelcomeSection(
                isHeaderCollapsed: widget.isHeaderCollapsed,
              ),
              
              const SizedBox(height: AppThemes.spaceXL),
              
              // Progress Section
              if (widget.state is OnboardingInProgress)
                OnboardingProgressSection(state: widget.state as OnboardingInProgress),
              
              const SizedBox(height: AppThemes.spaceM),
              
              // Error Widget
              if (widget.inlineErrorMessage != null)
                GlobalErrorWidget(
                  errorMessage: widget.inlineErrorMessage!,
                  onRetry: widget.onErrorRetry,
                ),
              
              const SizedBox(height: AppThemes.spaceXL),
              
              // Step Card (Main Content)
              if (widget.state is OnboardingInProgress)
                OnboardingStepCard(
                  state: widget.state as OnboardingInProgress,
                  subscriptions: widget.subscriptions.cast<Map<String, dynamic>>(),
                  loadingSubscriptions: widget.loadingSubscriptions,
                  categories: widget.categories.cast<Map<String, dynamic>>(),
                  loadingCategories: widget.loadingCategories,
                  onFetchSubscriptions: widget.onFetchSubscriptions,
                ),
              
              // Bottom spacing for navigation
              const SizedBox(height: 100),
            ],
          ),
        ),
        
        // Bottom Navigation Section
        if (widget.state is OnboardingInProgress)
          OnboardingBottomNavigation(state: widget.state as OnboardingInProgress),
      ],
    );
  }
}

/// Simplified version of the onboarding layout for basic use cases
class SimpleOnboardingLayoutWidget extends StatelessWidget {
  /// The current onboarding state
  final OnboardingState state;
  
  /// List of available subscriptions
  final List<dynamic> subscriptions;
  
  /// Whether subscriptions are currently loading
  final bool loadingSubscriptions;
  
  /// List of available categories
  final List<Map<String, dynamic>> categories;
  
  /// Whether categories are currently loading
  final bool loadingCategories;
  
  /// Callback to fetch subscriptions
  final VoidCallback onFetchSubscriptions;
  
  /// Inline error message to display
  final String? inlineErrorMessage;
  
  /// Callback when error retry is pressed
  final VoidCallback? onErrorRetry;

  const SimpleOnboardingLayoutWidget({
    super.key,
    required this.state,
    required this.subscriptions,
    required this.loadingSubscriptions,
    required this.categories,
    required this.loadingCategories,
    required this.onFetchSubscriptions,
    this.inlineErrorMessage,
    this.onErrorRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        OnboardingCompactHeader(isHeaderCollapsed: false),
        
        // Content
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceL),
            children: [
              const SizedBox(height: AppThemes.spaceL),
              
              // Welcome Section
              OnboardingWelcomeSection(isHeaderCollapsed: false),
              
              const SizedBox(height: AppThemes.spaceXL),
              
              // Progress Section
              if (state is OnboardingInProgress)
                OnboardingProgressSection(state: state as OnboardingInProgress),
              
              const SizedBox(height: AppThemes.spaceM),
              
              // Error Widget
              if (inlineErrorMessage != null)
                GlobalErrorWidget(
                  errorMessage: inlineErrorMessage!,
                  onRetry: onErrorRetry,
                ),
              
              const SizedBox(height: AppThemes.spaceXL),
              
              // Step Card
              if (state is OnboardingInProgress)
                OnboardingStepCard(
                  state: state as OnboardingInProgress,
                  subscriptions: subscriptions.cast<Map<String, dynamic>>(),
                  loadingSubscriptions: loadingSubscriptions,
                  categories: categories.cast<Map<String, dynamic>>(),
                  loadingCategories: loadingCategories,
                  onFetchSubscriptions: onFetchSubscriptions,
                ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
        
        // Bottom Navigation
        if (state is OnboardingInProgress)
          OnboardingBottomNavigation(state: state as OnboardingInProgress),
      ],
    );
  }
}
