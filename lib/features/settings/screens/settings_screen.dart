import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/selectors/language_switcher_button.dart';
import '../../../shared/widgets/selectors/theme_selector_button.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/common/app_widgets.dart';
import '../../../shared/widgets/common/global_loader.dart';
import '../bloc/vendor_info_bloc.dart';
import '../bloc/vendor_info_event.dart';
import '../bloc/vendor_info_state.dart';
import '../bloc/vendor_update_bloc.dart';
import '../bloc/vendor_update_event.dart';
import '../bloc/vendor_update_state.dart';
import '../../contacts/screens/contacts_screen.dart';
import '../../contacts/contacts_service.dart';
import '../../addresses/screens/addresses_screen.dart';
import '../../change_password/change_password.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../wallet_management/screens/wallet_management_screen.dart';
import '../../exhibition_pics/screens/exhibition_pics_screen.dart';
import '../../certificates/screens/certificates_screen.dart';
import '../../collaborators/screens/collaborators_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // Load vendor info when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorInfoBloc>().add(LoadVendorInfo());
    });
    
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to splash screen when user is logged out
            // Use go_router to navigate and clear navigation stack
            context.go('/splash');
          }
        },
        child: BlocListener<VendorUpdateBloc, VendorUpdateState>(
          listener: (context, state) {
          if (state is VendorUpdateLoading) {
            GlobalLoader.show(
              context,
              message: 'Updating cover image...',
            );
          } else if (state is VendorUpdatePolling) {
            GlobalLoader.show(
              context,
              message: 'Processing image...',
            );
          } else if (state is VendorUpdateSuccess) {
            GlobalLoader.hide(context);
            GlobalSnackBar.showSuccess(
              context: context,
              message: 'Cover image updated successfully!',
            );
            // Refresh vendor info to show updated image
            context.read<VendorInfoBloc>().add(LoadVendorInfo());
          } else if (state is VendorUpdateError) {
            GlobalLoader.hide(context);
            GlobalSnackBar.showError(
              context: context,
              message: 'Failed to update cover image: ${state.message}',
            );
          } else if (state is VendorUpdatePollingTimeout) {
            GlobalLoader.hide(context);
            GlobalSnackBar.showError(
              context: context,
              message: 'Image processing is taking longer than expected. Please try again.',
            );
          }
        },
        child: Builder(
          builder: (context) => Consumer2<LocalizationService, ThemeProvider>(
            builder: (context, localization, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              
              return Scaffold(
                backgroundColor: theme.background,
                appBar: AppBar(
                  backgroundColor: theme.surface,
                  elevation: 0,
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    _buildLanguageSelector(theme, themeProvider),
                    const SizedBox(width: 8),
                  ],
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildWalletBalance(theme),
                        const SizedBox(height: 24),
                        ..._buildAllSections(localization, theme),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppThemeData theme, VendorInfoState vendorInfoState, VendorUpdateState updateState) {
    String storeName = 'Loading...';
    String? coverImageUrl;
    String statusText = 'Loading...';
    Color statusColor = Colors.grey[600]!;
    Color statusBgColor = Colors.grey[100]!;
    bool isLoading = false; // Loading is now handled by GlobalLoader
    bool isVendorInfoLoading = vendorInfoState is VendorInfoLoading;
    
    if (vendorInfoState is VendorInfoLoaded) {
      final vendorData = vendorInfoState.vendorInfo['vendor'];
      if (vendorData != null) {
        // Get business name from API
        storeName = vendorData['name'] ?? 'Name is not available';
        
        // Get cover image URL
        final images = vendorData['images'];
        if (images != null && images['cover'] != null) {
          coverImageUrl = images['cover']['image_url'];
        }
        
        // Get status
        final isApproved = vendorData['isApproved'] ?? false;
        final status = vendorData['status'] ?? true;
        
        if (isApproved && status) {
          statusText = 'Verified Store';
          statusColor = Colors.blue[800]!;
          statusBgColor = Colors.blue[100]!;
        } else if (!isApproved) {
          statusText = 'Pending Verification';
          statusColor = Colors.orange[800]!;
          statusBgColor = Colors.orange[100]!;
        } else {
          statusText = 'Inactive';
          statusColor = Colors.red[800]!;
          statusBgColor = Colors.red[100]!;
        }
      }
    }
    
        return Container(
          padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: isVendorInfoLoading
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    )
                  : coverImageUrl != null
                      ? Image.network(
                          coverImageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.business, size: 50, color: Colors.grey[600]);
                          },
                        )
                      : Icon(Icons.business, size: 50, color: Colors.grey[600]),
            ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (!isLoading && !isVendorInfoLoading) {
                        GlobalImagePicker.showImageSourceDialog(
                          context: context,
                          onImageSelected: (image) => _showImageConfirmationDialog(image),
                        );
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (isLoading || isVendorInfoLoading) ? Colors.grey[400] : Colors.blue[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isVendorInfoLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              : Text(
                  storeName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 8),
          isVendorInfoLoading
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: statusColor),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: statusColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: statusColor),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWalletBalance(AppThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: theme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ETB 2,500.00',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _navigateToWalletManagement,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Wallet Management',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllSections(LocalizationService localization, AppThemeData theme) {
    final sections = [
      {
        'title': 'settings.account.title',
        'items': [
          {'icon': Icons.person_outline, 'title': 'settings.account.profileInfo', 'subtitle': 'settings.account.profileInfoDesc', 'onTap': _navigateToProfileInfo},
          {'icon': Icons.contact_mail_outlined, 'title': 'settings.account.contactInfo', 'subtitle': 'settings.account.contactInfoDesc', 'onTap': _navigateToContacts},
          {'icon': Icons.location_on_outlined, 'title': 'settings.account.addressManagement', 'subtitle': 'settings.account.addressManagementDesc', 'onTap': _navigateToAddresses},
        ]
      },
      {
        'title': 'settings.business.title',
        'items': [
          {'icon': Icons.photo_library_outlined, 'title': 'settings.business.exhibitionPics', 'subtitle': 'settings.business.exhibitionPicsDesc', 'onTap': _navigateToExhibitionPics},
          {'icon': Icons.workspace_premium_outlined, 'title': 'settings.business.certificates', 'subtitle': 'settings.business.certificatesDesc', 'onTap': _navigateToCertificates},
          {'icon': Icons.people_outline, 'title': 'settings.business.collaborators', 'subtitle': 'settings.business.collaboratorsDesc', 'onTap': _navigateToCollaborators},
        ]
      },
      {
        'title': 'settings.auth.title',
        'items': [
          {'icon': Icons.lock_outline, 'title': 'settings.auth.changePassword', 'subtitle': 'settings.auth.changePasswordDesc', 'onTap': _navigateToChangePassword},
        ]
      },
      {
        'title': 'settings.payment.title',
        'items': [
          {'icon': Icons.account_balance_wallet_outlined, 'title': 'settings.payment.walletManagement', 'subtitle': 'settings.payment.walletManagementDesc', 'onTap': _navigateToWalletManagement},
        ]
      },
      {
        'title': 'settings.orders.title',
        'items': [
          {'icon': Icons.notifications_active_outlined, 'title': 'settings.orders.pushNotifications', 'subtitle': 'settings.orders.pushNotificationsDesc', 'trailing': Switch(value: _notificationsEnabled, onChanged: (v) => setState(() => _notificationsEnabled = v))},
          {'icon': Icons.sms_outlined, 'title': 'settings.orders.smsNotifications', 'subtitle': 'settings.orders.smsNotificationsDesc'},
        ]
      },
      {
        'title': 'settings.products.title',
        'items': [
          {'icon': Icons.category_outlined, 'title': 'settings.products.defaultCategories', 'subtitle': 'settings.products.defaultCategoriesDesc'},
          {'icon': Icons.discount_outlined, 'title': 'settings.products.discountDefaults', 'subtitle': 'settings.products.discountDefaultsDesc'},
        ]
      },
      {
        'title': 'settings.analytics.title',
        'items': [
          {'icon': Icons.star_outline, 'title': 'settings.analytics.vendorPerformance', 'subtitle': 'settings.analytics.vendorPerformanceDesc'},
          {'icon': Icons.file_download_outlined, 'title': 'settings.analytics.exportReports', 'subtitle': 'settings.analytics.exportReportsDesc'},
        ]
      },
      {
        'title': 'settings.subscription.title',
        'items': [
          {'icon': Icons.credit_card_outlined, 'title': 'settings.subscription.currentPlan', 'subtitle': 'settings.subscription.currentPlanDesc'},
          {'icon': Icons.upgrade_outlined, 'title': 'settings.subscription.upgradePlan', 'subtitle': 'settings.subscription.upgradePlanDesc'},
          {'icon': Icons.history, 'title': 'settings.subscription.paymentHistory', 'subtitle': 'settings.subscription.paymentHistoryDesc'},
          {'icon': Icons.notifications_outlined, 'title': 'settings.subscription.renewalAlerts', 'subtitle': 'settings.subscription.renewalAlertsDesc'},
        ]
      },
      {
        'title': 'settings.help.title',
        'items': [
          {'icon': Icons.quiz_outlined, 'title': 'settings.help.faq', 'subtitle': 'settings.help.faqDesc'},
          {'icon': Icons.support_agent_outlined, 'title': 'settings.help.supportTickets', 'subtitle': 'settings.help.supportTicketsDesc'},
          {'icon': Icons.chat_outlined, 'title': 'settings.help.contactSupport', 'subtitle': 'settings.help.contactSupportDesc'},
          {'icon': Icons.feedback_outlined, 'title': 'settings.help.feedback', 'subtitle': 'settings.help.feedbackDesc'},
        ]
      },
      {
        'title': 'settings.security.title',
        'items': [
          {'icon': Icons.logout_outlined, 'title': 'settings.security.logout', 'subtitle': 'settings.security.logoutDesc', 'onTap': _showLogoutDialog},
          {'icon': Icons.download_outlined, 'title': 'settings.security.dataExport', 'subtitle': 'settings.security.dataExportDesc'},
          {'icon': Icons.info_outline, 'title': 'settings.security.appVersion', 'subtitle': 'settings.security.appVersionDesc'},
        ]
      },
    ];

    return sections.map((section) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            localization.translate(section['title'] as String),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        ...(section['items'] as List).map((item) => _buildMenuItem(item, localization, theme)).toList(),
        const SizedBox(height: 24),
      ],
    )).toList();
  }

  Widget _buildMenuItem(Map<String, dynamic> item, LocalizationService localization, AppThemeData theme) {
    return Material(
      color: theme.background,
      child: InkWell(
        onTap: item['onTap'] as VoidCallback?,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(8)),
                child: Icon(item['icon'] as IconData, color: theme.textSecondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.translate(item['title'] as String),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: theme.textPrimary),
                    ),
                      const SizedBox(height: 4),
                      Text(
                      localization.translate(item['subtitle'] as String),
                      style: TextStyle(fontSize: 13, color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
              item['trailing'] as Widget? ?? Icon(Icons.chevron_right, color: theme.textHint),
            ],
          ),
        ),
      ),
    );
  }


  void _showImageConfirmationDialog(XFile image) {
    GlobalDialog.showImageUpdateConfirmation(
      context: context,
      image: image,
    ).then((confirmed) {
      if (confirmed == true) {
        _updateCoverImage(image.path);
      }
    });
  }


  void _updateCoverImage(String imagePath) {
    try {
      final vendorUpdateBloc = context.read<VendorUpdateBloc>();
      vendorUpdateBloc.add(UpdateVendorCoverImage(imagePath: imagePath));
    } catch (e) {
      GlobalSnackBar.showError(
        context: context,
        message: 'Unable to update image - $e',
      );
    }
  }


  void _navigateToContacts() {
    // You can also use the global contacts service from anywhere:
    // ContactsService.loadContacts(); // Load all contacts
    // ContactsService.createContact(...); // Create a contact
    // etc.
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactsScreen(),
      ),
    );
  }

  void _navigateToAddresses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressesScreen(),
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  void _navigateToWalletManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletManagementScreen(
          isVendor: true,
        ),
      ),
    );
  }

  void _navigateToProfileInfo() {
    // Navigate to profile info screen with full vendor details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProfileInfoScreen(),
      ),
    );
  }

  void _navigateToExhibitionPics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExhibitionPicsScreen(),
      ),
    );
  }

  void _navigateToCertificates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CertificatesScreen(),
      ),
    );
  }

  void _navigateToCollaborators() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollaboratorsScreen(),
      ),
    );
  }



  Widget _buildLanguageSelector(AppThemeData theme, ThemeProvider themeProvider) {
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

  void _showLogoutDialog() {
    GlobalDialog.showLogoutConfirmation(context: context).then((confirmed) {
      if (confirmed == true) {
        // Trigger logout through AuthBloc
        context.read<AuthBloc>().add(const LogoutRequested());
      }
    });
  }
}

