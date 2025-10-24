import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';
import 'notification_detail_screen.dart';

class NotificationsTab extends StatelessWidget {
  final AppThemeData theme;

  const NotificationsTab({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Fake notifications data
    final notifications = [
      {
        'title': 'Order Shipped',
        'message': 'Your order #ORD-12345 has been shipped and is on the way.',
        'time': '2 hours ago',
        'icon': Icons.local_shipping,
        'iconColor': Colors.blue,
        'unread': true,
      },
      {
        'title': 'Payment Confirmed',
        'message': 'Payment of ETB 8,500.00 has been confirmed for order #ORD-12344.',
        'time': '5 hours ago',
        'icon': Icons.check_circle,
        'iconColor': Colors.green,
        'unread': true,
      },
      {
        'title': 'New Message',
        'message': 'Ethiopian Coffee Co. sent you a message about your quotation.',
        'time': 'Yesterday',
        'icon': Icons.message,
        'iconColor': Colors.orange,
        'unread': false,
      },
      {
        'title': 'Price Drop Alert',
        'message': 'Wireless Headphones price dropped to ETB 1,000 per unit!',
        'time': '2 days ago',
        'icon': Icons.trending_down,
        'iconColor': Colors.red,
        'unread': false,
      },
      {
        'title': 'Order Delivered',
        'message': 'Your order #ORD-12343 has been successfully delivered.',
        'time': '3 days ago',
        'icon': Icons.done_all,
        'iconColor': Colors.green,
        'unread': false,
      },
    ];

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 80,
              color: theme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, theme);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, AppThemeData theme) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NotificationDetailScreen(notification: notification),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notification['iconColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              notification['icon'] as IconData,
              size: 24,
              color: notification['iconColor'] as Color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification['unread'] 
                              ? FontWeight.bold 
                              : FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    if (notification['unread'])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: theme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
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
      ),
    );
  }
}
