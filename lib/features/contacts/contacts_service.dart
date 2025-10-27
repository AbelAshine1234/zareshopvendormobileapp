import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/contacts_bloc.dart';
import 'bloc/contacts_event.dart';

/// Global service for accessing contacts functionality from anywhere in the app
class ContactsService {
  static ContactsBloc? _contactsBloc;
  
  /// Initialize the contacts service with the global bloc
  static void initialize(BuildContext context) {
    _contactsBloc = context.read<ContactsBloc>();
  }
  
  /// Get the global contacts bloc
  static ContactsBloc get bloc {
    if (_contactsBloc == null) {
      throw Exception('ContactsService not initialized. Call ContactsService.initialize(context) first.');
    }
    return _contactsBloc!;
  }
  
  /// Load all contacts
  static void loadContacts() {
    bloc.add(LoadContacts());
  }
  
  /// Load contacts by type
  static void loadContactsByType(String type) {
    bloc.add(LoadContactsByType(type: type));
  }
  
  /// Create a new contact
  static void createContact({
    required String type,
    required String label,
    required String value,
    bool isPrimary = false,
    bool isVerified = false,
  }) {
    bloc.add(CreateContact(
      type: type,
      label: label,
      value: value,
      isPrimary: isPrimary,
      isVerified: isVerified,
    ));
  }
  
  /// Create multiple contacts (bulk)
  static void createContactsBulk(List<Map<String, dynamic>> contacts) {
    bloc.add(CreateContactsBulk(contacts: contacts));
  }
  
  /// Update a contact
  static void updateContact({
    required int contactId,
    String? label,
    String? value,
    bool? isPrimary,
    bool? isVerified,
  }) {
    bloc.add(UpdateContact(
      contactId: contactId,
      label: label,
      value: value,
      isPrimary: isPrimary,
      isVerified: isVerified,
    ));
  }
  
  /// Set contact as primary
  static void setContactAsPrimary(int contactId) {
    bloc.add(SetContactAsPrimary(contactId: contactId));
  }
  
  /// Delete a contact
  static void deleteContact(int contactId) {
    bloc.add(DeleteContact(contactId: contactId));
  }
  
  /// Refresh contacts
  static void refreshContacts() {
    bloc.add(RefreshContacts());
  }
}
