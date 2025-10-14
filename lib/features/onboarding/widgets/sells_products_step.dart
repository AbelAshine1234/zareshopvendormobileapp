import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class SellsProductsStep extends StatelessWidget {
  const SellsProductsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingInProgress) {
          final selectedValue = state.data.sellsProductsOnline;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do you sell products online?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: 'Yes',
                      isSelected: selectedValue == true,
                      onTap: () {
                        final bloc = context.read<OnboardingBloc>();
                        bloc.add(const UpdateSellsProductsOnline(true));
                        // Auto-advance to next step after a brief delay
                        Future.delayed(const Duration(milliseconds: 400), () {
                          bloc.add(const NextStep());
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChoiceButton(
                      label: 'No',
                      isSelected: selectedValue == false,
                      onTap: () {
                        final bloc = context.read<OnboardingBloc>();
                        bloc.add(const UpdateSellsProductsOnline(false));
                        // Auto-advance to next step after a brief delay
                        Future.delayed(const Duration(milliseconds: 400), () {
                          bloc.add(const NextStep());
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }
}
