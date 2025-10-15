import 'package:flutter/material.dart';

class AnimatedPaymentMethodCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int animationDelay;

  const AnimatedPaymentMethodCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedPaymentMethodCard> createState() =>
      _AnimatedPaymentMethodCardState();
}

class _AnimatedPaymentMethodCardState extends State<AnimatedPaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + widget.animationDelay),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final slideOffset = widget.animationDelay == 0
            ? Offset(-20 * (1 - value), 0)
            : Offset(20 * (1 - value), 0);
        
        return Transform.translate(
          offset: slideOffset,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_controller.value * 0.05),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? const Color(0xFFBBF7D0)
                            : Colors.white,
                        border: Border.all(
                          color: widget.isSelected
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFD1D5DB),
                          width: widget.isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.3),
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
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(
                                begin: 0.0, end: widget.isSelected ? 1.0 : 0.5),
                            curve: Curves.easeOutBack,
                            builder: (context, iconValue, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * iconValue),
                                child: Icon(
                                  widget.icon,
                                  color: widget.isSelected
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF6B7280),
                                  size: 36,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.isSelected
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF374151),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class PaymentMethodsList extends StatelessWidget {
  final bool isBank;
  final String bankAccountNumber;
  final String mobileWalletNumber;

  const PaymentMethodsList({
    super.key,
    required this.isBank,
    required this.bankAccountNumber,
    required this.mobileWalletNumber,
  });

  String getBankAccountDisplay(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    return '****** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isBank)
                    PaymentMethodItem(
                      icon: Icons.account_balance,
                      title: 'Bank Account',
                      subtitle: getBankAccountDisplay(bankAccountNumber),
                      isVerified: true,
                    )
                  else
                    PaymentMethodItem(
                      icon: Icons.phone_android,
                      title: 'Mobile Wallet Telebirr',
                      subtitle: mobileWalletNumber,
                      isVerified: true,
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

class PaymentMethodItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isVerified;

  const PaymentMethodItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
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
              );
            },
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
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                );
              },
            ),
        ],
      ),
    );
  }
}
