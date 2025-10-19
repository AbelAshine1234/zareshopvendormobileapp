import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';

class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Admin Review',
          style: AppThemes.titleLarge(theme),
        ),
        backgroundColor: theme.surface,
        elevation: 0,
        actions: [
          // Theme selector button
          const ThemeSelectorButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(theme),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Pending Applications
            _buildPendingApplicationsSection(theme),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Quick Stats
            _buildQuickStatsSection(theme),
            const SizedBox(height: AppThemes.spaceXL),
            
            // Recent Activity
            _buildRecentActivitySection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceXL),
      decoration: AppThemes.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceM),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: theme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppThemes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Applications Review',
                      style: AppThemes.headlineMedium(theme),
                    ),
                    const SizedBox(height: AppThemes.spaceS),
                    Text(
                      'Review and approve vendor applications for ZareShop',
                      style: AppThemes.bodyLarge(theme).copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApplicationsSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Applications',
          style: AppThemes.titleLarge(theme),
        ),
        const SizedBox(height: AppThemes.spaceM),
        
        // Mock pending applications
        ...List.generate(3, (index) => _buildApplicationCard(theme, index)),
      ],
    );
  }

  Widget _buildApplicationCard(AppThemeData theme, int index) {
    final applications = [
      {
        'name': 'Ethiopian Coffee Co.',
        'category': 'Food & Beverage',
        'location': 'Addis Ababa, Ethiopia',
        'status': 'Pending',
        'submittedDate': '2 days ago',
        'businessType': 'Coffee Shop',
      },
      {
        'name': 'Fashion Forward',
        'category': 'Fashion',
        'location': 'Bahir Dar, Ethiopia',
        'status': 'Pending',
        'submittedDate': '1 day ago',
        'businessType': 'Clothing Store',
      },
      {
        'name': 'Tech Gadgets Hub',
        'category': 'Electronics',
        'location': 'Dire Dawa, Ethiopia',
        'status': 'Pending',
        'submittedDate': '3 hours ago',
        'businessType': 'Electronics Store',
      },
    ];

    final app = applications[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceM),
      padding: const EdgeInsets.all(AppThemes.spaceL),
      decoration: AppThemes.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['name']!,
                      style: AppThemes.titleMedium(theme).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppThemes.spaceXS),
                    Text(
                      app['businessType']!,
                      style: AppThemes.bodyMedium(theme).copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceM,
                  vertical: AppThemes.spaceS,
                ),
                decoration: BoxDecoration(
                  color: theme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadius),
                  border: Border.all(
                    color: theme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  app['status']!,
                  style: AppThemes.bodySmall(theme).copyWith(
                    color: theme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceM),
          
          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: theme.textSecondary,
              ),
              const SizedBox(width: AppThemes.spaceS),
              Text(
                app['category']!,
                style: AppThemes.bodySmall(theme),
              ),
              const SizedBox(width: AppThemes.spaceL),
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.textSecondary,
              ),
              const SizedBox(width: AppThemes.spaceS),
              Text(
                app['location']!,
                style: AppThemes.bodySmall(theme),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceS),
          
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.textSecondary,
              ),
              const SizedBox(width: AppThemes.spaceS),
              Text(
                'Submitted ${app['submittedDate']}',
                style: AppThemes.bodySmall(theme).copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceM),
          
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  text: 'Review Details',
                  onPressed: () {
                    // TODO: Navigate to detailed review
                  },
                  height: 40,
                ),
              ),
              const SizedBox(width: AppThemes.spaceM),
              Expanded(
                child: AppPrimaryButton(
                  text: 'Quick Approve',
                  onPressed: () {
                    // TODO: Quick approve functionality
                  },
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: AppThemes.titleLarge(theme),
        ),
        const SizedBox(height: AppThemes.spaceM),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Pending',
                '12',
                Icons.pending_actions,
                theme.warning,
              ),
            ),
            const SizedBox(width: AppThemes.spaceM),
            Expanded(
              child: _buildStatCard(
                theme,
                'Approved Today',
                '8',
                Icons.check_circle,
                theme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemes.spaceM),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Rejected',
                '3',
                Icons.cancel,
                theme.error,
              ),
            ),
            const SizedBox(width: AppThemes.spaceM),
            Expanded(
              child: _buildStatCard(
                theme,
                'Total This Week',
                '23',
                Icons.trending_up,
                theme.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    AppThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceL),
      decoration: AppThemes.cardDecoration(theme),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppThemes.spaceM),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppThemes.spaceM),
          Text(
            value,
            style: AppThemes.headlineLarge(theme).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppThemes.spaceXS),
          Text(
            title,
            style: AppThemes.bodySmall(theme).copyWith(
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppThemes.titleLarge(theme),
        ),
        const SizedBox(height: AppThemes.spaceM),
        
        Container(
          padding: const EdgeInsets.all(AppThemes.spaceL),
          decoration: AppThemes.cardDecoration(theme),
          child: Column(
            children: [
              _buildActivityItem(
                theme,
                'Approved "Ethiopian Spices" application',
                '2 hours ago',
                Icons.check_circle,
                theme.success,
              ),
              const SizedBox(height: AppThemes.spaceM),
              _buildActivityItem(
                theme,
                'Rejected "Fake Electronics" application',
                '4 hours ago',
                Icons.cancel,
                theme.error,
              ),
              const SizedBox(height: AppThemes.spaceM),
              _buildActivityItem(
                theme,
                'Approved "Local Fashion" application',
                '6 hours ago',
                Icons.check_circle,
                theme.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    AppThemeData theme,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
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
            size: 16,
          ),
        ),
        const SizedBox(width: AppThemes.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: AppThemes.bodyMedium(theme),
              ),
              Text(
                time,
                style: AppThemes.bodySmall(theme).copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
