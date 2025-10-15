import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final bool isCollapsed;

  const OnboardingHeader({
    super.key,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isCollapsed ? 8 : 32,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isCollapsed
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
                fontSize: isCollapsed ? 16 : 28,
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
            child: isCollapsed
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: AlwaysStoppedAnimation(isCollapsed ? 0.0 : 1.0),
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
}
