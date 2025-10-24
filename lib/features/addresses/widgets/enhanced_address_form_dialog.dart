import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../core/services/localization_service.dart';
import '../models/address_model.dart';

class EnhancedAddressFormDialog extends StatefulWidget {
  final AddressModel? address;
  final Function(Map<String, dynamic>) onSave;

  const EnhancedAddressFormDialog({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<EnhancedAddressFormDialog> createState() => _EnhancedAddressFormDialogState();
}

class _EnhancedAddressFormDialogState extends State<EnhancedAddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _regionController = TextEditingController();
  final _subcityController = TextEditingController();
  final _woredaController = TextEditingController();
  final _kebeleController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  
  bool _isPrimary = false;
  double? _latitude;
  double? _longitude;
  String? _placeId;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(9.1450, 38.7613); // Addis Ababa

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _addressLine1Controller.text = widget.address!.addressLine1;
      _addressLine2Controller.text = widget.address!.addressLine2 ?? '';
      _cityController.text = widget.address!.city ?? '';
      _stateController.text = widget.address!.state ?? '';
      _regionController.text = widget.address!.region ?? '';
      _subcityController.text = widget.address!.subcity ?? '';
      _woredaController.text = widget.address!.woreda ?? '';
      _kebeleController.text = widget.address!.kebele ?? '';
      _postalCodeController.text = widget.address!.postalCode ?? '';
      _countryController.text = widget.address!.country ?? '';
      _isPrimary = widget.address!.isPrimary;
      _latitude = widget.address!.latitude;
      _longitude = widget.address!.longitude;
      _placeId = widget.address!.placeId;
      
      if (_latitude != null && _longitude != null) {
        _initialPosition = LatLng(_latitude!, _longitude!);
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _initialPosition,
            infoWindow: const InfoWindow(title: 'Selected Location'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _regionController.dispose();
    _subcityController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.address != null ? 'addresses.updateAddress'.tr() : 'addresses.addNewAddress'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Google Maps Section
                          _buildMapSection(theme),
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            controller: _addressLine1Controller,
                            label: 'addresses.addressLine1'.tr(),
                            hint: 'addresses.enterStreetAddress'.tr(),
                            icon: Icons.home,
                            isRequired: true,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _addressLine2Controller,
                            label: 'addresses.addressLine2'.tr(),
                            hint: 'addresses.apartmentSuite'.tr(),
                            icon: Icons.home_outlined,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: 'addresses.city'.tr(),
                                  hint: 'addresses.enterCity'.tr(),
                                  icon: Icons.business,
                                  isRequired: true,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _stateController,
                                  label: 'addresses.state'.tr(),
                                  hint: 'addresses.enterState'.tr(),
                                  icon: Icons.map,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _regionController,
                                  label: 'addresses.region'.tr(),
                                  hint: 'addresses.enterRegion'.tr(),
                                  icon: Icons.terrain,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _subcityController,
                                  label: 'addresses.subcity'.tr(),
                                  hint: 'addresses.enterSubcity'.tr(),
                                  icon: Icons.location_city,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _woredaController,
                                  label: 'addresses.woreda'.tr(),
                                  hint: 'addresses.enterWoreda'.tr(),
                                  icon: Icons.home,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _kebeleController,
                                  label: 'addresses.kebele'.tr(),
                                  hint: 'addresses.enterKebele'.tr(),
                                  icon: Icons.home_work,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _postalCodeController,
                                  label: 'addresses.postalCode'.tr(),
                                  hint: 'addresses.enterPostalCode'.tr(),
                                  icon: Icons.local_post_office,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _countryController,
                                  label: 'addresses.country'.tr(),
                                  hint: 'addresses.enterCountry'.tr(),
                                  icon: Icons.public,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Primary Address Toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: theme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'addresses.primaryAddress'.tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'addresses.primaryAddressDesc'.tr(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: theme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isPrimary,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPrimary = value;
                                    });
                                  },
                                  activeColor: theme.primary,
                                  activeTrackColor: theme.primary.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('common.cancel'.tr()),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _saveAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('addresses.addAddress'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildMapSection(AppThemeData theme) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 15.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          onTap: (LatLng position) {
            setState(() {
              _latitude = position.latitude;
              _longitude = position.longitude;
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: position,
                  infoWindow: InfoWindow(title: 'addresses.selectedLocation'.tr()),
                ),
              );
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required AppThemeData theme,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: theme.primary),
        hintText: hint,
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'validation.required'.tr();
              }
              return null;
            }
          : null,
    );
  }


  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final addressData = {
        'address_line1': _addressLine1Controller.text,
        'address_line2': _addressLine2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'region': _regionController.text,
        'subcity': _subcityController.text,
        'woreda': _woredaController.text,
        'kebele': _kebeleController.text,
        'postal_code': _postalCodeController.text,
        'country': _countryController.text,
        'is_primary': _isPrimary,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
        if (_placeId != null) 'place_id': _placeId,
      };
      
      widget.onSave(addressData);
      Navigator.pop(context);
    }
  }
}
