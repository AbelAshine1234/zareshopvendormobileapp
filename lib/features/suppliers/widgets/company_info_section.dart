import 'package:flutter/material.dart';
import '../supplier_model.dart';
import '../../../shared/utils/theme/app_themes.dart';

class CompanyInfoSection extends StatelessWidget {
  final B2BSupplier supplier;
  final AppThemeData theme;

  const CompanyInfoSection({
    super.key,
    required this.supplier,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Company Overview
        _buildSection(
          theme,
          'Company Overview',
          Column(
            children: [
              _buildInfoRow(theme, 'Business Type', 'Manufacturer & Exporter'),
              _buildInfoRow(theme, 'Main Products', supplier.category),
              _buildInfoRow(theme, 'Total Products', '${supplier.totalProducts}'),
              _buildInfoRow(theme, 'Year Established', '${DateTime.now().year - supplier.yearsInBusiness}'),
              _buildInfoRow(theme, 'Total Employees', '200-500'),
              _buildInfoRow(theme, 'Annual Revenue', 'USD 5-10 Million'),
            ],
          ),
        ),
        
        // Contact Information
        _buildSection(
          theme,
          'Contact Information',
          Column(
            children: [
              _buildInfoRow(theme, 'Location', supplier.location),
              _buildInfoRow(theme, 'Contact Person', 'Abebe Kebede - Sales Manager'),
              _buildInfoRow(theme, 'Phone', '+251 911 234 567'),
              _buildInfoRow(theme, 'Email', 'sales@globalelectronics.et'),
              _buildInfoRow(theme, 'Website', 'www.globalelectronics.et'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(AppThemeData theme, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(AppThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
