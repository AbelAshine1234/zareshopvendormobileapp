import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/utils/theme/theme_provider.dart';
import '../../shared/utils/theme/app_themes.dart';
import '../../core/services/localization_service.dart';
import 'message_detail_screen.dart';
import '../orders/screens/orders_tab.dart';
import '../notifications/screens/notifications_tab.dart';
import 'widgets/widgets.dart';

class MessagesScreen extends StatefulWidget {
  final int? initialTab;
  
  const MessagesScreen({super.key, this.initialTab});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _selectedTab = widget.initialTab ?? 0;
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'Messenger',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(theme),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Tabs Section
          Container(
            color: theme.background,
            child: Row(
              children: [
                MessageTabItem(
                  icon: Icons.message_outlined,
                  label: 'Direct Messages',
                  index: 0,
                  selectedTab: _selectedTab,
                  theme: theme,
                  badge: 3,
                  onTap: () => _tabController.animateTo(0),
                ),
                MessageTabItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  index: 1,
                  selectedTab: _selectedTab,
                  theme: theme,
                  badge: 0,
                  onTap: () => _tabController.animateTo(1),
                ),
                MessageTabItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  index: 2,
                  selectedTab: _selectedTab,
                  theme: theme,
                  badge: 2,
                  onTap: () => _tabController.animateTo(2),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.divider),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(color: theme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search messages or suppliers',
                  hintStyle: TextStyle(color: theme.textHint, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: theme.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Unread', theme, true),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Sessions Found
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 sessions found for you',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Reset filter',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tab Content
          Expanded(
            child: _selectedTab == 0
                ? _buildMessagesList(theme)
                : _selectedTab == 1
                    ? OrdersTab(theme: theme)
                    : NotificationsTab(theme: theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required AppThemeData theme,
    int badge = 0,
  }) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected ? theme.primary : theme.textSecondary,
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? theme.primary : theme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AppThemeData theme, bool isSelected, {bool hasDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? theme.primary.withOpacity(0.1) : theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? theme.primary : theme.divider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? theme.primary : theme.textPrimary,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isSelected ? theme.primary : theme.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesList(AppThemeData theme) {
    // Fake messages data
    final messages = [
      {
        'name': 'Ethiopian Coffee Co.',
        'message': 'Thank you for your order! We will ship it soon.',
        'time': '2:30 PM',
        'unread': true,
        'avatar': 'EC',
      },
      {
        'name': 'Tech Solutions Ltd',
        'message': 'Your quotation request has been received.',
        'time': '1:15 PM',
        'unread': true,
        'avatar': 'TS',
      },
      {
        'name': 'Eco Fashion Hub',
        'message': 'New products available in your category!',
        'time': 'Yesterday',
        'unread': false,
        'avatar': 'EF',
      },
      {
        'name': 'Office Solutions Pro',
        'message': 'Payment confirmed. Order #12345',
        'time': 'Yesterday',
        'unread': false,
        'avatar': 'OS',
      },
      {
        'name': 'Green Living Store',
        'message': 'Your items are ready for pickup',
        'time': '2 days ago',
        'unread': false,
        'avatar': 'GL',
      },
    ];

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 80,
              color: theme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with suppliers',
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageListItem(message: message, theme: theme);
      },
    );
  }

  Widget _buildLanguageSelector(AppThemeData theme) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.language_outlined, color: theme.textPrimary, size: 22),
              onPressed: () {
                final RenderBox button = context.findRenderObject() as RenderBox;
                _showLanguageMenu(context, themeProvider, button);
              },
            );
          },
        );
      },
    );
  }

  void _showLanguageMenu(BuildContext context, ThemeProvider themeProvider, RenderBox button) {
    final currentLanguage = LocalizationService.instance.currentLanguage;
    final buttonPosition = button.localToGlobal(Offset.zero);
    final buttonSize = button.size;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + 200,
        buttonPosition.dy,
      ),
      items: LocalizationService.instance.supportedLanguages.map((lang) {
        final isSelected = lang['code'] == currentLanguage;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(
            children: [
              Icon(
                Icons.language_outlined,
                size: 20,
                color: isSelected ? themeProvider.currentTheme.primary : themeProvider.currentTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                lang['name']!,
                style: TextStyle(
                  color: isSelected ? themeProvider.currentTheme.primary : themeProvider.currentTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: themeProvider.currentTheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedCode) {
      if (selectedCode != null) {
        LocalizationService.instance.loadLanguage(selectedCode);
      }
    });
  }
}
