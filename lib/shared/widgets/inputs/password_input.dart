import 'package:flutter/material.dart';
import '../../utils/theme/app_themes.dart';

class PasswordInput extends StatelessWidget {
  final AppThemeData theme;
  final TextEditingController? controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const PasswordInput({
    super.key,
    required this.theme,
    this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.inputBackground,
        border: Border.all(
          color: theme.inputBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.lock_outline, color: theme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                hintStyle: TextStyle(
                  color: theme.textHint,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: theme.textSecondary,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


