import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../shared/shared.dart';

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
    
    // Fetch categories from backend
    _fetchCategories();
  }
  
  Future<void> _fetchSubscriptions() async {
    
    setState(() {
      _loadingSubscriptions = true;
    });
    
    print('🔄 [FRONTEND] Set loading state to true, calling ApiService...');
    
    try {
      final result = await ApiService.fetchSubscriptions();
      
      print('📦 [FRONTEND] API Result received:');
      print('   Success: ${result['success']}');
      print('   Keys: ${result.keys.toList()}');
      
      if (result['success'] == true && mounted) {
        print('✅ [FRONTEND] Success response received, processing data...');
        final subscriptionsData = result['subscriptions'] as List<dynamic>;
        print('📊 [FRONTEND] Raw subscriptions data: $subscriptionsData');
        print('📊 [FRONTEND] Subscriptions count: ${subscriptionsData.length}');
        
        final processedSubscriptions = subscriptionsData.map((sub) {
          print('🔍 [FRONTEND] Processing subscription: $sub');
          return {
            'id': sub['id'],
            'name': sub['name'],
            'price': sub['price'],
            'duration': sub['duration'],
            'features': sub['features'] ?? [],
          };
        }).toList();
        
        print('✅ [FRONTEND] Processed ${processedSubscriptions.length} subscriptions');
        
        setState(() {
          _subscriptions = processedSubscriptions;
          _loadingSubscriptions = false;
        });
        
        print('✅ [FRONTEND] State updated successfully!');
        print('📋 [FRONTEND] Final subscriptions in state: $_subscriptions');
      } else if (mounted) {
        print('❌ [FRONTEND] API call failed or returned error');
        print('❌ [FRONTEND] Error details: ${result['error'] ?? 'Unknown error'}');
        
        setState(() {
          _loadingSubscriptions = false;
        });
        
        print('🔄 [FRONTEND] Setting fallback subscription...');
        // Fallback to default subscription if fetch fails
        setState(() {
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
        
        print('⚠️ [FRONTEND] Fallback subscription set: $_subscriptions');
      } else {
        print('⚠️ [FRONTEND] Widget not mounted, skipping state update');
      }
    } catch (e, stackTrace) {
      
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
        print('🛡️ [FRONTEND] Error fallback subscription set');
      }
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
      });
      // Fallback to default categories if fetch fails
      setState(() {
        _categories = [
          {'id': 1, 'name': 'Electronics', 'icon': Icons.devices, 'color': const Color(0xFF6366F1)},
          {'id': 2, 'name': 'Fashion', 'icon': Icons.checkroom, 'color': const Color(0xFFEC4899)},
          {'id': 3, 'name': 'Food & Beverage', 'icon': Icons.restaurant, 'color': const Color(0xFFF59E0B)},
          {'id': 4, 'name': 'Beauty & Health', 'icon': Icons.spa, 'color': const Color(0xFF8B5CF6)},
        ];
      });
    }
  }
  
  IconData _getCategoryIcon(String categoryName) {
    // Map category names to icons
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
    // Map category names to colors
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
    
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.currentTheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP sent successfully'),
        backgroundColor: theme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/');
        }
        
        // Handle vendor submission success
        if (state is OnboardingVendorSubmitted) {
          // Success handled in BlocBuilder
        }
        
        // Handle vendor submission failure
        if (state is OnboardingVendorSubmissionFailed) {
          // Error handled in BlocBuilder
        }
        
        // Handle user already exists - redirect to login
        if (state is OnboardingUserAlreadyExists) {
          // Show message and redirect to login page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.warning,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to login page
                  context.go('/login');
                },
              ),
            ),
          );
          
          // Auto redirect after a short delay
          Future.delayed(const Duration(seconds: 4), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
        
        // Show error messages
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        // Start OTP timer when reaching OTP step
        if (state is OnboardingInProgress && state.currentStep == 1) {
          if (_otpCountdown == 60 && _otpTimer == null) {
            _startOTPTimer();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              if (state is OnboardingInProgress) {
                return Column(
                  children: [
                    // Compact Logo Header
                    _buildCompactHeader(context, theme),
                    
                    // Main Content with Rain Drop Animation
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
                                const SizedBox(height: AppThemes.spaceXL),
                                _buildCurrentStepCard(context, state, theme),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Modern Bottom Navigation
                    _buildModernBottomNav(context, state, theme),
                  ],
                );
              }
              
              // Handle vendor submission success
              if (state is OnboardingVendorSubmitted) {
                return _buildVendorSubmissionSuccessPage(state);
              }
              
              // Handle user already exists - show redirect page
              if (state is OnboardingUserAlreadyExists) {
                return _buildUserAlreadyExistsPage(state);
              }
              
              // Handle vendor submission failure
              if (state is OnboardingVendorSubmissionFailed) {
                return _buildVendorSubmissionErrorPage(state);
              }
              
              // Loading state
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              );
            },
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
                color: theme.primary,
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
                      const SizedBox(height: AppThemes.spaceM),
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(_isHeaderCollapsed ? 0.0 : 1.0),
                        child: Text(
                          'VENDOR PORTAL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textSecondary,
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
                    'Welcome to ZareShop Vendor!',
                    style: AppThemes.displayLarge(theme),
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'Let\'s set up your shop in a few simple steps.',
                    style: AppThemes.bodyLarge(theme),
                  ),
                  const SizedBox(height: AppThemes.spaceM),
                  Text(
                    'You\'ll personalize your business profile, add your first products, and link payment options.',
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
              'Step ${state.currentStep + 1} of ${state.totalSteps}',
              style: AppThemes.titleLarge(theme),
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
                        theme: theme,
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
        const SizedBox(height: AppThemes.spaceM),
        // Progress bar with overshoot effect
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: theme.accent,
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
                        gradient: theme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.4),
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



  Widget _buildCurrentStepCard(BuildContext context, OnboardingInProgress state, AppThemeData theme) {
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
        padding: const EdgeInsets.all(AppThemes.spaceXL),
        decoration: AppThemes.cardDecoration(theme),
        child: _getStepWidget(state.currentStep, theme),
      ),
    );
  }

  Widget _getStepWidget(int step, AppThemeData theme) {
    // Fetch subscriptions when reaching step 6
    if (step == 6 && _subscriptions.isEmpty && !_loadingSubscriptions) {
      // Use WidgetsBinding to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSubscriptions();
      });
    }
    
    switch (step) {
      case 0:
        return _buildPhoneNumberStep(theme);
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildBasicInfoStep();
      case 3:
        return _buildShippingAddressStep();
      case 4:
        return _buildDocumentsStep();
      case 5:
        return _buildPayoutStep();
      case 6:
        return _buildSubscriptionStep();
      case 7:
        return _buildAdminApprovalStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 0: Phone Number
  Widget _buildPhoneNumberStep(AppThemeData theme) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Vendor Registration',
              style: AppThemes.headlineLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: theme.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.success,
                      borderRadius: BorderRadius.circular(AppThemes.spaceS),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Account',
                          style: AppThemes.titleMedium(theme),
                        ),
                        const SizedBox(height: AppThemes.spaceXS),
                        Text(
                          'Register your business to start selling',
                          style: AppThemes.bodySmall(theme),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'Phone Number',
              style: AppThemes.titleLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                color: theme.surface,
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
                                  decoration: BoxDecoration(
                                    gradient: theme.successGradient,
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
                        const SizedBox(width: AppThemes.spaceS),
                        Text(
                          '+251',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.accent,
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
                      decoration: InputDecoration(
                        hintText: '912345678',
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceM, vertical: AppThemes.spaceM),
                        hintStyle: TextStyle(
                          color: theme.textHint,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemes.spaceM),
            if (_phoneError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppThemes.spaceS),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.error,
                      size: 16,
                    ),
                    const SizedBox(width: AppThemes.spaceXS),
                    Text(
                      _phoneError!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.error,
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
                color: _phoneError != null ? theme.error.withOpacity(0.7) : theme.textSecondary,
              ),
            ),
            const SizedBox(height: AppThemes.spaceL),
            Text(
              'Password',
              style: AppThemes.titleLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
              ),
              child: TextField(
                onChanged: (value) {
                  context.read<OnboardingBloc>().add(UpdatePassword(value));
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Color(0xFF22C55E),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum 6 characters required',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
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
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'First Name *',
                    hint: 'Enter first name',
                    onChanged: (value) {
                      context.read<OnboardingBloc>().add(UpdateFirstName(value));
                      // Auto-update full name when first or last name changes
                      final state = context.read<OnboardingBloc>().state;
                      if (state is OnboardingInProgress) {
                        final lastName = state.data.lastName;
                        final fullName = '$value ${lastName}'.trim();
                        context.read<OnboardingBloc>().add(UpdateFullName(fullName));
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'First name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Last Name *',
                    hint: 'Enter last name',
                    onChanged: (value) {
                      context.read<OnboardingBloc>().add(UpdateLastName(value));
                      // Auto-update full name when first or last name changes
                      final state = context.read<OnboardingBloc>().state;
                      if (state is OnboardingInProgress) {
                        final firstName = state.data.firstName;
                        final fullName = '$firstName $value'.trim();
                        context.read<OnboardingBloc>().add(UpdateFullName(fullName));
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Last name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Name *',
              hint: 'Enter business name',
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBusinessName(value)),
              validator: ValidationUtils.validateBusinessName,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email Address *',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateEmail(value)),
              validator: ValidationUtils.validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Description *',
              hint: 'Describe what you sell',
              maxLines: 3,
              onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBusinessDescription(value)),
              validator: ValidationUtils.validateBusinessDescription,
            ),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
          ],
        );
      },
    );
  }

  // Step 3: Shipping Address
  Widget _buildShippingAddressStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your business shipping address',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Google Maps Location Picker
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to select location on map',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppPrimaryButton(
                        text: 'Pick Location',
                        icon: Icons.location_on,
                        onPressed: () {
                          // TODO: Open Google Maps picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Maps picker coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              
              // Required: Address Line 1
              _buildTextField(
                label: 'Address Line 1 *',
                hint: 'Street address, P.O. box',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(addressLine1: value)),
              ),
              const SizedBox(height: 16),
              
              // Optional: Address Line 2
              _buildTextField(
                label: 'Address Line 2 (Optional)',
                hint: 'Apartment, suite, unit, building, floor',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(addressLine2: value)),
              ),
              const SizedBox(height: 16),
              
              // Optional: City
              _buildTextField(
                label: 'City (Optional)',
                hint: 'e.g., Addis Ababa',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(city: value)),
              ),
              const SizedBox(height: 16),
              
              // Optional: Region and State in Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Region (Optional)',
                      hint: 'e.g., Oromia',
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(region: value)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'State (Optional)',
                      hint: 'State',
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(state: value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Optional: Subcity and Woreda in Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Subcity (Optional)',
                      hint: 'e.g., Bole',
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(subcity: value)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Woreda (Optional)',
                      hint: 'Woreda',
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(woreda: value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Optional: Kebele and Postal Code in Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Kebele (Optional)',
                      hint: 'Kebele',
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(kebele: value)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Postal Code (Optional)',
                      hint: 'e.g., 1000',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(postalCode: value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Optional: Country (default Ethiopia)
              _buildTextField(
                label: 'Country (Optional)',
                hint: 'Ethiopia',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateAddress(country: value)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Step 4: Documents
  Widget _buildDocumentsStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
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
            _buildImageUploadField(
              label: 'Cover Photo',
              hint: 'Tap to upload business cover photo',
              imagePath: state.data.coverPhotoUrl,
              onTap: () {
                _pickImage((path) {
                  context.read<OnboardingBloc>().add(UpdateCoverPhoto(path));
                });
              },
            ),
            const SizedBox(height: 16),
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
                label: 'Account Holder Name',
                hint: 'Enter account holder full name',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBankAccount(accountHolderName: value)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Bank Name',
                hint: 'Enter bank name (e.g., CBE, Dashen)',
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
              // Phone number suggestion for Telebirr
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  if (state is OnboardingInProgress) {
                    final userPhone = state.data.phoneNumber;
                    final walletNumber = state.data.mobileWalletNumber;
                    final shouldShowSuggestion = userPhone.isNotEmpty && 
                                                walletNumber.isEmpty && 
                                                userPhone.startsWith('+251');
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Telebirr Wallet Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Spacer(),
                            if (shouldShowSuggestion)
                              GestureDetector(
                                onTap: () {
                                  context.read<OnboardingBloc>().add(UpdateMobileWallet(userPhone));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_fix_high,
                                        size: 14,
                                        color: const Color(0xFF22C55E),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Use my phone',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF22C55E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (shouldShowSuggestion) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: const Color(0xFF22C55E),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Would you like to use your phone number ($userPhone) as your Telebirr wallet?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: const Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Account Holder Name',
                hint: 'Enter your full name',
                onChanged: (value) => context.read<OnboardingBloc>().add(UpdateBankAccount(accountHolderName: value)),
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

  // Step 5: Subscription Selection
  Widget _buildSubscriptionStep() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                AppSecondaryButton(
                  text: 'Debug: Fetch',
                  onPressed: () {
                    print('🔧 [DEBUG] Manual subscription fetch triggered');
                    _fetchSubscriptions();
                  },
                  width: 120,
                  height: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a subscription plan to get started',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (_loadingSubscriptions) ...
              [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                    ),
                  ),
                ),
                // Add loading text for better UX
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Loading subscription plans...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ]
            else if (_subscriptions.isEmpty) ...
              [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No subscription plans available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your internet connection and try again',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          text: 'Retry',
                          onPressed: () {
                            print('🔄 [SUBSCRIPTION_WIDGET] Retry button pressed');
                            _fetchSubscriptions();
                          },
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = _subscriptions[index];
                  final isSelected = state.data.selectedSubscriptionId == subscription['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        context.read<OnboardingBloc>().add(
                          UpdateSubscription(subscription['id'] as int),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF22C55E)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subscription['name'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected 
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Selected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${subscription['price']} ETB',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '/ ${subscription['duration']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (subscription['features'] != null && 
                                (subscription['features'] as List).isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...((subscription['features'] as List).map((feature) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Color(0xFF22C55E),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              
              // Terms and Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: state.data.agreeTermsCheck,
                    onChanged: (value) {
                      context.read<OnboardingBloc>().add(ToggleTermsAgreement(value ?? false));
                    },
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
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  // Step 7: Admin Approval
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
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
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
                value: state.data.confirmDetailsCheck,
                onChanged: (value) {
                  context.read<OnboardingBloc>().add(UpdatePayoutCheckboxes(
                    confirmDetailsCheck: value,
                  ));
                },
              ),
              const SizedBox(height: 16),
              _buildCheckboxItem(
                'I authorize payouts to the selected default payment method',
                value: state.data.authorizePayoutCheck,
                onChanged: (value) {
                  context.read<OnboardingBloc>().add(UpdatePayoutCheckboxes(
                    authorizePayoutCheck: value,
                  ));
                },
              ),
            ],
          ),
        );
      },
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
    String? Function(String?)? validator,
    String? initialValue,
  }) {
    return _TextFieldWidget(
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      initialValue: initialValue,
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
    // Use categories from backend (fetched in initState)
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        final selectedCategory = state.data.category;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Category *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingCategories)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                  ),
                ),
              )
            else if (_categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                // Support multiple category selection
                final selectedCategories = selectedCategory.isEmpty 
                    ? <String>[]
                    : selectedCategory.contains(',')
                        ? selectedCategory.split(',').map((e) => e.trim()).toList()
                        : [selectedCategory];
                final isSelected = selectedCategories.contains(category['name']);
                
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
                            final categoryName = category['name'] as String;
                            final currentCategories = selectedCategory.isEmpty 
                                ? <String>[]
                                : selectedCategory.contains(',')
                                    ? selectedCategory.split(',').map((e) => e.trim()).toList()
                                    : [selectedCategory];
                            
                            List<String> newCategories;
                            if (currentCategories.contains(categoryName)) {
                              // Remove category if already selected
                              newCategories = currentCategories.where((c) => c != categoryName).toList();
                            } else {
                              // Add category if not selected
                              newCategories = [...currentCategories, categoryName];
                            }
                            
                            // Convert back to comma-separated string
                            final newCategoryString = newCategories.join(',');
                            context.read<OnboardingBloc>().add(UpdateCategory(newCategoryString));
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

  Widget _buildModernBottomNav(BuildContext context, OnboardingInProgress state, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceL),
      color: theme.surface,
      child: AppPrimaryButton(
        text: state.isLastStep ? 'Finish Setup' : 'Continue',
        onPressed: state.canProceed
            ? () {
                context.read<OnboardingBloc>().add(const NextStep());
              }
            : null,
        enabled: state.canProceed,
        height: 52,
      ),
    );
  }

  // Success page for vendor submission
  Widget _buildVendorSubmissionSuccessPage(OnboardingVendorSubmitted state) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981), // Emerald green
              Color(0xFF22C55E), // Green
              Color(0xFF16A34A), // Dark green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      child: Stack(
        children: [
          // Animated background particles
          ...List.generate(20, (index) => 
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 2000 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Positioned(
                  left: (index * 50.0) % MediaQuery.of(context).size.width,
                  top: (index * 80.0) % MediaQuery.of(context).size.height,
                  child: Transform.scale(
                    scale: 0.3 + (value * 0.7),
                    child: Opacity(
                      opacity: (0.1 + (value * 0.3)).clamp(0.0, 1.0),
                      child: Container(
                        width: 20 + (index % 3) * 10,
                        height: 20 + (index % 3) * 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              // Animated success icon with celebration
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Main success circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.celebration,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                        // Floating particles around icon
                        ...List.generate(8, (index) {
                          final angle = (index * 45.0) * (3.14159 / 180);
                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * 100 * value,
                              math.sin(angle) * 100 * value,
                            ),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated title
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          const Text(
                            '🎉 Congratulations! 🎉',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Application Submitted Successfully!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Animated message with beautiful card
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              color: Colors.white.withOpacity(0.9),
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your vendor application is now under review',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We\'ll notify you once it\'s approved. This usually takes 1-2 business days.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated buttons
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            // Primary button
                            AppSecondaryButton(
                              text: 'Contact Help',
                              icon: Icons.support_agent,
                              onPressed: () {
                                // Contact help functionality - could open help page or contact form
                                // For now, just show a snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contact our support team at support@zareshop.com'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            // Secondary button
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  // Could add functionality to view application status
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white.withOpacity(0.9),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.track_changes, size: 18, color: Colors.white.withOpacity(0.8)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Track Application Status',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
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
              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Error page for vendor submission failure
  Widget _buildVendorSubmissionErrorPage(OnboardingVendorSubmissionFailed state) {
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          
          // Error Title
          const Text(
            'Submission Failed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Error Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.error,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Try Again Button
                AppPrimaryButton(
                  text: 'Try Again',
                  onPressed: () {
                    context.read<OnboardingBloc>().add(const InitializeOnboarding());
                  },
                ),
                const SizedBox(height: 12),
                
                // Go to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Skip to Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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

  // Page for when user already exists - redirect to login
  Widget _buildUserAlreadyExistsPage(OnboardingUserAlreadyExists state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEA580C), Color(0xFFF97316)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Info Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          
          // Title
          const Text(
            'Account Already Exists',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          if (state.phoneNumber != null || state.email != null) ...[
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (state.phoneNumber != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.phoneNumber!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (state.email != null && state.phoneNumber != null)
                    const SizedBox(height: 8),
                  if (state.email != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.email!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Go to Login Button
                AppPrimaryButton(
                  text: 'Go to Login',
                  onPressed: () {
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 12),
                
                // Start Over Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.read<OnboardingBloc>().add(const InitializeOnboarding());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Over with Different Info',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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
}

// Separate widget for dot indicator with spring animation
class _DotIndicator extends StatefulWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;
  final AppThemeData theme;
  final VoidCallback? onTap;

  const _DotIndicator({
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.theme,
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
              margin: const EdgeInsets.only(left: AppThemes.spaceS),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.isCompleted || widget.isActive
                    ? widget.theme.primary
                    : widget.theme.accent,
                shape: BoxShape.circle,
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: widget.theme.primary.withValues(alpha: 0.4),
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

class _TextFieldWidget extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;

  const _TextFieldWidget({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    required this.onChanged,
    this.validator,
    this.initialValue,
  });

  @override
  State<_TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<_TextFieldWidget> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Validate the input
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
    
    // Call the onChanged callback
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorText != null ? Colors.red : const Color(0xFF22C55E),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
