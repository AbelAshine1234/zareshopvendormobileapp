import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/utils/theme/theme_provider.dart';

class ContactFormDialog extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Function(Map<String, dynamic>) onSave;

  const ContactFormDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _valueController = TextEditingController();
  
  String _selectedType = 'phone';
  bool _isPrimary = false;
  bool _isVerified = false;
  
  final List<String> _contactTypes = [
    'phone',
    'email',
    'website',
    'social_media',
    'address',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _labelController.text = widget.contact!['label'] ?? '';
      _valueController.text = widget.contact!['value'] ?? '';
      _selectedType = widget.contact!['type'] ?? 'phone';
      _isPrimary = widget.contact!['is_primary'] ?? false;
      _isVerified = widget.contact!['is_verified'] ?? false;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return AlertDialog(
          title: Text(
            widget.contact != null ? 'Edit Contact' : 'Add Contact',
            style: TextStyle(color: theme.textPrimary),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _contactTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Label field
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Value field
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Checkboxes
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
                    const Text('Set as Primary'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isVerified,
                      onChanged: (value) {
                        setState(() {
                          _isVerified = value ?? false;
                        });
                      },
                    ),
                    const Text('Verified'),
                  ],
                ),
              ],
            ),
          ),
        ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveContact,
              child: Text(widget.contact != null ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final contactData = {
        'type': _selectedType,
        'label': _labelController.text,
        'value': _valueController.text,
        'is_primary': _isPrimary,
        'is_verified': _isVerified,
      };
      
      widget.onSave(contactData);
      Navigator.pop(context);
    }
  }
}
