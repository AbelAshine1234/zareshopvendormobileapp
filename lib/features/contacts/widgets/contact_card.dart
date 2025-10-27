import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final Function(String, Map<String, dynamic>) onAction;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        final id = contact['id'] as int;
        final type = contact['type'] as String;
        final label = contact['label'] as String? ?? '';
        final value = contact['value'] as String;
        final isPrimary = contact['is_primary'] as bool? ?? false;
        final isVerified = contact['is_verified'] as bool? ?? false;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getContactIcon(type, theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (label.isNotEmpty)
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.primary,
                              ),
                            ),
                          ),
                        if (isPrimary) const SizedBox(width: 8),
                        if (isVerified)
                          Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                        if (isVerified) const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) => onAction(value, contact),
                          itemBuilder: (context) => [
                            if (!isPrimary)
                              const PopupMenuItem(
                                value: 'set_primary',
                                child: Text('Set as Primary'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getContactIcon(String type, AppThemeData theme) {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case 'phone':
        iconData = Icons.phone;
        iconColor = Colors.green;
        break;
      case 'email':
        iconData = Icons.email;
        iconColor = Colors.blue;
        break;
      case 'website':
        iconData = Icons.language;
        iconColor = Colors.purple;
        break;
      case 'social_media':
        iconData = Icons.share;
        iconColor = Colors.orange;
        break;
      case 'address':
        iconData = Icons.location_on;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.contact_support;
        iconColor = theme.textSecondary;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
