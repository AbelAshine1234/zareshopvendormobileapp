import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/selectors/language_switcher_button.dart';
import '../../../shared/widgets/selectors/theme_selector_button.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/common/app_widgets.dart';
import '../bloc/vendor_info_bloc.dart';
import '../bloc/vendor_info_event.dart';
import '../bloc/vendor_info_state.dart';
import '../bloc/vendor_update_bloc.dart';
import '../bloc/vendor_update_event.dart';
import '../bloc/vendor_update_state.dart';

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
    
    return BlocListener<VendorUpdateBloc, VendorUpdateState>(
        listener: (context, state) {
          if (state is VendorUpdateSuccess) {
            GlobalSnackBar.showSuccess(
              context: context,
              message: 'Cover image updated successfully!',
            );
            // Refresh vendor info to show updated image
            context.read<VendorInfoBloc>().add(LoadVendorInfo());
          } else if (state is VendorUpdateError) {
            GlobalSnackBar.showError(
              context: context,
              message: 'Failed to update cover image: ${state.message}',
            );
          }
        },
        child: Builder(
          builder: (context) => Consumer2<LocalizationService, ThemeProvider>(
            builder: (context, localization, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              
              return BlocBuilder<VendorUpdateBloc, VendorUpdateState>(
                builder: (context, updateState) {
                  final isUpdating = updateState is VendorUpdateLoading;
                  
                  return Scaffold(
                    backgroundColor: theme.background,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: const SizedBox.shrink(),
                      actions: const [
                        LanguageSwitcherButton(),
                        SizedBox(width: 8),
                        ThemeSelectorButton(),
                        SizedBox(width: 16),
                      ],
                    ),
                    body: Stack(
                      children: [
                        SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                BlocBuilder<VendorInfoBloc, VendorInfoState>(
                                  builder: (context, vendorInfoState) {
                                    return BlocBuilder<VendorUpdateBloc, VendorUpdateState>(
                                      builder: (context, updateState) {
                                        return _buildProfileHeader(theme, vendorInfoState, updateState);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                ..._buildAllSections(localization, theme),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        // Loading overlay
                        if (isUpdating)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Updating cover image...',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
  }

  Widget _buildProfileHeader(AppThemeData theme, VendorInfoState vendorInfoState, VendorUpdateState updateState) {
    String storeName = 'Name is not available';
    String? coverImageUrl;
    String statusText = 'Verified Store';
    Color statusColor = Colors.blue[800]!;
    Color statusBgColor = Colors.blue[100]!;
    bool isLoading = updateState is VendorUpdateLoading;
    
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
              child: isLoading
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
                      : Image.asset(
                          'assets/logo/logo-basic.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.business, size: 50, color: Colors.grey[600]);
                          },
                        ),
            ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (!isLoading) {
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
                        color: isLoading ? Colors.grey[400] : Colors.blue[600],
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
          Text(
            storeName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
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

  List<Widget> _buildAllSections(LocalizationService localization, AppThemeData theme) {
    final sections = [
      {
        'title': 'settings.account.title',
        'items': [
          {'icon': Icons.image_outlined, 'title': 'settings.account.storeLogo', 'subtitle': 'settings.account.storeLogoDesc'},
          {'icon': Icons.contact_mail_outlined, 'title': 'settings.account.contactInfo', 'subtitle': 'settings.account.contactInfoDesc'},
          {'icon': Icons.location_on_outlined, 'title': 'settings.account.addressManagement', 'subtitle': 'settings.account.addressManagementDesc'},
          {'icon': Icons.lock_outline, 'title': 'settings.account.changePassword', 'subtitle': 'settings.account.changePasswordDesc'},
        ]
      },
      {
        'title': 'settings.payment.title',
        'items': [
          {'icon': Icons.account_balance_outlined, 'title': 'settings.payment.paymentMethods', 'subtitle': 'settings.payment.paymentMethodsDesc'},
          {'icon': Icons.account_balance_wallet_outlined, 'title': 'settings.payment.walletBalance', 'subtitle': 'settings.payment.walletBalanceDesc'},
          {'icon': Icons.history, 'title': 'settings.payment.payoutHistory', 'subtitle': 'settings.payment.payoutHistoryDesc'},
          {'icon': Icons.receipt_outlined, 'title': 'settings.payment.invoiceManagement', 'subtitle': 'settings.payment.invoiceManagementDesc'},
        ]
      },
      {
        'title': 'settings.orders.title',
        'items': [
          {'icon': Icons.notifications_active_outlined, 'title': 'settings.orders.pushNotifications', 'subtitle': 'settings.orders.pushNotificationsDesc', 'trailing': Switch(value: _notificationsEnabled, onChanged: (v) => setState(() => _notificationsEnabled = v))},
          {'icon': Icons.sms_outlined, 'title': 'settings.orders.smsNotifications', 'subtitle': 'settings.orders.smsNotificationsDesc'},
          {'icon': Icons.email_outlined, 'title': 'settings.orders.emailNotifications', 'subtitle': 'settings.orders.emailNotificationsDesc'},
          {'icon': Icons.language_outlined, 'title': 'settings.orders.notificationLanguage', 'subtitle': 'settings.orders.notificationLanguageDesc'},
        ]
      },
      {
        'title': 'settings.products.title',
        'items': [
          {'icon': Icons.category_outlined, 'title': 'settings.products.defaultCategories', 'subtitle': 'settings.products.defaultCategoriesDesc'},
          {'icon': Icons.inventory_2_outlined, 'title': 'settings.products.stockManagement', 'subtitle': 'settings.products.stockManagementDesc'},
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textPrimary),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: theme.textPrimary),
                    ),
                      const SizedBox(height: 4),
                      Text(
                      localization.translate(item['subtitle'] as String),
                      style: TextStyle(fontSize: 14, color: theme.textSecondary),
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


  void _showLogoutDialog() {
    GlobalDialog.showLogoutConfirmation(context: context).then((confirmed) {
      if (confirmed == true) {
        // TODO: Implement logout functionality
      }
    });
  }
}