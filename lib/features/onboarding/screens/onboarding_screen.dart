import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/full_name_step.dart';
import '../widgets/sells_products_step.dart';
import '../widgets/monthly_revenue_step.dart';
import '../widgets/email_address_step.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOut,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
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
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              if (state is OnboardingInProgress) {
                return Column(
                  children: [
                    // Enhanced Header
                    _buildEnhancedHeader(context),
                    
                    // Enhanced Progress
                    _buildEnhancedProgress(state),
                    
                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildTitle(),
                              const SizedBox(height: 32),
                              _buildCompactStepsList(context, state),
                              const SizedBox(height: 24),
                              _buildCurrentStepCard(context, state),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Enhanced Bottom Navigation
                    _buildEnhancedBottomNav(context, state),
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

  Widget _buildEnhancedHeader(BuildContext context) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981), // Solid green color
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ZareShop Logo - Direct on green background
              FutureBuilder<bool>(
                future: _checkImageExists('logo/logo.png'),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Image.asset(
                      'logo/logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultLogoText();
                      },
                    );
                  }
                  return _buildDefaultLogoText();
                },
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Text(
                'Vendor Portal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogoText() {
    return const Text(
      'ZARE SHOP',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 2,
      ),
    );
  }

  Future<bool> _checkImageExists(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }


  Widget _buildEnhancedProgress(OnboardingInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${state.currentStep + 1}/${state.totalSteps}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 500),
                tween: IntTween(begin: 0, end: (state.progress * 100).toInt()),
                builder: (context, value, child) {
                  return Text(
                    '$value%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
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
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Solid color
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ONBOARDING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD97706),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome to ZareShop!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A few quick questions to customize your experience',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStepsList(BuildContext context, OnboardingInProgress state) {
    final steps = [
      {'icon': Icons.person_rounded, 'title': 'Full Name'},
      {'icon': Icons.store_rounded, 'title': 'Products Online'},
      {'icon': Icons.monetization_on_rounded, 'title': 'Monthly Revenue'},
      {'icon': Icons.email_rounded, 'title': 'Email Address'},
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = state.data.isStepCompleted(index);
        final isCurrent = state.currentStep == index;
        
        return TweenAnimationBuilder<double>(
          key: ValueKey('step_$index'),
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildCompactStepItem(
              context,
              state,
              index,
              steps[index]['icon'] as IconData,
              steps[index]['title'] as String,
              isCompleted,
              isCurrent,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompactStepItem(
    BuildContext context,
    OnboardingInProgress state,
    int index,
    IconData icon,
    String title,
    bool isCompleted,
    bool isCurrent,
  ) {
    return GestureDetector(
      onTap: () {
        if (index <= state.currentStep || isCompleted) {
          context.read<OnboardingBloc>().add(GoToStep(index));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFFD1FAE5) // Light green for current
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent || isCompleted
                ? const Color(0xFF10B981)
                : const Color(0xFFE5E7EB),
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                  color: isCurrent || isCompleted
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepCard(BuildContext context, OnboardingInProgress state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(state.currentStep),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
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
        return const FullNameStep();
      case 1:
        return const SellsProductsStep();
      case 2:
        return const MonthlyRevenueStep();
      case 3:
        return const EmailAddressStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEnhancedBottomNav(BuildContext context, OnboardingInProgress state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!state.isFirstStep)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () {
                  context.read<OnboardingBloc>().add(const PreviousStep());
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!state.isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: state.canProceed
                    ? () {
                        context.read<OnboardingBloc>().add(const NextStep());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: state.canProceed ? 2 : 0,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.isLastStep ? 'Finish' : 'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: state.canProceed ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      state.isLastStep
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      color: state.canProceed ? Colors.white : const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
