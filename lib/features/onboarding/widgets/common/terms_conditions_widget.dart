import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/onboarding_constants.dart';
import '../../core/onboarding_theme.dart';

class TermsConditionsWidget extends StatefulWidget {
  final bool isChecked;
  final Function(bool) onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const TermsConditionsWidget({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  @override
  State<TermsConditionsWidget> createState() => _TermsConditionsWidgetState();
}

class _TermsConditionsWidgetState extends State<TermsConditionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: OnboardingConstants.fastAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: OnboardingConstants.borderColor,
      end: OnboardingConstants.primaryGreen,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onChanged(!widget.isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(OnboardingConstants.spaceM),
          decoration: BoxDecoration(
            color: widget.isChecked 
                ? OnboardingConstants.primaryGreen.withOpacity(0.05)
                : OnboardingConstants.backgroundLight,
            borderRadius: BorderRadius.circular(OnboardingConstants.borderRadius),
            border: Border.all(
              color: _colorAnimation.value ?? OnboardingConstants.borderColor,
              width: widget.isChecked ? 2 : 1,
            ),
            boxShadow: widget.isChecked
                ? [
                    BoxShadow(
                      color: OnboardingConstants.primaryGreen.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Checkbox
              GestureDetector(
                onTap: _handleTap,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedContainer(
                    duration: OnboardingConstants.fastAnimation,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.isChecked 
                          ? OnboardingConstants.primaryGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.isChecked 
                            ? OnboardingConstants.primaryGreen
                            : OnboardingConstants.borderColor,
                        width: 2,
                      ),
                    ),
                    child: widget.isChecked
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(width: OnboardingConstants.spaceM),
              
              // Terms Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Agreement Text
                    RichText(
                      text: TextSpan(
                        style: OnboardingTheme.bodyMedium.copyWith(
                          color: OnboardingConstants.textPrimary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'I agree to the ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: OnboardingConstants.primaryGreen,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onTermsTap ?? _showTermsDialog,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: OnboardingConstants.primaryGreen,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onPrivacyTap ?? _showPrivacyDialog,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: OnboardingConstants.spaceS),
                    
                    // Additional Info
                    Text(
                      'By checking this box, you confirm that you have read and understood our terms and conditions.',
                      style: OnboardingTheme.bodyMedium.copyWith(
                        fontSize: OnboardingConstants.fontSizeSmall,
                        color: OnboardingConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => const TermsDialog(
        title: 'Terms of Service',
        content: _termsContent,
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => const TermsDialog(
        title: 'Privacy Policy',
        content: _privacyContent,
      ),
    );
  }
}

class TermsDialog extends StatelessWidget {
  final String title;
  final String content;

  const TermsDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OnboardingConstants.largeBorderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(OnboardingConstants.spaceL),
              decoration: BoxDecoration(
                color: OnboardingConstants.primaryGreen.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(OnboardingConstants.largeBorderRadius),
                  topRight: Radius.circular(OnboardingConstants.largeBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(OnboardingConstants.spaceS),
                    decoration: BoxDecoration(
                      color: OnboardingConstants.primaryGreen,
                      borderRadius: BorderRadius.circular(OnboardingConstants.spaceS),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: OnboardingConstants.spaceM),
                  Expanded(
                    child: Text(
                      title,
                      style: OnboardingTheme.titleMedium.copyWith(
                        color: OnboardingConstants.primaryGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: OnboardingConstants.textSecondary,
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OnboardingConstants.spaceL),
                child: Text(
                  content,
                  style: OnboardingTheme.bodyMedium.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(OnboardingConstants.spaceL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OnboardingTheme.primaryButtonStyle,
                  child: const Text('I Understand'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sample Terms Content
const String _termsContent = '''
ZARESHOP VENDOR TERMS OF SERVICE

Last updated: October 2025

1. ACCEPTANCE OF TERMS
By creating a vendor account on ZareShop, you agree to be bound by these Terms of Service and all applicable laws and regulations.

2. VENDOR RESPONSIBILITIES
- Provide accurate product information
- Maintain competitive pricing
- Ensure timely order fulfillment
- Provide excellent customer service
- Comply with all applicable laws

3. ACCOUNT REQUIREMENTS
- Must be 18 years or older
- Provide valid business information
- Maintain account security
- Update information as needed

4. COMMISSION AND FEES
- Platform commission: 5-15% per sale
- Payment processing fees apply
- Monthly subscription fees may apply
- No hidden charges

5. PRODUCT GUIDELINES
- Products must be legal and safe
- Accurate descriptions required
- High-quality images mandatory
- No counterfeit items allowed

6. ORDER MANAGEMENT
- Process orders within 24 hours
- Provide tracking information
- Handle returns professionally
- Maintain inventory accuracy

7. PAYMENT TERMS
- Payments processed weekly
- Minimum payout threshold: 500 ETB
- Multiple payment methods supported
- Tax compliance required

8. INTELLECTUAL PROPERTY
- Respect third-party rights
- Original content preferred
- Proper licensing required
- Report violations promptly

9. TERMINATION
- Either party may terminate
- 30-day notice period
- Outstanding obligations remain
- Data retention policies apply

10. LIMITATION OF LIABILITY
ZareShop's liability is limited to the maximum extent permitted by law.

11. GOVERNING LAW
These terms are governed by Ethiopian law.

12. CONTACT INFORMATION
For questions about these terms, contact us at legal@zareshop.com.

By using our platform, you acknowledge that you have read, understood, and agree to be bound by these terms.
''';

const String _privacyContent = '''
ZARESHOP VENDOR PRIVACY POLICY

Last updated: October 2025

1. INFORMATION WE COLLECT
- Account information (name, email, phone)
- Business details and documentation
- Financial information for payments
- Product and inventory data
- Usage analytics and preferences

2. HOW WE USE YOUR INFORMATION
- Account management and verification
- Order processing and fulfillment
- Payment processing
- Customer support
- Platform improvement
- Legal compliance

3. INFORMATION SHARING
We may share your information with:
- Customers (for order fulfillment)
- Payment processors
- Shipping partners
- Legal authorities (when required)
- Service providers (under strict agreements)

4. DATA SECURITY
- Encryption of sensitive data
- Secure server infrastructure
- Regular security audits
- Access controls and monitoring
- Incident response procedures

5. YOUR RIGHTS
- Access your personal data
- Correct inaccurate information
- Delete your account
- Data portability
- Opt-out of marketing

6. COOKIES AND TRACKING
- Essential cookies for functionality
- Analytics cookies for improvement
- Marketing cookies (with consent)
- Third-party integrations

7. DATA RETENTION
- Account data: Until account deletion
- Transaction data: 7 years (legal requirement)
- Analytics data: 2 years
- Marketing data: Until opt-out

8. INTERNATIONAL TRANSFERS
Data may be transferred internationally with appropriate safeguards.

9. CHILDREN'S PRIVACY
Our platform is not intended for users under 18.

10. POLICY UPDATES
We may update this policy with notice to users.

11. CONTACT US
For privacy questions, contact us at:
- Email: privacy@zareshop.com
- Phone: +251-11-XXX-XXXX
- Address: Addis Ababa, Ethiopia

12. DATA PROTECTION OFFICER
For data protection matters, contact our DPO at dpo@zareshop.com.

Your privacy is important to us. We are committed to protecting your personal information and being transparent about our practices.
''';

// Compact Terms Widget for smaller spaces
class CompactTermsWidget extends StatelessWidget {
  final bool isChecked;
  final Function(bool) onChanged;

  const CompactTermsWidget({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        children: [
          AnimatedContainer(
            duration: OnboardingConstants.fastAnimation,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked 
                  ? OnboardingConstants.primaryGreen
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isChecked 
                    ? OnboardingConstants.primaryGreen
                    : OnboardingConstants.borderColor,
                width: 2,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
          const SizedBox(width: OnboardingConstants.spaceS),
          Expanded(
            child: Text(
              'I agree to Terms & Privacy Policy',
              style: OnboardingTheme.bodyMedium.copyWith(
                fontSize: OnboardingConstants.fontSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
