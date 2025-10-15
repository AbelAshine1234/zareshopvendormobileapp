import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
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
  
  // Checkbox states
  bool _confirmDetailsCheck = false;
  bool _agreeTermsCheck = false;
  bool _authorizePayoutCheck = false;
  
  // Phone validation
  String? _phoneError;
  String? _walletPhoneError;
  
  // OTP timer
  int _otpCountdown = 60;
  Timer? _otpTimer;

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
    _otpTimer?.cancel();
    super.dispose();
  }
  
  void _startOTPTimer() {
    _otpTimer?.cancel();
    setState(() => _otpCountdown = 60);
    
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        setState(() => _otpCountdown--);
      } else {
        timer.cancel();
      }
    });
  }
  
  void _resendOTP() {
    context.read<OnboardingBloc>().add(const ResendOTP());
    _startOTPTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/');
        }
        // Start OTP timer when reaching OTP step
        if (state is OnboardingInProgress && state.currentStep == 1) {
          if (_otpCountdown == 60 && _otpTimer == null) {
            _startOTPTimer();
          }
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
                        physics: const BouncingScrollPhysics(),
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
            // Step dots with spring animation
            Row(
              children: List.generate(state.totalSteps, (index) {
                final isActive = index == state.currentStep;
                final isCompleted = index < state.currentStep;
                return TweenAnimationBuilder<double>(
                  key: ValueKey('dot_$index'),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutBack,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: _DotIndicator(
                        index: index,
                        isActive: isActive,
                        isCompleted: isCompleted,
                        onTap: isCompleted
                            ? () {
                                context.read<OnboardingBloc>().add(GoToStep(index));
                              }
                            : null,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar with overshoot effect
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
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                tween: Tween(begin: 0.0, end: state.progress),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Smooth combined animation: fade + slide + scale
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
        );
        
        final slideAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        );
        
        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
        );
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(slideAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(scaleAnimation),
              child: child,
            ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                        _validateEthiopianPhone(value);
                        context.read<OnboardingBloc>().add(UpdatePhoneNumber('+251$value'));
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: const InputDecoration(
                        hintText: '912345678',
                        border: InputBorder.none,
                        counterText: '',
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
            if (_phoneError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _phoneError!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'We\'ll send a 6-digit OTP for verification.',
              style: TextStyle(
                fontSize: 14,
                color: _phoneError != null ? Colors.red.shade300 : const Color(0xFF6B7280),
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
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildVendorTypeCard(
                            'Individual Vendor',
                            'individual',
                            Icons.person,
                            state.data.vendorType == 'individual',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildVendorTypeCard(
                            'Business Vendor',
                            'business',
                            Icons.business,
                            state.data.vendorType == 'business',
                          ),
                        ),
                      );
                    },
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
              child: _otpCountdown > 0
                  ? TweenAnimationBuilder<double>(
                      key: ValueKey(_otpCountdown),
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.8, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Text(
                            'Resend OTP in $_otpCountdown seconds',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    )
                  : TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: TextButton.icon(
                            onPressed: _resendOTP,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Resend OTP'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF22C55E),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
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
                imagePath: state.data.faydaIdNumber,
                onTap: () {
                  _pickImage((path) {
                    context.read<OnboardingBloc>().add(UpdateFaydaIdNumber(path));
                  });
                },
              ),
            ] else ...[
              _buildImageUploadField(
                label: 'Business License Photo',
                hint: 'Tap to upload business license',
                imagePath: state.data.businessLicenseNumber,
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
                imagePath: state.data.taxId,
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
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(-20 * (1 - value), 0),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildPayoutMethodCard(
                            'Mobile Wallet',
                            'wallet',
                            Icons.phone_android,
                            !isBank,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildPayoutMethodCard(
                            'Bank Account',
                            'bank',
                            Icons.account_balance,
                            isBank,
                          ),
                        ),
                      );
                    },
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
                          _validateEthiopianWalletPhone(value);
                          context.read<OnboardingBloc>().add(UpdateMobileWallet('+251$value'));
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 9,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        decoration: const InputDecoration(
                          hintText: '912345678',
                          border: InputBorder.none,
                          counterText: '',
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
              // Wallet phone error message
              if (_walletPhoneError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _walletPhoneError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
    
    // Safely get last 4 digits of bank account
    String getBankAccountDisplay(String accountNumber) {
      if (accountNumber.length <= 4) {
        return accountNumber;
      }
      return '****** ${accountNumber.substring(accountNumber.length - 4)}';
    }
    
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
              subtitle: getBankAccountDisplay(state.data.bankAccountNumber),
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
          const Expanded(
            child: Text(
              'Set as default payment method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
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
            value: _confirmDetailsCheck,
            onChanged: (value) {
              setState(() {
                _confirmDetailsCheck = value ?? false;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            'I agree to the Zareshop Payout Terms',
            value: _agreeTermsCheck,
            onChanged: (value) {
              setState(() {
                _agreeTermsCheck = value ?? false;
              });
            },
            linkText: 'View terms',
            onLinkTap: () {
              _showTermsDialog();
            },
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            'I authorize payouts to the selected default payment method',
            value: _authorizePayoutCheck,
            onChanged: (value) {
              setState(() {
                _authorizePayoutCheck = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    String text, {
    required bool value,
    required Function(bool?) onChanged,
    String? linkText,
    VoidCallback? onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Zareshop Payout Terms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Processing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zareshop will process your payouts according to the selected payment method. Payouts are typically processed within 2-5 business days.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fees and Charges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A standard processing fee of 2.5% applies to all transactions. Additional fees may apply based on your payment method.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment details must be verified before payouts can be processed. Please ensure all information is accurate.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
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

  void _validateEthiopianPhone(String phone) {
    setState(() {
      // Remove any spaces or special characters
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Ethiopian mobile numbers:
      // - Start with 09 or 07 (when local format)
      // - Total 9 digits (without +251)
      // - Valid prefixes: 9 or 7
      
      if (cleanPhone.isEmpty) {
        _phoneError = null;
      } else if (cleanPhone.length < 9) {
        _phoneError = 'Phone number too short';
      } else if (cleanPhone.length > 9) {
        _phoneError = 'Phone number too long';
      } else if (!cleanPhone.startsWith('9') && !cleanPhone.startsWith('7')) {
        _phoneError = 'Must start with 9 or 7 (e.g., 912345678)';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateEthiopianWalletPhone(String phone) {
    setState(() {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleanPhone.isEmpty) {
        _walletPhoneError = null;
      } else if (cleanPhone.length < 9) {
        _walletPhoneError = 'Phone number too short';
      } else if (cleanPhone.length > 9) {
        _walletPhoneError = 'Phone number too long';
      } else if (!cleanPhone.startsWith('9') && !cleanPhone.startsWith('7')) {
        _walletPhoneError = 'Must start with 9 or 7 (e.g., 912345678)';
      } else {
        _walletPhoneError = null;
      }
    });
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    try {
      final picker = ImagePicker();
      final XFile? xfile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (xfile == null) return;

      // If a file path is available (mobile/desktop), use it. On web, path may be empty.
      if (xfile.path.isNotEmpty) {
        onImagePicked(xfile.path);
      } else {
        // Web: convert to data URL
        final bytes = await xfile.readAsBytes();
        final ext = xfile.name.contains('.') ? xfile.name.split('.').last.toLowerCase() : 'png';
        final mime = (ext == 'jpg') ? 'image/jpeg' : 'image/$ext';
        final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        onImagePicked(dataUrl);
      }

      if (mounted) {
        final sizeBytes = await xfile.length();
        final kb = (sizeBytes / 1024).toStringAsFixed(1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${xfile.name} selected ($kb KB)'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
  }

  Widget _buildImageUploadField({
    required String label,
    required String hint,
    required VoidCallback onTap,
    String? imagePath,
  }) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final isDataUrl = hasImage && imagePath.startsWith('data:');
    
    // Debug logging
    if (hasImage) {
      print('=== Image Upload Debug ===');
      print('Has image: $hasImage');
      print('Is data URL: $isDataUrl');
      print('Image path length: ${imagePath?.length}');
      print('Image path preview: ${imagePath?.substring(0, imagePath.length > 100 ? 100 : imagePath.length)}');
      print('Platform: web=${kIsWeb}');
    }

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
            height: hasImage ? 200 : null,
            padding: hasImage ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF22C55E),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: hasImage
                ? TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Container(
                            color: Colors.grey.shade100,
                            child: Stack(
                              children: [
                                // Image preview
                                ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: isDataUrl
                                      ? Image.memory(
                                          base64Decode(imagePath.split(',')[1]),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Image.memory error: $error');
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                                                  const SizedBox(height: 8),
                                                  const Text('Failed to load image', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : (kIsWeb
                                          ? Image.network(
                                              imagePath,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    color: const Color(0xFF22C55E),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Image.network error: $error');
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                                                      const SizedBox(height: 8),
                                                      const Text('Failed to load image', style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : Image.file(
                                              File(imagePath),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Image.file error: $error');
                                                print('Image path: $imagePath');
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                                                      const SizedBox(height: 8),
                                                      const Text('Failed to load image', style: TextStyle(color: Colors.red)),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Path: ${imagePath.split('/').last}',
                                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )),
                                ),
                              ),
                              // Edit overlay
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Change',
                                        style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Column(
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
                
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 80)),
                  curve: Curves.easeOutBack,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: GestureDetector(
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
                        ),
                      ),
                    );
                  },
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
              fontWeight: FontWeight.w400, // Regular weight - lighter
              color: state.canProceed ? Colors.white : const Color(0xFF9CA3AF),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// Separate widget for dot indicator with spring animation
class _DotIndicator extends StatefulWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _DotIndicator({
    required this.index,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
  });

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _controller.forward(from: 0).then((_) {
        widget.onTap!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.isCompleted || widget.isActive
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
