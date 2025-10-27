import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';

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
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.divider.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
        // Image section with bookmark icon
        Stack(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  contact['cover_image'] ??
                      contact['profile_image'] ??
                      contact['image'] ??
                      'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to gradient if image fails to load
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade300,
                            Colors.yellow.shade300,
                            Colors.pink.shade300,
                            Colors.red.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  color: theme.surface,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        // Content section
        Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Name with verified badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact['name'] ?? 'Contact Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified,
                        color: theme.surface,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  contact['description'] ?? 'Contact description goes here',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    // Rating
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (contact['rating'] != null &&
                                  contact['rating'] != 'N/A')
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              if (contact['rating'] != null &&
                                  contact['rating'] != 'N/A')
                                const SizedBox(width: 4),
                              Text(
                                contact['rating'] ?? '4.8',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.divider,
                    ),
                    // Contact Info Count
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _getContactInfoCount(contact).toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Info',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Contact Info Section
                Column(
                  children: [
                    // Phone numbers
                    ..._buildPhoneNumbersForContactInfo(contact),
                    
                    // Email
                    if (contact['email']?.isNotEmpty == true)
                      _buildContactItem(
                        Icons.email,
                        Colors.blue,
                        'contacts.email'.tr(),
                        contact['email']!,
                      ),
                    if (contact['email']?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Website
                    if (contact['website']?.isNotEmpty == true)
                      _buildContactItem(
                        Icons.language,
                        Colors.green,
                        'contacts.website'.tr(),
                        contact['website']!,
                      ),
                    if (contact['website']?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Social media links
                    ..._buildSocialMediaForContactInfo(contact),
                  ],
                ),
                const SizedBox(height: 24),
                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onAction('contact', contact),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'contacts.updateInfo'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onAction('delete', contact),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.error,
                          foregroundColor: theme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'contacts.delete'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildSocialMediaItem(IconData icon, Color color, String platform, String link, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$platform - $link',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPhoneNumbersList(Map<String, dynamic> contact) {
    List<Widget> phoneWidgets = [];
    List<String> labels = ['Primary', 'Secondary', 'Additional', 'Emergency'];
    
    for (int i = 1; i <= 4; i++) {
      final phone = contact['phone$i'];
      if (phone != null && phone.isNotEmpty) {
        phoneWidgets.add(
          _buildContactItem(
            Icons.phone,
            Colors.green,
            labels[i - 1],
            '+251 $phone',
          ),
        );
        if (i < 4) phoneWidgets.add(const SizedBox(height: 6));
      }
    }
    
    return phoneWidgets;
  }

  List<Widget> _buildSimplePhoneNumbersList(Map<String, dynamic> contact, AppThemeData theme) {
    List<Widget> phoneWidgets = [];
    bool hasPhoneNumbers = false;
    
    for (int i = 1; i <= 4; i++) {
      final phone = contact['phone$i'];
      if (phone != null && phone.isNotEmpty) {
        hasPhoneNumbers = true;
        break;
      }
    }
    
    if (!hasPhoneNumbers) {
      return phoneWidgets;
    }
    
    phoneWidgets.add(const SizedBox(height: 12));
    phoneWidgets.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1),
      ),
    );
    
    for (int i = 1; i <= 4; i++) {
      final phone = contact['phone$i'];
      if (phone != null && phone.isNotEmpty) {
        phoneWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.phone,
                  color: theme.success,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '+251 $phone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    phoneWidgets.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1),
      ),
    );
    
    return phoneWidgets;
  }

  List<Widget> _buildPhoneNumbersForContactInfo(Map<String, dynamic> contact) {
    List<Widget> phoneWidgets = [];
    List<String> labels = [
      'contacts.primary'.tr(),
      'contacts.secondary'.tr(),
      'contacts.additional'.tr(),
      'contacts.emergency'.tr(),
    ];
    
    for (int i = 1; i <= 4; i++) {
      final phone = contact['phone$i'];
      if (phone != null && phone.isNotEmpty) {
        phoneWidgets.add(
          _buildContactItem(
            Icons.phone,
            Colors.green,
            labels[i - 1],
            '+251 $phone',
          ),
        );
        phoneWidgets.add(const SizedBox(height: 6));
      }
    }
    
    return phoneWidgets;
  }

  List<Widget> _buildSocialMediaForContactInfo(Map<String, dynamic> contact) {
    List<Widget> socialWidgets = [];
    
    // Twitter
    if (contact['twitter_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.alternate_email,
          Colors.blue,
          'contacts.twitter'.tr(),
          contact['twitter_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // Telegram
    if (contact['telegram_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.telegram,
          Colors.blue,
          'contacts.telegram'.tr(),
          contact['telegram_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // Facebook
    if (contact['facebook_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.facebook,
          Colors.blue,
          'contacts.facebook'.tr(),
          contact['facebook_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // YouTube
    if (contact['youtube_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.play_circle_fill,
          Colors.red,
          'contacts.youtube'.tr(),
          contact['youtube_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // Bluesky
    if (contact['bluesky_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.cloud,
          Colors.blue,
          'contacts.bluesky'.tr(),
          contact['bluesky_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // Instagram
    if (contact['instagram_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.camera_alt,
          Colors.pink,
          'contacts.instagram'.tr(),
          contact['instagram_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // LinkedIn
    if (contact['linkedin_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.business,
          Colors.blue,
          'contacts.linkedin'.tr(),
          contact['linkedin_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    // TikTok
    if (contact['tiktok_link']?.isNotEmpty == true) {
      socialWidgets.add(
        _buildContactItem(
          Icons.music_note,
          Colors.black,
          'contacts.tiktok'.tr(),
          contact['tiktok_link']!,
        ),
      );
      socialWidgets.add(const SizedBox(height: 6));
    }
    
    return socialWidgets;
  }

  int _getContactInfoCount(Map<String, dynamic> contact) {
    int count = 0;
    
    // Count phone numbers
    for (int i = 1; i <= 4; i++) {
      if (contact['phone$i']?.isNotEmpty == true) {
        count++;
      }
    }
    
    // Count email
    if (contact['email']?.isNotEmpty == true) {
      count++;
    }
    
    // Count website
    if (contact['website']?.isNotEmpty == true) {
      count++;
    }
    
    // Count social media links
    if (contact['twitter_link']?.isNotEmpty == true) count++;
    if (contact['telegram_link']?.isNotEmpty == true) count++;
    if (contact['facebook_link']?.isNotEmpty == true) count++;
    if (contact['youtube_link']?.isNotEmpty == true) count++;
    if (contact['bluesky_link']?.isNotEmpty == true) count++;
    if (contact['instagram_link']?.isNotEmpty == true) count++;
    if (contact['linkedin_link']?.isNotEmpty == true) count++;
    if (contact['tiktok_link']?.isNotEmpty == true) count++;
    
    return count;
  }

  bool _hasAnySocialMediaLinks(Map<String, dynamic> contact) {
    return (contact['twitter_link']?.isNotEmpty == true) ||
           (contact['telegram_link']?.isNotEmpty == true) ||
           (contact['facebook_link']?.isNotEmpty == true) ||
           (contact['youtube_link']?.isNotEmpty == true) ||
           (contact['bluesky_link']?.isNotEmpty == true) ||
           (contact['instagram_link']?.isNotEmpty == true) ||
           (contact['linkedin_link']?.isNotEmpty == true) ||
           (contact['tiktok_link']?.isNotEmpty == true);
  }
}
