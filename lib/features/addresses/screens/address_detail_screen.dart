import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/common/global_snackbar.dart';
import '../../../shared/widgets/common/global_dialog.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../models/address_model.dart';
import '../widgets/enhanced_address_form_dialog.dart';

class AddressDetailScreen extends StatefulWidget {
  final AddressModel address;

  const AddressDetailScreen({
    super.key,
    required this.address,
  });

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressUpdated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Address updated successfully!',
          );
          Navigator.pop(context, state.address);
        } else if (state is AddressUpdateError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to update address: ${state.message}',
          );
        } else if (state is AddressDeleted) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Address deleted successfully!',
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        } else if (state is AddressDeleteError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to delete address: ${state.message}',
          );
        } else if (state is AddressSetAsPrimary) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Address set as primary!',
          );
          Navigator.pop(context, state.address);
        } else if (state is AddressSetPrimaryError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to set address as primary: ${state.message}',
          );
        }
      },
      child: Consumer<LocalizationService>(
        builder: (context, localization, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final theme = themeProvider.currentTheme;
              
              return Scaffold(
                backgroundColor: theme.background,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Address Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    TextButton.icon(
                      onPressed: () => _showEditAddressDialog(),
                      icon: Icon(Icons.edit, color: theme.primary),
                      label: Text(
                        'Edit',
                        style: TextStyle(color: theme.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressCard(theme),
                      if (widget.address.latitude != null && widget.address.longitude != null)
                        _buildMapSection(theme),
                      _buildAddressDetails(theme),
                      if (widget.address.latitude != null && widget.address.longitude != null)
                        _buildCoordinatesSection(theme),
                      _buildStatusSection(theme),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(AppThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primary,
                        theme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
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
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.address.displayAddress,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.address.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                          size: 16,
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
              ],
            ),
            if (widget.address.formattedAddress != null && 
                widget.address.formattedAddress != widget.address.displayAddress) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_align_left,
                      size: 18,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.address.formattedAddress!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: _buildMapFallback(theme),
    );
  }

  Widget _buildMapFallback(AppThemeData theme) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primary,
                  theme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Location Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${widget.address.latitude!.toStringAsFixed(6)}, ${widget.address.longitude!.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Open in external maps app
              final lat = widget.address.latitude!;
              final lng = widget.address.longitude!;
              final url = 'https://www.google.com/maps?q=$lat,$lng';
              // You can use url_launcher here if needed
            },
            icon: Icon(Icons.open_in_new, size: 18),
            label: Text(
              'Open in Maps',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 4,
              shadowColor: theme.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(AppThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Address Line 1', widget.address.addressLine1, theme),
          if (widget.address.addressLine2?.isNotEmpty == true)
            _buildDetailRow('Address Line 2', widget.address.addressLine2!, theme),
          if (widget.address.city?.isNotEmpty == true)
            _buildDetailRow('City', widget.address.city!, theme),
          if (widget.address.state?.isNotEmpty == true)
            _buildDetailRow('State', widget.address.state!, theme),
          if (widget.address.region?.isNotEmpty == true)
            _buildDetailRow('Region', widget.address.region!, theme),
          if (widget.address.subcity?.isNotEmpty == true)
            _buildDetailRow('Subcity', widget.address.subcity!, theme),
          if (widget.address.woreda?.isNotEmpty == true)
            _buildDetailRow('Woreda', widget.address.woreda!, theme),
          if (widget.address.kebele?.isNotEmpty == true)
            _buildDetailRow('Kebele', widget.address.kebele!, theme),
          if (widget.address.postalCode?.isNotEmpty == true)
            _buildDetailRow('Postal Code', widget.address.postalCode!, theme),
          if (widget.address.country?.isNotEmpty == true)
            _buildDetailRow('Country', widget.address.country!, theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Coordinates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCoordinateItem(
                  'Latitude',
                  widget.address.latitude!.toStringAsFixed(6),
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCoordinateItem(
                  'Longitude',
                  widget.address.longitude!.toStringAsFixed(6),
                  theme,
                ),
              ),
            ],
          ),
          if (widget.address.placeId?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 18,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Place ID: ${widget.address.placeId}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoordinateItem(String label, String value, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(AppThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Status Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Primary',
                  widget.address.isPrimary,
                  widget.address.isPrimary ? Colors.green : Colors.grey,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusItem(
                  'Verified',
                  widget.address.isVerified,
                  widget.address.isVerified ? Colors.blue : Colors.grey,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: theme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Created: ${_formatDate(widget.address.createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool value, Color color, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              value ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }


  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddressFormDialog(
        address: widget.address,
        onSave: (addressData) {
          context.read<AddressBloc>().add(UpdateAddress(
            addressId: widget.address.id,
            addressLine1: addressData['address_line1'],
            addressLine2: addressData['address_line2'],
            city: addressData['city'],
            state: addressData['state'],
            region: addressData['region'],
            subcity: addressData['subcity'],
            woreda: addressData['woreda'],
            kebele: addressData['kebele'],
            postalCode: addressData['postal_code'],
            country: addressData['country'],
            isPrimary: addressData['is_primary'],
          ));
        },
      ),
    );
  }

}
