import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../core/services/localization_service.dart';
import '../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final Function(String, AddressModel) onAction;

  const AddressCard({
    super.key,
    required this.address,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.divider.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section with location icon and primary badge
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.textPrimary,
                            ),
                          ),
                          if (address.formattedAddress != null && 
                              address.formattedAddress != address.displayAddress) ...[
                            const SizedBox(height: 4),
                            Text(
                              address.formattedAddress!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: theme.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (address.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.verified,
                          color: theme.surface,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Address details section
                Column(
                  children: [
                    // City and State
                    if (address.city?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.business,
                        Colors.blue,
                        'addresses.city'.tr(),
                        address.city!,
                      ),
                    if (address.city?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // State/Region
                    if (address.state?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.map,
                        Colors.green,
                        'addresses.state'.tr(),
                        address.state!,
                      ),
                    if (address.state?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Region
                    if (address.region?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.terrain,
                        Colors.orange,
                        'addresses.region'.tr(),
                        address.region!,
                      ),
                    if (address.region?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Subcity
                    if (address.subcity?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.location_city_outlined,
                        Colors.purple,
                        'addresses.subcity'.tr(),
                        address.subcity!,
                      ),
                    if (address.subcity?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Woreda
                    if (address.woreda?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.home,
                        Colors.teal,
                        'addresses.woreda'.tr(),
                        address.woreda!,
                      ),
                    if (address.woreda?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Kebele
                    if (address.kebele?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.home_work,
                        Colors.indigo,
                        'addresses.kebele'.tr(),
                        address.kebele!,
                      ),
                    if (address.kebele?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Postal Code
                    if (address.postalCode?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.local_post_office,
                        Colors.brown,
                        'addresses.postalCode'.tr(),
                        address.postalCode!,
                      ),
                    if (address.postalCode?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Country
                    if (address.country?.isNotEmpty == true)
                      _buildAddressItem(
                        Icons.public,
                        Colors.red,
                        'addresses.country'.tr(),
                        address.country!,
                      ),
                    if (address.country?.isNotEmpty == true)
                      const SizedBox(height: 6),

                    // Coordinates
                    if (address.latitude != null && address.longitude != null)
                      _buildAddressItem(
                        Icons.my_location,
                        Colors.cyan,
                        'addresses.coordinates'.tr(),
                        '${address.latitude!.toStringAsFixed(4)}, ${address.longitude!.toStringAsFixed(4)}',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onAction('edit', address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'addresses.updateAddress'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onAction('delete', address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.error,
                          foregroundColor: theme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'addresses.deleteAddress'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
