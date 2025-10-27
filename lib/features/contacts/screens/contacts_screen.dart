import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/common/global_snackbar.dart';
import '../../../shared/widgets/common/global_dialog.dart';
import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';
import '../widgets/contact_card.dart';
import '../widgets/contact_filter_chips.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/contacts_empty_state.dart';
import '../widgets/contacts_error_state.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String selectedType = 'all';

  @override
  void initState() {
    super.initState();
    // Load contacts when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsBloc>().add(LoadContacts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsBloc, ContactsState>(
      listener: (context, state) {
        if (state is ContactCreated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Contact created successfully!',
          );
          context.read<ContactsBloc>().add(LoadContacts());
        } else if (state is ContactCreateError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to create contact: ${state.message}',
          );
        } else if (state is ContactUpdated) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Contact updated successfully!',
          );
          context.read<ContactsBloc>().add(LoadContacts());
        } else if (state is ContactUpdateError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to update contact: ${state.message}',
          );
        } else if (state is ContactDeleted) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Contact deleted successfully!',
          );
          context.read<ContactsBloc>().add(LoadContacts());
        } else if (state is ContactDeleteError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to delete contact: ${state.message}',
          );
        } else if (state is ContactSetAsPrimary) {
          GlobalSnackBar.showSuccess(
            context: context,
            message: 'Contact set as primary!',
          );
          context.read<ContactsBloc>().add(LoadContacts());
        } else if (state is ContactSetPrimaryError) {
          GlobalSnackBar.showError(
            context: context,
            message: 'Failed to set contact as primary: ${state.message}',
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
                    'Contact Information',
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
                    IconButton(
                      icon: Icon(Icons.add, color: theme.textPrimary),
                      onPressed: _showAddContactDialog,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: Column(
                  children: [
                    // Filter chips
                    ContactFilterChips(
                      selectedType: selectedType,
                      onTypeChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 16),
                    // Contacts list
                    Expanded(
                      child: BlocBuilder<ContactsBloc, ContactsState>(
                        builder: (context, state) {
                          if (state is ContactsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is ContactsLoaded) {
                            final contacts = _filterContactsByType(state.contacts);
                            if (contacts.isEmpty) {
                              return ContactsEmptyState(
                                onAddContact: _showAddContactDialog,
                              );
                            }
                            return _buildContactsList(contacts);
                          } else if (state is ContactsError) {
                            return ContactsErrorState(
                              message: state.message,
                              onRetry: () => context.read<ContactsBloc>().add(LoadContacts()),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContactsList(List<Map<String, dynamic>> contacts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactCard(
          contact: contact,
          onAction: _handleContactAction,
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterContactsByType(List<Map<String, dynamic>> contacts) {
    if (selectedType == 'all') {
      return contacts;
    }
    return contacts.where((contact) => contact['type'] == selectedType).toList();
  }

  void _onTypeChanged(String type) {
    setState(() {
      selectedType = type;
    });
    if (type == 'all') {
      context.read<ContactsBloc>().add(LoadContacts());
    } else {
      context.read<ContactsBloc>().add(LoadContactsByType(type: type));
    }
  }

  void _handleContactAction(String action, Map<String, dynamic> contact) {
    final id = contact['id'] as int;
    
    switch (action) {
      case 'set_primary':
        context.read<ContactsBloc>().add(SetContactAsPrimary(contactId: id));
        break;
      case 'edit':
        _showEditContactDialog(contact);
        break;
      case 'delete':
        _showDeleteContactDialog(id);
        break;
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => ContactFormDialog(
        onSave: (contactData) {
          context.read<ContactsBloc>().add(CreateContact(
            type: contactData['type'],
            label: contactData['label'],
            value: contactData['value'],
            isPrimary: contactData['is_primary'] ?? false,
            isVerified: contactData['is_verified'] ?? false,
          ));
        },
      ),
    );
  }

  void _showEditContactDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => ContactFormDialog(
        contact: contact,
        onSave: (contactData) {
          context.read<ContactsBloc>().add(UpdateContact(
            contactId: contact['id'],
            label: contactData['label'],
            value: contactData['value'],
            isPrimary: contactData['is_primary'],
            isVerified: contactData['is_verified'],
          ));
        },
      ),
    );
  }

  void _showDeleteContactDialog(int contactId) {
    GlobalDialog.showConfirmation(
      context: context,
      title: 'Delete Contact',
      content: 'Are you sure you want to delete this contact? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<ContactsBloc>().add(DeleteContact(contactId: contactId));
      }
    });
  }
}