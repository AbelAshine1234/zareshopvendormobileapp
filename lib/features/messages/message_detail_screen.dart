import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/utils/theme/theme_provider.dart';
import '../../shared/utils/theme/app_themes.dart';

class MessageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const MessageDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    // Mock chat messages
    final messages = [
      {
        'text': 'Hello! I saw your coffee products and I\'m interested in placing a bulk order.',
        'time': '9:15 AM',
        'isMe': true,
      },
      {
        'text': 'Good morning! Thank you for reaching out. We\'d be happy to help with your bulk order.',
        'time': '9:18 AM',
        'isMe': false,
      },
      {
        'text': 'Great! I need 500kg of your premium Arabica beans. What\'s your best price?',
        'time': '9:20 AM',
        'isMe': true,
      },
      {
        'text': 'For 500kg of premium Arabica, we can offer ETB 450 per kg. This includes packaging and delivery within Addis Ababa.',
        'time': '9:25 AM',
        'isMe': false,
      },
      {
        'text': 'That\'s a good price. What about the delivery timeline?',
        'time': '9:28 AM',
        'isMe': true,
      },
      {
        'text': 'We can deliver within 3-5 business days after order confirmation. Would you like to proceed?',
        'time': '9:30 AM',
        'isMe': false,
      },
      {
        'text': 'Yes, please send me the quotation and payment details.',
        'time': '9:32 AM',
        'isMe': true,
      },
      {
        'text': 'Perfect! I\'ll prepare the official quotation and send it to you within the next hour. You\'ll receive it via email.',
        'time': '9:35 AM',
        'isMe': false,
      },
      {
        'text': 'Thank you! Looking forward to it.',
        'time': '9:36 AM',
        'isMe': true,
      },
    ];

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.primary.withOpacity(0.2),
              child: Text(
                widget.conversation['avatar'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                top: BorderSide(color: theme.divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.textSecondary),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.inputBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.divider),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: theme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: theme.textHint, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: theme.primary),
                  onPressed: () {
                    // Send message logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, AppThemeData theme) {
    final isMe = message['isMe'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primary.withOpacity(0.2),
              child: Icon(Icons.person, size: 16, color: theme.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? theme.primary : theme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe ? theme.primary : theme.divider,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? Colors.white.withOpacity(0.8) : theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
