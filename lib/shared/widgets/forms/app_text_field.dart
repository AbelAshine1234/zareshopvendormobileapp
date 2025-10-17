import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_themes.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool required;
  final bool enabled;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.obscureText = false,
    this.required = false,
    this.enabled = true,
    this.controller,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? 
        TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            RichText(
              text: TextSpan(
                text: widget.label,
                style: AppThemes.labelLarge(theme),
                children: widget.required
                    ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: theme.error),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: AppThemes.spaceS),
            
            // Text Field
            TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              obscureText: widget.obscureText,
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              style: AppThemes.bodyLarge(theme),
              decoration: AppThemes.inputDecoration(
                theme,
                hintText: widget.hint,
                errorText: _errorText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Specialized text fields
class AppEmailField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final String? initialValue;
  final bool required;
  final bool enabled;
  final TextEditingController? controller;

  const AppEmailField({
    super.key,
    this.label = 'Email Address',
    required this.onChanged,
    this.initialValue,
    this.required = true,
    this.enabled = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: 'your@email.com',
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      initialValue: initialValue,
      required: required,
      enabled: enabled,
      controller: controller,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Email is required';
        }
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }
}

class AppPhoneField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final String? initialValue;
  final bool required;
  final bool enabled;
  final TextEditingController? controller;

  const AppPhoneField({
    super.key,
    this.label = 'Phone Number',
    required this.onChanged,
    this.initialValue,
    this.required = true,
    this.enabled = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: '912345678',
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      initialValue: initialValue,
      required: required,
      enabled: enabled,
      controller: controller,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Phone number is required';
        }
        if (value != null && value.isNotEmpty && value.length != 9) {
          return 'Phone number must be 9 digits';
        }
        return null;
      },
    );
  }
}

class AppPasswordField extends StatefulWidget {
  final String label;
  final Function(String) onChanged;
  final String? initialValue;
  final bool required;
  final bool enabled;
  final TextEditingController? controller;

  const AppPasswordField({
    super.key,
    this.label = 'Password',
    required this.onChanged,
    this.initialValue,
    this.required = true,
    this.enabled = true,
    this.controller,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: 'Enter your password',
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,
      required: widget.required,
      enabled: widget.enabled,
      controller: widget.controller,
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      validator: (value) {
        if (widget.required && (value == null || value.isEmpty)) {
          return 'Password is required';
        }
        if (value != null && value.isNotEmpty) {
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
            return 'Password must contain uppercase, lowercase, and number';
          }
        }
        return null;
      },
    );
  }
}

class AppSearchField extends StatelessWidget {
  final String hint;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    this.hint = 'Search...',
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTheme.bodyMedium,
      decoration: AppTheme.inputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: onClear != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
