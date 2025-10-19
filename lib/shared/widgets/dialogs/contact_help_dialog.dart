import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class ContactHelpDialog extends StatelessWidget {
  final AppThemeData theme;

  const ContactHelpDialog({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Contact Support',
        style: AppThemes.titleLarge(theme),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Need help? We\'re here to assist you!',
              style: AppThemes.bodyLarge(theme),
            ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Inbox to Admin
            _buildContactOption(
              context,
              'Send Message to Admin',
              'You will be notified by phone number',
              Icons.inbox,
              theme.primary,
              () => _showInboxDialog(context),
            ),
            
            const SizedBox(height: AppThemes.spaceM),
            
            // Phone Number
            _buildContactOption(
              context,
              'Call ZareShop',
              '+251 11 123 4567',
              Icons.phone,
              theme.success,
              () => _makePhoneCall('+251111234567'),
            ),
            
            const SizedBox(height: AppThemes.spaceM),
            
            // Email
            _buildContactOption(
              context,
              'Email Support',
              'support@zareshop.com',
              Icons.email,
              theme.info,
              () => _sendEmail('support@zareshop.com'),
            ),
            
            const SizedBox(height: AppThemes.spaceL),
            
            // Additional Info
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: theme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: theme.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppThemes.spaceM),
                  Expanded(
                    child: Text(
                      'We will respond within 4 hours. Our support team is available Monday to Friday, 9 AM to 6 PM EAT',
                      style: AppThemes.bodySmall(theme).copyWith(
                        color: theme.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: theme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemes.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppThemes.spaceM),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppThemes.borderRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppThemes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppThemes.titleMedium(theme).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXS),
                  Text(
                    subtitle,
                    style: AppThemes.bodySmall(theme).copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showInboxDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _InboxDialog(theme: theme);
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // TODO: Implement phone call functionality
    // For now, just show a message
    print('Making phone call to: $phoneNumber');
  }

  Future<void> _sendEmail(String email) async {
    // TODO: Implement email functionality
    // For now, just show a message
    print('Sending email to: $email');
  }

  static void show(BuildContext context, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContactHelpDialog(theme: theme);
      },
    );
  }
}

class _InboxDialog extends StatefulWidget {
  final AppThemeData theme;

  const _InboxDialog({required this.theme});

  @override
  State<_InboxDialog> createState() => _InboxDialogState();
}

class _InboxDialogState extends State<_InboxDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Send Message to Admin',
        style: AppThemes.titleLarge(widget.theme),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send a message directly to our admin team. You will be notified by phone number.',
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceL),
            
            // Subject Field
            Text(
              'Subject',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _subjectController,
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'Brief description of your issue',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Message Field
            Text(
              'Message',
              style: AppThemes.titleMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceS),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: AppThemes.inputDecoration(
                widget.theme,
                hintText: 'Describe your issue or question in detail...',
              ),
              style: AppThemes.bodyMedium(widget.theme),
            ),
            const SizedBox(height: AppThemes.spaceM),
            
            // Info
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceM),
              decoration: BoxDecoration(
                color: widget.theme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                border: Border.all(
                  color: widget.theme.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.theme.info,
                    size: 16,
                  ),
                  const SizedBox(width: AppThemes.spaceS),
                  Expanded(
                    child: Text(
                      'We will respond within 4 hours and notify you by phone number',
                      style: AppThemes.bodySmall(widget.theme).copyWith(
                        color: widget.theme.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: widget.theme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_subjectController.text.isNotEmpty && 
                _messageController.text.isNotEmpty) {
              // TODO: Implement actual message sending
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Message sent successfully!'),
                  backgroundColor: widget.theme.success,
                ),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close both dialogs
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please fill in all fields'),
                  backgroundColor: widget.theme.error,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 40),
          ),
          child: const Text('Send Message'),
        ),
      ],
    );
  }
}
