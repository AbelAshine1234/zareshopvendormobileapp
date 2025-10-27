import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactFilterChips extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const ContactFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const Map<String, String> typeLabels = {
    'all': 'All Contacts',
    'phone': 'Phone Numbers',
    'email': 'Email Addresses',
    'website': 'Websites',
    'social_media': 'Social Media',
    'address': 'Addresses',
    'other': 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: typeLabels.length,
            itemBuilder: (context, index) {
              final type = typeLabels.keys.elementAt(index);
              final label = typeLabels[type]!;
              final isSelected = selectedType == type;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) => onTypeChanged(type),
                  backgroundColor: theme.surface,
                  selectedColor: theme.primary.withOpacity(0.2),
                  checkmarkColor: theme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.primary : theme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
