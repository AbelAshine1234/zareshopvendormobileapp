import 'package:flutter/material.dart';
import '../../utils/theme/app_themes.dart';

class InlineErrorBanner extends StatelessWidget {
  final AppThemeData theme;
  final String message;

  const InlineErrorBanner({
    super.key,
    required this.theme,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.error.withOpacity(0.08),
        border: Border.all(color: theme.error.withOpacity(0.35), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


