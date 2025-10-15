import 'package:flutter/material.dart';
import 'onboarding_constants.dart';

class OnboardingDialogs {
  /// Show terms and conditions dialog with animation
  static void showTermsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Terms',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(OnboardingConstants.largeRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                    decoration: BoxDecoration(
                      color: OnboardingConstants.backgroundGray,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(OnboardingConstants.largeRadius),
                        topRight: Radius.circular(OnboardingConstants.largeRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: OnboardingConstants.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(OnboardingConstants.smallRadius),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: OnboardingConstants.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: OnboardingConstants.mediumSpace),
                        const Expanded(
                          child: Text(
                            OnboardingConstants.termsTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: OnboardingConstants.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: OnboardingConstants.termsContent
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                                milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOutCubic,
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (index > 0)
                                        const SizedBox(
                                            height: OnboardingConstants
                                                .mediumSpace),
                                      Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              color: OnboardingConstants
                                                  .primaryGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item['title']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: OnboardingConstants
                                                  .textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              OnboardingConstants.smallSpace),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(
                                          item['content']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: OnboardingConstants.textGray,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                    decoration: BoxDecoration(
                      color: OnboardingConstants.backgroundGray,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(OnboardingConstants.largeRadius),
                        bottomRight: Radius.circular(OnboardingConstants.largeRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    OnboardingConstants.mediumRadius),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: OnboardingConstants.primaryGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show success dialog with animation
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onContinue,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(OnboardingConstants.largeRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: OnboardingConstants.primaryGreen
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: OnboardingConstants.primaryGreen,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: OnboardingConstants.largeSpace),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: OnboardingConstants.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OnboardingConstants.mediumSpace),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: OnboardingConstants.textGray,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OnboardingConstants.largeSpace),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onContinue?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OnboardingConstants.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              OnboardingConstants.mediumRadius),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
