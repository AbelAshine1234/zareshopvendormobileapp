import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' show InputElement, FileReader, document;
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OnboardingScreen extends StatelessWidget {
  final bool useMockData;

  const OnboardingScreen({
    super.key,
    this.useMockData = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()
        ..add(InitializeOnboarding(useMockData: useMockData)),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Drop from top
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.elasticOut, // Bouncy rain-like effect
      ),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _contentController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = true;
      });
    } else if (_scrollController.offset <= 10 && _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              if (state is OnboardingInProgress) {
                return Column(
                  children: [
                    // Compact Logo Header
                    _buildCompactHeader(context),
                    
                    // Main Content with Rain Drop Animation
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SlideTransition(
                          position: _contentSlideAnimation,
                          child: FadeTransition(
                            opacity: _contentFadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                _buildWelcomeSection(),
                                const SizedBox(height: 32),
                                _buildProgressSection(state),
                                const SizedBox(height: 32),
                                _buildCurrentStepCard(context, state),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Modern Bottom Navigation
                    _buildModernBottomNav(context, state),
                  ],
                );
              }
              
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: _isHeaderCollapsed ? 8 : 32,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _isHeaderCollapsed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // ZARESHOP Logo Text with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              );
            },
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: _isHeaderCollapsed ? 16 : 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
                letterSpacing: 2,
              ),
              child: const Text('ZARESHOP'),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: _isHeaderCollapsed
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(_isHeaderCollapsed ? 0.0 : 1.0),
                        child: Text(
                          'VENDOR PORTAL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildWelcomeSection() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isHeaderCollapsed ? 0.0 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isHeaderCollapsed ? 0 : null,
        child: _isHeaderCollapsed
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to ZareShop Vendor!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let\'s set up your shop in a few simple steps.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'ll personalize your business profile, add your first products, and link payment options.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressSection(OnboardingInProgress state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${state.currentStep + 1} of ${state.totalSteps}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            // Step dots
            Row(
              children: List.generate(state.totalSteps, (index) {
                final isActive = index == state.currentStep;
                final isCompleted = index < state.currentStep;
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                tween: Tween(begin: 0.0, end: state.progress),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildCurrentStepCard(BuildContext context, OnboardingInProgress state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(state.currentStep),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: _getStepWidget(state.currentStep),
      ),
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 0:
        return _buildPhoneNumberStep();
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildBasicInfoStep();
      case 3:
        return _buildDocumentsStep();
      case 4:
        return _buildPayoutStep();
      case 5:
        return _buildAdminApprovalStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 0: Phone Number
  Widget _buildPhoneNumberStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your phone number to get started',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
              ),
              child: Row(
                children: [
                  // Country code with flag
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://flagcdn.com/w40/et.png',
                              width: 28,
                              height: 20,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'ET',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+251',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFFE5E7EB),
                  ),
                  // Phone number input
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        context.read<OnboardingBloc>().add(UpdatePhoneNumber('+251$value'));
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '912345678',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We\'ll send a 6-digit OTP for verification.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Vendor Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVendorTypeCard(
                    'Individual Vendor',
                    'individual',
                    Icons.person,
                    state.data.vendorType == 'individual',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVendorTypeCard(
                    'Business Vendor',
                    'business',
                    Icons.business,
                    state.data.vendorType == 'business',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildVendorTypeCard(String label, String value, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<OnboardingBloc>().add(UpdateVendorType(value));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: OTP
  Widget _buildOTPStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${state.data.phoneNumber}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) {
                context.read<OnboardingBloc>().add(UpdateOTP(value));
              },
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 16,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<OnboardingBloc>().add(const ResendOTP());
                },
                child: const Text('Resend OTP'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Step 2: Basic Info
  Widget _buildBasicInfoStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        final isIndividual = state.data.isIndividual;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIndividual ? 'Your Information' : 'Business Information',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            if (isIndividual) ...[
              _buildTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateFullName(value)),
              ),
            ] else ...[
              _buildTextField(
                label: 'Business Name',
                hint: 'Enter business name',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBusinessName(value)),
              ),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email (Optional)',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateEmail(value)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Street',
              hint: 'Enter street address',
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(street: value)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'City',
              hint: 'Enter city',
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(city: value)),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Description',
              hint: 'Describe what you sell',
              maxLines: 3,
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBusinessDescription(value)),
            ),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
          ],
        );
      },
    );
  }

  // Step 3: Documents
  Widget _buildDocumentsStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        final isIndividual = state.data.isIndividual;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the following documents for verification',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (isIndividual) ...[
              _buildImageUploadField(
                label: 'Fayda ID Photo',
                hint: 'Tap to upload your Fayda ID',
                onTap: () {
                  // TODO: Implement image picker
                  _pickImage((path) {
                    context.read<OnboardingBloc>().add(UpdateFaydaIdNumber(path));
                  });
                },
              ),
            ] else ...[
              _buildImageUploadField(
                label: 'Business License Photo',
                hint: 'Tap to upload business license',
                onTap: () {
                  _pickImage((path) {
                    context.read<OnboardingBloc>().add(UpdateBusinessLicenseNumber(path));
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildImageUploadField(
                label: 'Tax ID Document (Optional)',
                hint: 'Tap to upload tax ID',
                onTap: () {
                  _pickImage((path) {
                    context.read<OnboardingBloc>().add(UpdateTaxId(path));
                  });
                },
              ),
            ],
          ],
        );
      },
    );
  }

  // Step 4: Payout with Confirmation
  Widget _buildPayoutStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        final isBank = state.data.preferredPayoutMethod == 'bank';
        final hasPaymentData = isBank 
            ? state.data.bankAccountNumber.isNotEmpty 
            : state.data.mobileWalletNumber.isNotEmpty;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payout Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you like to receive payments?',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPayoutMethodCard(
                    'Mobile Wallet',
                    'wallet',
                    Icons.phone_android,
                    !isBank,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPayoutMethodCard(
                    'Bank Account',
                    'bank',
                    Icons.account_balance,
                    isBank,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isBank) ...[
              _buildTextField(
                label: 'Bank Name',
                hint: 'Enter bank name',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBankAccount(bankName: value)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Account Number',
                hint: 'Enter account number',
                keyboardType: TextInputType.number,
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBankAccount(bankAccountNumber: value)),
              ),
            ] else ...[
              const Text(
                'Mobile Wallet Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateMobileWallet(value)),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+251912345678',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
            
            // Show confirmation section if payment data is entered
            if (hasPaymentData) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              
              // Linked Payment Methods
              const Text(
                'Linked Payment Methods',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodsList(state),
              
              const SizedBox(height: 20),
              _buildDefaultPaymentToggle(),
              
              const SizedBox(height: 20),
              _buildConfirmationChecks(),
            ],
          ],
        );
      },
    );
  }

  // Step 5: Admin Approval
  Widget _buildAdminApprovalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 50,
              color: Color(0xFF10B981),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Application Submitted!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your vendor application is under review',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ll notify you once your account is approved. This usually takes 1-2 business days.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: const Color(0xFF10B981),
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                'What\'s Next?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your email for updates\nPrepare your first products\nExplore vendor dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList(OnboardingInProgress state) {
    final isBank = state.data.preferredPayoutMethod == 'bank';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          if (isBank)
            _buildPaymentMethodItem(
              icon: Icons.account_balance,
              title: 'Bank Account',
              subtitle: '****** ${state.data.bankAccountNumber.substring(state.data.bankAccountNumber.length - 4)}',
              isVerified: true,
            )
          else
            _buildPaymentMethodItem(
              icon: Icons.phone_android,
              title: 'Mobile Wallet Telebirr',
              subtitle: state.data.mobileWalletNumber,
              isVerified: true,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF22C55E),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22C55E),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultPaymentToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Set as default payment method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {},
            activeTrackColor: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationChecks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          _buildCheckboxItem(
            'I confirm that the above payment details are correct',
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            'I agree to the Zareshop Payout Terms',
            linkText: 'View terms',
            onLinkTap: () {
              // Show terms dialog
            },
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            'I authorize payouts to the selected default payment method',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(String text, {String? linkText, VoidCallback? onLinkTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: false,
          onChanged: (value) {},
          activeColor: const Color(0xFF22C55E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                  height: 1.5,
                ),
              ),
              if (linkText != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onLinkTap,
                  child: Text(
                    linkText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutMethodCard(String label, String value, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<OnboardingBloc>().add(UpdatePayoutMethod(value));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBBF7D0) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF374151),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    if (kIsWeb) {
      // Web-specific image picker
      try {
        // Create file input element
        final input = document.createElement('input') as InputElement;
        input.type = 'file';
        input.accept = 'image/*';
        
        // Listen for file selection
        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            final file = files[0];
            final reader = FileReader();
            
            reader.onLoadEnd.listen((event) {
              if (mounted) {
                final dataUrl = reader.result as String;
                onImagePicked(dataUrl);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file.name} selected (${(file.size / 1024).toStringAsFixed(1)} KB)'),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
            
            reader.readAsDataUrl(file);
          }
        });
        
        // Trigger file selection
        input.click();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Mobile fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add image_picker package for mobile support'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      onImagePicked('/simulated/path/image.jpg');
    }
  }

  Widget _buildImageUploadField({
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF22C55E),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 2000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -4 * (0.5 - (value - 0.5).abs())),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Image',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Up to 4 photos',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'color': const Color(0xFF6366F1)},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': const Color(0xFFEC4899)},
      {'name': 'Food & Beverage', 'icon': Icons.restaurant, 'color': const Color(0xFFF59E0B)},
      {'name': 'Beauty & Health', 'icon': Icons.spa, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Home & Garden', 'icon': Icons.home, 'color': const Color(0xFF10B981)},
      {'name': 'Sports & Outdoor', 'icon': Icons.sports_soccer, 'color': const Color(0xFF3B82F6)},
      {'name': 'Books & Media', 'icon': Icons.menu_book, 'color': const Color(0xFFF97316)},
      {'name': 'Toys & Kids', 'icon': Icons.toys, 'color': const Color(0xFFEF4444)},
    ];

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        final selectedCategory = state.data.category;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category['name'];
                
                return GestureDetector(
                  onTap: () {
                    context.read<OnboardingBloc>().add(UpdateCategory(category['name'] as String));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (category['color'] as Color).withValues(alpha: 0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? (category['color'] as Color)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (category['color'] as Color).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 20,
                          color: isSelected 
                              ? (category['color'] as Color)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? (category['color'] as Color)
                                  : Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernBottomNav(BuildContext context, OnboardingInProgress state) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: state.canProceed
              ? () {
                  context.read<OnboardingBloc>().add(const NextStep());
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E), // Zareshop green
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: const Color(0xFF22C55E).withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100), // Pill shape - fully rounded
            ),
          ).copyWith(
            elevation: MaterialStateProperty.resolveWith<double>((states) {
              if (states.contains(MaterialState.pressed)) {
                return 0;
              }
              if (states.contains(MaterialState.hovered)) {
                return 8;
              }
              return 4;
            }),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return const Color(0xFFE5E7EB);
              }
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF15803D);
              }
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF16A34A);
              }
              return const Color(0xFF22C55E);
            }),
          ),
          child: Text(
            state.isLastStep ? 'Finish Setup' : 'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // SemiBold
              color: state.canProceed ? Colors.white : const Color(0xFF9CA3AF),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
