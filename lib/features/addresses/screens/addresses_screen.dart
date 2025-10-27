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
import '../widgets/address_card.dart';
import '../widgets/enhanced_address_form_dialog.dart';
import 'address_detail_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    // Load addresses when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressBloc>().add(LoadAddresses());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressCreated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Address created successfully!',
          );
          _refreshAddresses();
        } else if (state is AddressCreateError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to create address: ${state.message}',
          );
        } else if (state is AddressUpdated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Address updated successfully!',
          );
          _refreshAddresses();
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
          _refreshAddresses();
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
          _refreshAddresses();
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
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primary,
                          theme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Address Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddAddressDialog(),
                        icon: Icon(Icons.add, size: 18),
                        label: Text('Add Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primary,
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    if (state is AddressLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is AddressesLoaded) {
                      final addresses = state.vendorAddresses ?? state.addresses;
                      if (addresses.isEmpty) {
                        return _buildEmptyState(theme);
                      }
                      return _buildAddressesList(addresses);
                    } else if (state is AddressError) {
                      return _buildErrorState(state.message, theme);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressesList(List<AddressModel> addresses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return AddressCard(
                      address: address,
                      onTap: () => _navigateToAddressDetail(address),
                      onDelete: () => _showDeleteAddressDialog(address.id),
                      onSetPrimary: address.isPrimary ? null : () => _setAsPrimary(address.id),
                    );
                  },
    );
  }

  Widget _buildEmptyState(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withOpacity(0.1),
                    theme.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: theme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 60,
                color: theme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No addresses found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first address to get started with shipping',
              style: TextStyle(
                fontSize: 16,
                color: theme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressDialog(),
              icon: Icon(Icons.add, size: 20),
              label: Text(
                'Add Your First Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
                shadowColor: theme.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading addresses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshAddresses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddressDetail(AddressModel address) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressDetailScreen(address: address),
      ),
    );
    
    // If the address was updated or deleted, refresh the list
    if (result != null) {
      _refreshAddresses();
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddressFormDialog(
        onSave: (addressData) {
          context.read<AddressBloc>().add(CreateAddress(
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
            isPrimary: addressData['is_primary'] ?? false,
          ));
        },
      ),
    );
  }

  void _showEditAddressDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddressFormDialog(
        address: address,
        onSave: (addressData) {
          context.read<AddressBloc>().add(UpdateAddress(
            addressId: address.id,
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

  void _showDeleteAddressDialog(int addressId) {
    GlobalDialog.showConfirmation(
      context: context,
      title: 'Delete Address',
      content: 'Are you sure you want to delete this address? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<AddressBloc>().add(DeleteAddress(addressId: addressId));
      }
    });
  }

  void _setAsPrimary(int addressId) {
    context.read<AddressBloc>().add(SetPrimaryAddress(addressId: addressId));
  }

  void _refreshAddresses() {
    context.read<AddressBloc>().add(LoadAddresses());
  }
}
