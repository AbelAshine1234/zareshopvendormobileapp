import 'package:flutter/material.dart';

class AnimatedCheckboxItem extends StatefulWidget {
  final String text;
  final bool value;
  final Function(bool?) onChanged;
  final String? linkText;
  final VoidCallback? onLinkTap;

  const AnimatedCheckboxItem({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    this.linkText,
    this.onLinkTap,
  });

  @override
  State<AnimatedCheckboxItem> createState() => _AnimatedCheckboxItemState();
}

class _AnimatedCheckboxItemState extends State<AnimatedCheckboxItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onChanged(!widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: widget.value ? 1.0 : 0.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Checkbox(
                        value: widget.value,
                        onChanged: widget.onChanged,
                        activeColor: const Color(0xFF22C55E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          height: 1.5,
                        ),
                      ),
                      if (widget.linkText != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: widget.onLinkTap,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(5 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    widget.linkText!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF22C55E),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
