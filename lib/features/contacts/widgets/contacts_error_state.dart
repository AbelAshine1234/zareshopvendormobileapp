import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ContactsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
