import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../models/onboarding_data.dart';

class MonthlyRevenueStep extends StatelessWidget {
  const MonthlyRevenueStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingInProgress) {
          final selectedValue = state.data.monthlyRevenue;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Average Monthly Revenue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This helps us personalize your experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ...RevenueOption.options.map((option) {
                final isSelected = selectedValue == option.value;
                final bloc = context.read<OnboardingBloc>();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RevenueOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      bloc.add(UpdateMonthlyRevenue(option.value));
                      // Auto-advance to next step after a brief delay
                      Future.delayed(const Duration(milliseconds: 400), () {
                        bloc.add(const NextStep());
                      });
                    },
                  ),
                );
              }),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RevenueOptionTile extends StatelessWidget {
  final RevenueOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RevenueOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF10B981) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
