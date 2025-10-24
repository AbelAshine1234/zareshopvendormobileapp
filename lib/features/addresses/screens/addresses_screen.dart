import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../models/address_model.dart';
import '../widgets/address_card.dart';
import '../widgets/enhanced_address_form_dialog.dart';

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
            message: 'addresses.addressCreated'.tr(),
          );
          _refreshAddresses();
        } else if (state is AddressCreateError) {
          GlobalSnackBar.showError(
            context: context,
            message: '${'addresses.failedToCreate'.tr()}: ${state.message}',
          );
        } else if (state is AddressUpdated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'addresses.addressUpdated'.tr(),
          );
          _refreshAddresses();
        } else if (state is AddressUpdateError) {
          GlobalSnackBar.showError(
            context: context,
            message: '${'addresses.failedToUpdate'.tr()}: ${state.message}',
          );
        } else if (state is AddressDeleted) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'addresses.addressDeleted'.tr(),
          );
          _refreshAddresses();
        } else if (state is AddressDeleteError) {
          GlobalSnackBar.showError(
            context: context,
            message: '${'addresses.failedToDelete'.tr()}: ${state.message}',
          );
        } else if (state is AddressSetAsPrimary) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'addresses.addressSetPrimary'.tr(),
          );
          _refreshAddresses();
        } else if (state is AddressSetPrimaryError) {
          GlobalSnackBar.showError(
            context: context,
            message: '${'addresses.failedToSetPrimary'.tr()}: ${state.message}',
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
                  backgroundColor: theme.surface,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'addresses.title'.tr(),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => _showAddAddressDialog(),
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  icon: Icon(Icons.add, size: 20),
                  label: Text(
                    'addresses.addAddress'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
          onAction: (action, address) {
            if (action == 'edit') {
              _showEditAddressDialog(address);
            } else if (action == 'delete') {
              _showDeleteAddressDialog(address.id);
            }
          },
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
                Icons.home_outlined,
                size: 60,
                color: theme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'addresses.noAddressesFound'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'addresses.addFirstAddress'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
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
                'addresses.addYourFirstAddress'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
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
            'addresses.errorLoadingAddresses'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
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
      title: 'addresses.deleteAddress'.tr(),
      content: 'addresses.deleteConfirmation'.tr(),
      confirmText: 'addresses.deleteAddress'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<AddressBloc>().add(DeleteAddress(addressId: addressId));
      }
    });
  }


  void _refreshAddresses() {
    context.read<AddressBloc>().add(LoadAddresses());
  }
}
