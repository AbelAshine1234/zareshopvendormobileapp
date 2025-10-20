import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/language_selector/language_switcher_button.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../steps/steps.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../shared/widgets/inline_error_banner.dart';

class OnboardingMainScreen extends StatelessWidget {
  final bool useMockData;

  const OnboardingMainScreen({
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
  
  // Phone validation
  String? _phoneError;
  
  // OTP timer
  int _otpCountdown = 60;
  Timer? _otpTimer;
  
  // Transient inline error banner message (similar to login screen)
  String? _inlineErrorMessage;
  int _lastStep = -1;
  
  // Categories from backend
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = false;
  
  // Subscriptions from backend
  List<Map<String, dynamic>> _subscriptions = [];
  bool _loadingSubscriptions = false;

  @override
  void initState() {
    super.initState();
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _contentController.forward();
    _fetchCategories();

    // Ensure latest localization assets (including newly added keys) are loaded
    // when entering onboarding, so .tr() resolves without requiring full app restart.
    LocalizationService.instance.loadLanguage(
      LocalizationService.instance.currentLanguage,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    _otpTimer?.cancel();
    super.dispose();
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

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
    });
    
    final result = await ApiService.fetchCategories();
    
    if (result['success'] == true && mounted) {
      final categoriesData = result['categories'] as List<dynamic>;
      setState(() {
        _categories = categoriesData.map((cat) {
          return {
            'id': cat['id'],
            'name': cat['name'],
            'icon': _getCategoryIcon(cat['name']),
            'color': _getCategoryColor(cat['name']),
          };
        }).toList();
        _loadingCategories = false;
      });
    } else if (mounted) {
      setState(() {
        _loadingCategories = false;
        _categories = [
          {'id': 1, 'name': 'Electronics', 'icon': Icons.devices, 'color': const Color(0xFF6366F1)},
          {'id': 2, 'name': 'Fashion', 'icon': Icons.checkroom, 'color': const Color(0xFFEC4899)},
          {'id': 3, 'name': 'Food & Beverage', 'icon': Icons.restaurant, 'color': const Color(0xFFF59E0B)},
          {'id': 4, 'name': 'Beauty & Health', 'icon': Icons.spa, 'color': const Color(0xFF8B5CF6)},
        ];
      });
    }
  }

  Future<void> _fetchSubscriptions() async {
    setState(() {
      _loadingSubscriptions = true;
    });
    
    try {
      final result = await ApiService.fetchSubscriptions();
      
      if (result['success'] == true && mounted) {
        final subscriptionsData = result['subscriptions'] as List<dynamic>;
        final processedSubscriptions = subscriptionsData.map((sub) {
          return {
            'id': sub['id'],
            'name': sub['name'],
            'price': sub['price'],
            'duration': sub['duration'],
            'features': sub['features'] ?? [],
          };
        }).toList();
        
        setState(() {
          _subscriptions = processedSubscriptions;
          _loadingSubscriptions = false;
        });
      } else if (mounted) {
        setState(() {
          _loadingSubscriptions = false;
          _subscriptions = [
            {
              'id': 1,
              'name': 'Basic Plan (Fallback)',
              'price': 99.99,
              'duration': 'monthly',
              'features': ['Up to 100 products', 'Basic analytics', 'Email support'],
            },
          ];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSubscriptions = false;
          _subscriptions = [
            {
              'id': 1,
              'name': 'Basic Plan (Error Fallback)',
              'price': 99.99,
              'duration': 'monthly',
              'features': ['Up to 100 products', 'Basic analytics', 'Email support'],
            },
          ];
        });
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final iconMap = {
      'Electronics': Icons.devices,
      'Fashion': Icons.checkroom,
      'Food & Beverage': Icons.restaurant,
      'Beauty & Health': Icons.spa,
      'Home & Garden': Icons.home,
      'Sports & Outdoor': Icons.sports_soccer,
      'Books & Media': Icons.menu_book,
      'Toys & Kids': Icons.toys,
      'Automotive': Icons.directions_car,
      'Jewelry': Icons.diamond,
    };
    return iconMap[categoryName] ?? Icons.category;
  }
  
  Color _getCategoryColor(String categoryName) {
    final colorMap = {
      'Electronics': const Color(0xFF6366F1),
      'Fashion': const Color(0xFFEC4899),
      'Food & Beverage': const Color(0xFFF59E0B),
      'Beauty & Health': const Color(0xFF8B5CF6),
      'Home & Garden': const Color(0xFF10B981),
      'Sports & Outdoor': const Color(0xFF3B82F6),
      'Books & Media': const Color(0xFFF97316),
      'Toys & Kids': const Color(0xFFEF4444),
      'Automotive': const Color(0xFF64748B),
      'Jewelry': const Color(0xFFFBBF24),
    };
    return colorMap[categoryName] ?? const Color(0xFF6B7280);
  }

  void _validateEthiopianPhone(String value) {
    final error = ValidationUtils.validateEthiopianPhone(value);
    setState(() {
      _phoneError = error;
    });
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
    
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.currentTheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('onboarding.otp.sentSuccess'.tr()),
        backgroundColor: theme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    
    // Rebuild this screen whenever localization changes so .tr() strings update immediately
    return Consumer<LocalizationService>(
      builder: (context, localization, _) => BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/');
        }
        
        if (state is OnboardingUserAlreadyExists) {
          setState(() {
            _inlineErrorMessage = 'onboarding.userExists.banner'.tr();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('onboarding.userExists.banner'.tr()),
              backgroundColor: theme.warning,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  context.go('/login');
                },
              ),
            ),
          );
          
          Future.delayed(const Duration(seconds: 4), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
        
        if (state is OnboardingError) {
          // Map common server messages to localized keys
          final lower = state.message.toLowerCase();
          final msgKey = lower.contains('user') && lower.contains('exist')
              ? 'errors.userExists'
              : lower.contains('network')
                  ? 'errors.networkError'
                  : lower.contains('otp') || lower.contains('verification')
                      ? 'errors.invalidOtp'
                      : lower.contains('login') && lower.contains('otp')
                          ? 'errors.loginAfterOtpFailed'
                          : lower.contains('vendor') && lower.contains('failed')
                              ? 'errors.vendorCreationFailed'
                              : lower.contains('registration')
                                  ? 'errors.registrationFailed'
                                  : 'errors.unknownError';
          setState(() {
            _inlineErrorMessage = msgKey.tr();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msgKey.tr()),
              backgroundColor: theme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        if (state is OnboardingInProgress) {
          if (_lastStep != state.currentStep) {
            setState(() {
              _inlineErrorMessage = null;
              _lastStep = state.currentStep;
            });
          }
        }
        
        if (state is OnboardingInProgress && state.currentStep == 1) {
          if (_otpCountdown == 60 && _otpTimer == null) {
            _startOTPTimer();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: Stack(
          children: [
            SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              if (state is OnboardingInProgress) {
                return Column(
                  children: [
                    _buildCompactHeader(context, theme),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceL),
                        child: SlideTransition(
                          position: _contentSlideAnimation,
                          child: FadeTransition(
                            opacity: _contentFadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppThemes.spaceL),
                                _buildWelcomeSection(theme),
                                const SizedBox(height: AppThemes.spaceXL),
                                _buildProgressSection(state, theme),
                                const SizedBox(height: AppThemes.spaceM),
                                if (_inlineErrorMessage != null) ...[
                                  InlineErrorBanner(
                                    theme: theme,
                                    message: _inlineErrorMessage!,
                                  ),
                                  const SizedBox(height: AppThemes.spaceM),
                                ],
                                const SizedBox(height: AppThemes.spaceXL),
                                _buildCurrentStepCard(context, state, theme),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildModernBottomNav(context, state, theme),
                  ],
                );
              }
              
              if (state is OnboardingVendorSubmitted) {
                return _buildVendorSubmissionSuccessPage(state, theme);
              }
              
              if (state is OnboardingUserAlreadyExists) {
                return _buildUserAlreadyExistsPage(state, theme);
              }
              
              if (state is OnboardingVendorSubmissionFailed) {
                return _buildVendorSubmissionErrorPage(state, theme);
              }
              
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              );
            },
          ),
            ),
            
            // Theme selector and language switcher buttons in top-right
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    LanguageSwitcherButton(),
                    SizedBox(width: 8),
                    ThemeSelectorButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, AppThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: _isHeaderCollapsed ? AppThemes.spaceS : AppThemes.spaceXL,
        horizontal: AppThemes.spaceL,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: _isHeaderCollapsed
            ? [
                BoxShadow(
                  color: (theme.isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header row with back button and title
          Row(
            children: [
              // Back button
              IconButton(
                onPressed: () {
                  print('🔙 [ONBOARDING] Back button pressed, navigating to splash');
                  context.go('/splash');
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.textPrimary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.surface,
                  foregroundColor: theme.textPrimary,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: _isHeaderCollapsed ? 16 : 28,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    letterSpacing: 2,
                  ),
                  child: const Text('ZARESHOP'),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: _isHeaderCollapsed
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const SizedBox(height: AppThemes.spaceM),
                      Text(
                        'onboarding.welcome.vendorPortal'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AppThemeData theme) {
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
                  Text(
                    'onboarding.welcome.title'.tr(),
                    style: AppThemes.displayLarge(theme),
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'onboarding.welcome.subtitle'.tr(),
                    style: AppThemes.bodyLarge(theme),
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'onboarding.welcome.description'.tr(),
                    style: AppThemes.bodyLarge(theme),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressSection(OnboardingInProgress state, AppThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${'onboarding.progress.step'.tr()} ${(state.currentStep + 1)}',
              style: AppThemes.titleLarge(theme),
            ),
            Row(
              children: List.generate(state.totalSteps, (index) {
                final isActive = index == state.currentStep;
                final isCompleted = index < state.currentStep;
                return Container(
                  margin: const EdgeInsets.only(left: AppThemes.spaceS),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive ? theme.primary : theme.accent,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: AppThemes.spaceM),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: theme.accent,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepCard(BuildContext context, OnboardingInProgress state, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceXL),
      decoration: AppThemes.cardDecoration(theme),
      child: _getStepWidget(state.currentStep, theme),
    );
  }

  Widget _getStepWidget(int step, AppThemeData theme) {
    if (step == 6 && _subscriptions.isEmpty && !_loadingSubscriptions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSubscriptions();
      });
    }
    
    switch (step) {
      case 0:
        return PhoneNumberStep(
          theme: theme,
          phoneError: _phoneError,
          onValidatePhone: _validateEthiopianPhone,
        );
      case 1:
        return OTPStep(
          theme: theme,
          otpCountdown: _otpCountdown,
          onResendOTP: _resendOTP,
        );
      case 2:
        return BasicInfoStep(
          theme: theme,
          categories: _categories,
          loadingCategories: _loadingCategories,
        );
      case 3:
        return ShippingAddressStep(theme: theme);
      case 4:
        return DocumentsStep(theme: theme);
      case 5:
        return PayoutStep(theme: theme);
      case 6:
        return SubscriptionStep(
          theme: theme,
          subscriptions: _subscriptions,
          loadingSubscriptions: _loadingSubscriptions,
          onFetchSubscriptions: _fetchSubscriptions,
        );
      case 7:
        return AdminApprovalStep(theme: theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildModernBottomNav(BuildContext context, OnboardingInProgress state, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceL),
      color: theme.surface,
      child: Row(
        children: [
          // Previous button (only show if not on first step)
          if (state.currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: AppSecondaryButton(
                text: 'common.back'.tr(),
                onPressed: () {
                  print('🎯 [ONBOARDING_MAIN] Previous button pressed');
                  print('🎯 [ONBOARDING_MAIN] Current step: ${state.currentStep}');
                  print('🎯 [ONBOARDING_MAIN] Dispatching PreviousStep event');
                  context.read<OnboardingBloc>().add(const PreviousStep());
                },
                height: 52,
              ),
            ),
            const SizedBox(width: AppThemes.spaceM),
          ],
          // Continue/Finish button
          Expanded(
            flex: state.currentStep > 0 ? 2 : 1,
            child: AppPrimaryButton(
              text: state.isLastStep
                  ? 'onboarding.progress.finishSetup'.tr()
                  : 'common.continue'.tr(),
              onPressed: state.canProceed
                  ? () {
                      print('🎯 [ONBOARDING_MAIN] Continue button pressed');
                      print('🎯 [ONBOARDING_MAIN] Current step: ${state.currentStep}');
                      print('🎯 [ONBOARDING_MAIN] Is last step: ${state.isLastStep}');
                      print('🎯 [ONBOARDING_MAIN] Can proceed: ${state.canProceed}');
                      print('🎯 [ONBOARDING_MAIN] Dispatching NextStep event');
                      context.read<OnboardingBloc>().add(const NextStep());
                    }
                  : null,
              enabled: state.canProceed,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  // Success page for vendor submission
  Widget _buildVendorSubmissionSuccessPage(OnboardingVendorSubmitted state, AppThemeData theme) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: theme.success,
                ),
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Success Title
              Text(
                'onboarding.vendorSubmitted.title'.tr(),
                style: AppThemes.displayLarge(theme).copyWith(
                  color: theme.success,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceM),
              
              // Success Message
              Text(
                state.message,
                style: AppThemes.bodyLarge(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceL),
                decoration: AppThemes.cardDecoration(theme),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: theme.primary,
                    ),
                    const SizedBox(height: AppThemes.spaceM),
                    Text(
                      'onboarding.vendorSubmitted.reviewTitle'.tr(),
                      style: AppThemes.titleLarge(theme),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppThemes.spaceS),
                    Text(
                      'onboarding.vendorSubmitted.reviewMessage'.tr(),
                      style: AppThemes.bodyMedium(theme),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Action Buttons
              Column(
                children: [
                  AppPrimaryButton(
                    text: 'onboarding.vendorSubmitted.contactHelp'.tr(),
                    icon: Icons.support_agent,
                    onPressed: () {
                      ContactHelpDialog.show(context, theme);
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  AppSecondaryButton(
                    text: 'onboarding.vendorSubmitted.waitForApproval'.tr(),
                    icon: Icons.hourglass_empty,
                    onPressed: () {
                      // Just show a message that they need to wait
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('onboarding.vendorSubmitted.reviewMessage'.tr()),
                          backgroundColor: theme.info,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // User already exists page
  Widget _buildUserAlreadyExistsPage(OnboardingUserAlreadyExists state, AppThemeData theme) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off,
                  size: 60,
                  color: theme.warning,
                ),
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Title
              Text(
                'onboarding.userExists.title'.tr(),
                style: AppThemes.displayLarge(theme).copyWith(
                  color: theme.warning,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceM),
              
              // Message
              Text(
                state.message,
                style: AppThemes.bodyLarge(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Action Buttons
              Column(
                children: [
                  AppPrimaryButton(
                    text: 'onboarding.userExists.loginInstead'.tr(),
                    onPressed: () {
                      context.go('/login');
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  AppSecondaryButton(
                    text: 'onboarding.userExists.tryDifferent'.tr(),
                    onPressed: () {
                      context.go('/onboarding');
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error page for vendor submission failure
  Widget _buildVendorSubmissionErrorPage(OnboardingVendorSubmissionFailed state, AppThemeData theme) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: theme.error,
                ),
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Error Title
              Text(
                'onboarding.submissionFailed.title'.tr(),
                style: AppThemes.displayLarge(theme).copyWith(
                  color: theme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceM),
              
              // Error Message
              Text(
                state.error,
                style: AppThemes.bodyLarge(theme),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceL),
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(
                    color: theme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 32,
                      color: theme.error,
                    ),
                    const SizedBox(height: AppThemes.spaceM),
                    Text(
                      'onboarding.submissionFailed.whatNext'.tr(),
                      style: AppThemes.titleMedium(theme).copyWith(
                        color: theme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppThemes.spaceS),
                    Text(
                      'onboarding.submissionFailed.hint'.tr(),
                      style: AppThemes.bodyMedium(theme),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppThemes.spaceXL),
              
              // Action Buttons
              Column(
                children: [
                  AppPrimaryButton(
                    text: 'onboarding.submissionFailed.tryAgain'.tr(),
                    onPressed: () {
                      context.read<OnboardingBloc>().add(const RetryVendorSubmission());
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  AppSecondaryButton(
                    text: 'onboarding.submissionFailed.contactSupport'.tr(),
                    onPressed: () {
                      ContactHelpDialog.show(context, theme);
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
