import 'package:flutter/material.dart';
import 'onboarding_constants.dart';

class OnboardingDialogs {
  /// Show terms and conditions dialog
  static void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: OnboardingConstants.primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: OnboardingConstants.mediumSpace),
                        const Expanded(
                          child: Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: OnboardingConstants.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: OnboardingConstants.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'By using our service, you agree to the following terms:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: OnboardingConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: OnboardingConstants.mediumSpace),
                        
                        // Terms list
                        ...OnboardingConstants.termsList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index > 0)
                                const SizedBox(height: OnboardingConstants.mediumSpace),
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: OnboardingConstants.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: OnboardingConstants.smallSpace),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: OnboardingConstants.textGray,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OnboardingConstants.largeSpace,
                      0,
                      OnboardingConstants.largeSpace,
                      OnboardingConstants.largeSpace,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingConstants.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(OnboardingConstants.mediumRadius),
                          ),
                        ),
                        child: const Text(
                          'I Understand',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

  /// Show privacy policy dialog
  static void showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: OnboardingConstants.primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.privacy_tip_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: OnboardingConstants.mediumSpace),
                        const Expanded(
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: OnboardingConstants.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: OnboardingConstants.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'We respect your privacy and protect your data:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: OnboardingConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: OnboardingConstants.mediumSpace),
                        
                        // Privacy list
                        ...OnboardingConstants.privacyList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index > 0)
                                const SizedBox(height: OnboardingConstants.mediumSpace),
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: OnboardingConstants.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: OnboardingConstants.smallSpace),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: OnboardingConstants.textGray,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OnboardingConstants.largeSpace,
                      0,
                      OnboardingConstants.largeSpace,
                      OnboardingConstants.largeSpace,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OnboardingConstants.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(OnboardingConstants.mediumRadius),
                          ),
                        ),
                        child: const Text(
                          'I Understand',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

  /// Show success dialog
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      builder: (context) {
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
                  // Success icon
                  Container(
                    padding: const EdgeInsets.all(OnboardingConstants.largeSpace),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: OnboardingConstants.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: OnboardingConstants.primaryGreen,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: OnboardingConstants.primaryGreen,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OnboardingConstants.largeSpace,
                      0,
                      OnboardingConstants.largeSpace,
                      OnboardingConstants.largeSpace,
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: OnboardingConstants.textPrimary,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
