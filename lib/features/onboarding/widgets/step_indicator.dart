import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double progress;
  final Function(int) onDotTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            // Step dots with spring animation
            Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index == currentStep;
                final isCompleted = index < currentStep;
                return TweenAnimationBuilder<double>(
                  key: ValueKey('dot_$index'),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutBack,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: DotIndicator(
                        index: index,
                        isActive: isActive,
                        isCompleted: isCompleted,
                        onTap: isCompleted
                            ? () => onDotTap(index)
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
        AnimatedProgressBar(progress: progress),
      ],
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double progress;

  const AnimatedProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
            tween: Tween(begin: 0.0, end: progress),
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
    );
  }
}

class DotIndicator extends StatefulWidget {
  final int index;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const DotIndicator({
    super.key,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
  });

  @override
  State<DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<DotIndicator>
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
