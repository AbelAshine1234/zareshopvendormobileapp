import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../core/bloc/socket_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../steps/steps.dart';
import '../../../shared/screens/admin_approval_screen.dart';
import 'vendor_creation_failed_screen.dart';
import 'business_name_conflict_screen.dart';
import '../widgets/widgets.dart';
import '../widgets/onboarding_layout_widget.dart';
import '../../../shared/widgets/common/global_loader.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/categories_service.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/bloc/app_data.dart';

class OnboardingMainScreen extends StatelessWidget {
  final bool useMockData;

  const OnboardingMainScreen({
    super.key,
    this.useMockData = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OnboardingBloc()
            ..add(InitializeOnboarding(useMockData: useMockData)),
        ),
      ],
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
  
  String? _phoneError;
  int _otpCountdown = 60;
  Timer? _otpTimer;
  String? _inlineErrorMessage;
  int _lastStep = -1;
  OnboardingInProgress? _lastInProgress;
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = false;
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

    LocalizationService.instance.loadLanguage(
      LocalizationService.instance.currentLanguage,
    );

    // Fetch categories and subscriptions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
      _fetchSubscriptions();
    });
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

  void _updateCategoriesFromBloc(List<dynamic> categories) {
    if (mounted) {
      setState(() {
        _categories = categories.map((cat) {
          return {
            'id': cat.id,
            'name': cat.name,
            'description': cat.description,
          };
        }).toList();
        _loadingCategories = false;
      });
    }
  }

  void _updateSubscriptionsFromBloc(List<Map<String, dynamic>> subscriptions) {
    if (mounted) {
      setState(() {
        _subscriptions = subscriptions;
        _loadingSubscriptions = false;
      });
    }
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
  }

  void _fetchSubscriptions() {
    context.read<AppDataBloc>().add(const FetchSubscriptions());
  }

  void _fetchCategories() {
    context.read<AppDataBloc>().add(const FetchCategories());
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    
    return Consumer<LocalizationService>(
      builder: (context, localization, _) => BlocListener<AppDataBloc, AppDataState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            _updateCategoriesFromBloc(state.categories);
          } else if (state is CategoriesError) {
            _updateCategoriesFromBloc(state.fallbackCategories);
          } else if (state is SubscriptionsLoaded) {
            _updateSubscriptionsFromBloc(state.subscriptions);
          } else if (state is SubscriptionsError) {
            _updateSubscriptionsFromBloc(state.fallbackSubscriptions);
          } else if (state is AllAppDataLoaded) {
            _updateCategoriesFromBloc(state.categories);
            _updateSubscriptionsFromBloc(state.subscriptions);
          }
        },
        // Listen to global SocketBloc for WebSocket events
        child: BlocListener<SocketBloc, SocketState>(
          listener: (context, socketState) {
            // Handle vendor approval from WebSocket
            if (socketState is SocketVendorApproved) {
              GlobalLoader.hide(context);
              
              // Show approval dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: theme.success,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'onboarding.vendorApproval.congratulations'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Message
                      Text(
                        socketState.event.message ?? 'onboarding.vendorApproval.approvedMessage'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Continue Button
                      AppPrimaryButton(
                        text: 'onboarding.vendorApproval.goToDashboard'.tr(),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Handle vendor rejection from WebSocket
            if (socketState is SocketVendorRejected) {
              GlobalLoader.hide(context);
              
              // Show rejection dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: theme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Error Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cancel,
                          color: theme.error,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'onboarding.vendorApproval.rejectedTitle'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Reason
                      Text(
                        socketState.event.reason ?? 'onboarding.vendorApproval.rejectedMessage'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              text: 'onboarding.vendorApproval.contactSupport'.tr(),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                // TODO: Navigate to support page
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppPrimaryButton(
                              text: 'common.ok'.tr(),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Handle vendor status change from WebSocket
            if (socketState is SocketVendorStatusChanged) {
              GlobalLoader.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.info, color: theme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vendor status changed: ${socketState.event.oldStatus} → ${socketState.event.newStatus}',
                          style: TextStyle(color: theme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: theme.primary.withValues(alpha: 0.1),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          child: BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingCompleted) {
                context.go('/');
              }
              
              // Unified error handling
              if (state is OnboardingError) {
                GlobalLoader.hide(context);
                setState(() {
                  _inlineErrorMessage = state.code == 'USER_ALREADY_EXISTS'
                    ? 'onboarding.userExists.banner'.tr()
                    : state.message;
                });
              }
              
              if (state is OnboardingLoading) {
                GlobalLoader.show(context, message: 'common.loading'.tr());
              }

              if (state is OnboardingInProgress || state is OnboardingVendorSubmitted || state is OnboardingBusinessNameConflict || state is OnboardingVendorSubmissionFailed) {
                GlobalLoader.hide(context);
              }

              if (state is OnboardingInProgress) {
                if (_lastStep != state.currentStep) {
                  setState(() {
                    _inlineErrorMessage = null;
                    _lastStep = state.currentStep;
                  });
                }
                _lastInProgress = state;
              }
              
              if (state is OnboardingInProgress && state.currentStep == 1) {
                if (_otpCountdown == 60 && _otpTimer == null) {
                  _startOTPTimer();
                }
              }
              
              // Connect WebSocket when user is authenticated (after OTP verification)
              if (state is OnboardingUserAuthenticated) {
                context.read<SocketBloc>().add(const SocketConnect());
              }
              
              // Subscribe to WebSocket updates when vendor is submitted
              if (state is OnboardingVendorSubmitted) {
                final vendorId = state.apiResponse['data']?['vendor']?['id'] ?? state.apiResponse['vendor_id'];
                if (vendorId != null) {
                  context.read<SocketBloc>().add(SocketSubscribeToVendor(vendorId as int));
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
                return OnboardingLayoutWidget(
                  state: state,
                  subscriptions: _subscriptions,
                  loadingSubscriptions: _loadingSubscriptions,
                  categories: _categories,
                  loadingCategories: _loadingCategories,
                  onFetchSubscriptions: _fetchSubscriptions,
                  inlineErrorMessage: _inlineErrorMessage,
                  onErrorRetry: _inlineErrorMessage != null ? () {
                    setState(() {
                      _inlineErrorMessage = null;
                    });
                  } : null,
                  isHeaderCollapsed: _isHeaderCollapsed,
                  scrollController: _scrollController,
                  contentSlideAnimation: _contentSlideAnimation,
                  contentFadeAnimation: _contentFadeAnimation,
                );
              }
              
              // While loading, keep showing the last in-progress UI to avoid flicker
              if (state is OnboardingLoading && _lastInProgress != null) {
                return OnboardingLayoutWidget(
                  state: _lastInProgress!,
                  subscriptions: _subscriptions,
                  loadingSubscriptions: _loadingSubscriptions,
                  categories: _categories,
                  loadingCategories: _loadingCategories,
                  onFetchSubscriptions: _fetchSubscriptions,
                  inlineErrorMessage: _inlineErrorMessage,
                  onErrorRetry: _inlineErrorMessage != null ? () {
                    setState(() {
                      _inlineErrorMessage = null;
                    });
                  } : null,
                  isHeaderCollapsed: _isHeaderCollapsed,
                  scrollController: _scrollController,
                  contentSlideAnimation: _contentSlideAnimation,
                  contentFadeAnimation: _contentFadeAnimation,
                );
              }
              
              if (state is OnboardingVendorSubmitted) {
                // Show admin approval screen (WebSocket events handled by BlocListener)
                return const AdminApprovalScreen();
              }
              
              // The unified OnboardingError now covers user-exists and other errors
              
              if (state is OnboardingBusinessNameConflict) {
                return BusinessNameConflictScreen(state: state);
              }
              
              if (state is OnboardingVendorSubmissionFailed) {
                return VendorCreationFailedScreen(state: state);
              }
              
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              );
                },
              ),
            ),
            
            Positioned(
              top: 8,
              right: 16,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LanguageSwitcherButton(),
                    const SizedBox(width: 8),
                    ThemeSelectorButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }
}
