import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../message_detail_screen.dart';

class MessageListItem extends StatelessWidget {
  final Map<String, dynamic> message;
  final AppThemeData theme;

  const MessageListItem({
    super.key,
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailScreen(conversation: message),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(
            bottom: BorderSide(color: theme.divider.withOpacity(0.5), width: 1),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: theme.primary.withOpacity(0.2),
            child: Text(
              message['avatar'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  message['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: message['unread'] ? FontWeight.bold : FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                message['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message['message'],
              style: TextStyle(
                fontSize: 13,
                color: theme.textSecondary,
                fontWeight: message['unread'] ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: message['unread']
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
