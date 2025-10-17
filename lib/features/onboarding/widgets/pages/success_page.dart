import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../shared/shared.dart';
import '../../bloc/onboarding_state.dart';

class SuccessPage extends StatelessWidget {
  final OnboardingVendorSubmitted state;

  const SuccessPage({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.successGradient,
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => 
              _AnimatedParticle(
                index: index,
                screenWidth: MediaQuery.of(context).size.width,
                screenHeight: MediaQuery.of(context).size.height,
              ),
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated success icon
                      const _AnimatedSuccessIcon(),
                      
                      const SizedBox(height: AppTheme.spaceXXL),
                      
                      // Animated title
                      const _AnimatedTitle(),
                      
                      const SizedBox(height: AppTheme.spaceL),
                      
                      // Animated message card
                      const _AnimatedMessageCard(),
                      
                      const SizedBox(height: AppTheme.spaceXXL),
                      
                      // Animated buttons
                      _AnimatedButtons(),
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
}

class _AnimatedParticle extends StatelessWidget {
  final int index;
  final double screenWidth;
  final double screenHeight;

  const _AnimatedParticle({
    required this.index,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 2000 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          left: (index * 50.0) % screenWidth,
          top: (index * 80.0) % screenHeight,
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
    );
  }
}

class _AnimatedSuccessIcon extends StatelessWidget {
  const _AnimatedSuccessIcon();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppTheme.celebrationAnimation,
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
    );
  }
}

class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppTheme.slowAnimation,
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: const Column(
              children: [
                Text(
                  '🎉 Congratulations! 🎉',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXXL,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spaceS),
                Text(
                  'Application Submitted Successfully!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeHero,
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
    );
  }
}

class _AnimatedMessageCard extends StatelessWidget {
  const _AnimatedMessageCard();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
              padding: const EdgeInsets.all(AppTheme.spaceL),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
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
                  const SizedBox(height: AppTheme.spaceM),
                  Text(
                    'Your vendor application is now under review',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceS),
                  Text(
                    'We\'ll notify you once it\'s approved. This usually takes 1-2 business days.',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
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
    );
  }
}

class _AnimatedButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: AppTheme.celebrationAnimation,
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXL),
              child: Column(
                children: [
                  // Primary button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact our support team at support@zareshop.com'),
                            backgroundColor: AppTheme.emeraldGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.emeraldGreen,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.support_agent, size: 20),
                          SizedBox(width: AppTheme.spaceS),
                          Text(
                            'Contact Help',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeRegular,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceM),
                  // Secondary button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Could add functionality to view application status
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.track_changes, 
                            size: 18, 
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: AppTheme.spaceS),
                          Text(
                            'Track Application Status',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeMedium,
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
    );
  }
}