// Profile Info Screen with full vendor details and edit capability
class _ProfileInfoScreen extends StatefulWidget {
  @override
  State<_ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<_ProfileInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEditing = true;
  String? _videoPath;
  String? _coverImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Information',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(theme, themeProvider),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<VendorInfoBloc, VendorInfoState>(
        builder: (context, vendorInfoState) {
          return BlocBuilder<VendorUpdateBloc, VendorUpdateState>(
            builder: (context, updateState) {
              return _buildProfileContent(theme, vendorInfoState, updateState);
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(AppThemeData theme, VendorInfoState vendorInfoState, VendorUpdateState updateState) {
    String storeName = 'Loading...';
    String? coverImageUrl;
    String statusText = 'Loading...';
    Color statusColor = Colors.grey[600]!;
    Color statusBgColor = Colors.grey[100]!;
    bool isVendorInfoLoading = vendorInfoState is VendorInfoLoading;
    
    if (vendorInfoState is VendorInfoLoaded) {
      final vendorData = vendorInfoState.vendorInfo['vendor'];
      if (vendorData != null) {
        storeName = vendorData['name'] ?? 'Name is not available';
        _nameController.text = storeName;
        _emailController.text = vendorData['email'] ?? 'email@example.com';
        _phoneController.text = vendorData['phone'] ?? '+251 9XX XXX XXX';
        _descriptionController.text = vendorData['description'] ?? 'No description available';
        
        final images = vendorData['images'];
        if (images != null && images['cover'] != null) {
          coverImageUrl = images['cover']['image_url'];
        }
        final isApproved = vendorData['isApproved'] ?? false;
        final status = vendorData['status'] ?? true;
        
        if (isApproved && status) {
          statusText = 'Verified Store';
          statusColor = Colors.blue[800]!;
          statusBgColor = Colors.blue[100]!;
        } else if (!isApproved) {
          statusText = 'Pending Verification';
          statusColor = Colors.orange[800]!;
          statusBgColor = Colors.orange[100]!;
        } else {
          statusText = 'Inactive';
          statusColor = Colors.red[800]!;
          statusBgColor = Colors.red[100]!;
        }
      }
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cover Image - Wide Rectangle
          Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.divider.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isVendorInfoLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : _coverImagePath != null
                          ? Image.file(
                              File(_coverImagePath!),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : coverImageUrl != null
                              ? Image.network(
                                  coverImageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.store, size: 80, color: Colors.grey[600]),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(Icons.store, size: 80, color: Colors.grey[600]),
                                ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Row(
                    children: [
                      if (_coverImagePath != null || coverImageUrl != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: _deleteCoverImage,
                            child: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                          ),
                        ),
                      if (_coverImagePath != null || coverImageUrl != null) const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: _pickCoverImage,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                
                // Video Section
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.inputBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.divider.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Video placeholder or actual video
                      Center(
                        child: _videoPath != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 64,
                                    color: theme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Video Selected',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      _videoPath!.split('/').last,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_outlined,
                                    size: 64,
                                    color: theme.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Business Video',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'No video uploaded',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textSecondary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      // Action buttons
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Row(
                          children: [
                            if (_videoPath != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  onTap: _deleteVideo,
                                  child: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                ),
                              ),
                            if (_videoPath != null) const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: _pickVideo,
                                child: Icon(Icons.videocam, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
          
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: statusColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Profile Fields
                _buildProfileField(
                  theme: theme,
                  label: 'Business Name',
                  controller: _nameController,
                  icon: Icons.store_outlined,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  theme: theme,
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  theme: theme,
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  theme: theme,
                  label: 'Description',
                  controller: _descriptionController,
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement save profile functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2), // Max 2 minutes
      );
      
      if (video != null) {
        setState(() {
          _videoPath = video.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video selected: ${video.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Video'),
        content: Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _videoPath = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _coverImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cover image selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCoverImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Cover Image'),
        content: Text('Are you sure you want to delete the cover image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _coverImagePath = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cover image deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required AppThemeData theme,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.labelText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.inputBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: controller,
                        maxLines: maxLines,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        controller.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textPrimary,
                        ),
                        maxLines: maxLines,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(AppThemeData theme, ThemeProvider themeProvider) {
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