import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactsEmptyState extends StatelessWidget {
  final VoidCallback onAddContact;

  const ContactsEmptyState({
    super.key,
    required this.onAddContact,
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
                Icons.contact_support_outlined,
                size: 64,
                color: theme.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No contacts found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first contact to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddContact,
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
