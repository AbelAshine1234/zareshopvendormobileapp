import 'package:flutter/material.dart';

class VendorTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const VendorTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: _AnimatedVendorTypeCard(
                label: 'Individual Vendor',
                value: 'individual',
                icon: Icons.person,
                isSelected: selectedType == 'individual',
                onTap: () => onTypeSelected('individual'),
                animationDelay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AnimatedVendorTypeCard(
                label: 'Business Vendor',
                value: 'business',
                icon: Icons.business,
                isSelected: selectedType == 'business',
                onTap: () => onTypeSelected('business'),
                animationDelay: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedVendorTypeCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int animationDelay;

  const _AnimatedVendorTypeCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + animationDelay),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: onTap,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.8, end: isSelected ? 1.0 : 0.8),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            icon,
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF6B7280),
                            size: 40,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF374151),
                        height: 1.4,
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
  }
}
