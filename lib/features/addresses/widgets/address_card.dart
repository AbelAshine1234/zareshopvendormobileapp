import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrimary;

  const AddressCard({
    super.key,
    required this.address,
    required this.onTap,
    this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.primary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primary,
                              theme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.displayAddress,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            if (address.formattedAddress != null && 
                                address.formattedAddress != address.displayAddress) ...[
                              const SizedBox(height: 4),
                              Text(
                                address.formattedAddress!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textSecondary,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (address.isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.green.shade600],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Primary',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (address.isPrimary) const SizedBox(width: 8),
                          if (address.isVerified)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ),
                          if (address.isVerified) const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (address.latitude != null && address.longitude != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 16,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${address.latitude!.toStringAsFixed(4)}, ${address.longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onSetPrimary != null && !address.isPrimary)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onSetPrimary,
                            icon: Icon(Icons.star, size: 16),
                            label: Text('Set Primary'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary.withOpacity(0.1),
                              foregroundColor: theme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (onSetPrimary != null && !address.isPrimary) const SizedBox(width: 12),
                      if (onDelete != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: Icon(Icons.delete, size: 16),
                            label: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getAddressIcon(AppThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.location_on,
        color: Colors.blue,
        size: 20,
      ),
    );
  }
}
