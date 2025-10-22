import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme/app_themes.dart';

class PhoneInput extends StatelessWidget {
  final AppThemeData theme;
  final TextEditingController? controller;
  final ValueChanged<String>? onChangedDigitsOnly;
  final String? errorText;
  final String countryCode; // e.g., "+251"
  final String hintDigits; // e.g., "912345678"
  final String? label;
  final String? helperText;
  final bool showErrorIcon;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const PhoneInput({
    super.key,
    required this.theme,
    this.controller,
    this.onChangedDigitsOnly,
    this.errorText,
    this.countryCode = '+251',
    this.hintDigits = '912345678',
    this.label,
    this.helperText,
    this.showErrorIcon = true,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (label != null) ...[
            Text(
              label!,
              style: AppThemes.titleLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
          ],
          
          // Phone input container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: enabled ? theme.inputBackground : theme.inputBackground.withOpacity(0.5),
              border: Border.all(
                color: errorText != null ? theme.error : theme.inputBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            'https://flagcdn.com/w40/et.png',
                            width: 28,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.surface,
                                child: const Center(
                                  child: Text(
                                    'ET',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        countryCode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: enabled ? theme.labelText : theme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.divider,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChangedDigitsOnly,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    enabled: enabled,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: InputDecoration(
                      hintText: hintDigits,
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintStyle: TextStyle(
                        color: theme.textHint,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: enabled ? theme.textPrimary : theme.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Error message
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (showErrorIcon) ...[
                    Icon(
                      Icons.error_outline,
                      color: theme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      errorText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Helper text
          if (helperText != null && errorText == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                helperText!,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


