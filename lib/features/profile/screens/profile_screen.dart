import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/app_themes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/language_selector/language_switcher_button.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../settings/screens/payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfile());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
            final vendor = state is ProfileLoaded
                ? state.vendor
                : (state as ProfileUpdateSuccess).vendor;
            final currentLanguage =
                state is ProfileLoaded ? state.currentLanguage : 'en';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(vendor),
                  const SizedBox(height: 24),
                  _buildAccountSection(context, vendor, currentLanguage),
                  const SizedBox(height: 28),
                  _buildPreferencesSection(context),
                  const SizedBox(height: 28),
                  _buildSupportSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox();
        },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(vendor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: vendor.profileImageUrl.isNotEmpty 
                      ? vendor.profileImageUrl 
                      : 'https://i.pravatar.cc/150?img=12',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, size: 36, color: Colors.grey[500]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.shopName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.ownerName,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.successColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, vendor, String currentLanguage) {
    final currentLang = AppConstants.supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentLanguage,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Account Information',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.language,
          title: 'Language',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLang['name'] ?? 'English',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
          onTap: () => _showLanguageDialog(context, currentLanguage),
        ),
        _buildMenuItem(
          icon: Icons.credit_card,
          title: 'Payment Methods',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentMethodsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppTheme.successColor,
          ),
          onTap: null,
        ),
        _buildMenuItem(
          icon: Icons.palette_outlined,
          title: 'Theme',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Light',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.view_list_outlined,
          title: 'Default Order View',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'SUPPORTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.support_agent_outlined,
          title: 'Contact Support',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.quiz_outlined,
          title: 'FAQ',
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedLanguages.map((lang) {
            final isSelected = lang['code'] == currentLanguage;
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  context.read<ProfileBloc>().add(ChangeLanguage(value));
                  Navigator.pop(dialogContext);
                }
              },
              selected: isSelected,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text(
              'Zareshop Vendor App helps Ethiopian vendors manage their online business efficiently.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}
