import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';
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
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.9,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationSection(theme),
                          const SizedBox(height: 24),
                          _buildAddressDetailsSection(theme),
                          const SizedBox(height: 24),
                          _buildPrimarySection(theme),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary,
            theme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.address != null ? 'Edit Address' : 'Add New Address',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter address details and location',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                  Icons.map,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Location & Map',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMapPlaceholder(theme),
          const SizedBox(height: 16),
          if (_latitude != null && _longitude != null)
            _buildCoordinatesDisplay(theme),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(AppThemeData theme) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withOpacity(0.1),
            theme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Google Maps Integration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Location will be automatically detected',
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openLocationPicker,
            icon: Icon(Icons.my_location, size: 18),
            label: Text('Set Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesDisplay(AppThemeData theme) {
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
      child: Row(
        children: [
          Icon(
            Icons.my_location,
            color: theme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordinates',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearLocation,
            icon: Icon(
              Icons.clear,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsSection(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
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
                  Icons.home,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1',
            hint: 'Enter street address',
            icon: Icons.location_on,
            isRequired: true,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            hint: 'Apartment, suite, etc. (optional)',
            icon: Icons.location_on_outlined,
            theme: theme,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Enter city',
                  icon: Icons.location_city,
                  isRequired: true,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'Enter state',
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
                  label: 'Region',
                  hint: 'Enter region',
                  icon: Icons.terrain,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _subcityController,
                  label: 'Subcity',
                  hint: 'Enter subcity',
                  icon: Icons.location_city_outlined,
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
                  label: 'Woreda',
                  hint: 'Enter woreda',
                  icon: Icons.location_on_outlined,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _kebeleController,
                  label: 'Kebele',
                  hint: 'Enter kebele',
                  icon: Icons.location_on_outlined,
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
                  label: 'Postal Code',
                  hint: 'Enter postal code',
                  icon: Icons.local_post_office,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  hint: 'Enter country',
                  icon: Icons.public,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.textSecondary.withOpacity(0.7),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPrimarySection(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
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
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set this as your primary shipping address',
                  style: TextStyle(
                    fontSize: 14,
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
    );
  }

  Widget _buildFooter(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: theme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.primary.withOpacity(0.3),
              ),
              child: Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLocationPicker() {
    // TODO: Implement Google Maps location picker
    // For now, simulate location selection
    setState(() {
      _latitude = 9.1450; // Addis Ababa coordinates
      _longitude = 38.7613;
      _placeId = 'ChIJKxjxuaNqWBMRiVODVu0WgAU';
    });
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _placeId = null;
    });
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
