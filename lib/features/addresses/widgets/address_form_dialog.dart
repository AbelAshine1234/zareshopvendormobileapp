import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../models/address_model.dart';

class AddressFormDialog extends StatefulWidget {
  final AddressModel? address;
  final Function(Map<String, dynamic>) onSave;

  const AddressFormDialog({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
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

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _addressLine1Controller.text = widget.address!.addressLine1;
    }
    if (widget.address != null) {
      _addressLine2Controller.text = widget.address!.addressLine2 ?? '';
    }
    if (widget.address != null) {
      _cityController.text = widget.address!.city ?? '';
    }
    if (widget.address != null) {
      _stateController.text = widget.address!.state ?? '';
    }
    if (widget.address != null) {
      _regionController.text = widget.address!.region ?? '';
    }
    if (widget.address != null) {
      _subcityController.text = widget.address!.subcity ?? '';
    }
    if (widget.address != null) {
      _woredaController.text = widget.address!.woreda ?? '';
    }
    if (widget.address != null) {
      _kebeleController.text = widget.address!.kebele ?? '';
    }
    if (widget.address != null) {
      _postalCodeController.text = widget.address!.postalCode ?? '';
    }
    if (widget.address != null) {
      _countryController.text = widget.address!.country ?? '';
    }
    if (widget.address != null) {
      _isPrimary = widget.address!.isPrimary;
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
        
        return AlertDialog(
          title: Text(
            widget.address != null ? 'Edit Address' : 'Add Address',
            style: TextStyle(color: theme.textPrimary),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Address Line 1 (Required)
                    TextFormField(
                      controller: _addressLine1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 1 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address line 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Line 2
                    TextFormField(
                      controller: _addressLine2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // City and State Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Region and Subcity Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _regionController,
                            decoration: const InputDecoration(
                              labelText: 'Region',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _subcityController,
                            decoration: const InputDecoration(
                              labelText: 'Subcity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Woreda and Kebele Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _woredaController,
                            decoration: const InputDecoration(
                              labelText: 'Woreda',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _kebeleController,
                            decoration: const InputDecoration(
                              labelText: 'Kebele',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Postal Code and Country Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Postal Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Primary Address Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isPrimary,
                          onChanged: (value) {
                            setState(() {
                              _isPrimary = value ?? false;
                            });
                          },
                        ),
                        const Text('Set as Primary Address'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveAddress,
              child: Text(widget.address != null ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final addressData = {
        'address_line1': _addressLine1Controller.text,
        'address_line2': _addressLine2Controller.text.isNotEmpty ? _addressLine2Controller.text : null,
        'city': _cityController.text.isNotEmpty ? _cityController.text : null,
        'state': _stateController.text.isNotEmpty ? _stateController.text : null,
        'region': _regionController.text.isNotEmpty ? _regionController.text : null,
        'subcity': _subcityController.text.isNotEmpty ? _subcityController.text : null,
        'woreda': _woredaController.text.isNotEmpty ? _woredaController.text : null,
        'kebele': _kebeleController.text.isNotEmpty ? _kebeleController.text : null,
        'postal_code': _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        'country': _countryController.text.isNotEmpty ? _countryController.text : null,
        'is_primary': _isPrimary,
      };
      
      widget.onSave(addressData);
      Navigator.pop(context);
    }
  }
}
