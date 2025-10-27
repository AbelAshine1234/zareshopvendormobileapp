abstract class ContactsEvent {}

// Load contacts
class LoadContacts extends ContactsEvent {}

// Load contacts by type
class LoadContactsByType extends ContactsEvent {
  final String type;
  
  LoadContactsByType({required this.type});
}

// Create single contact
class CreateContact extends ContactsEvent {
  final String type;
  final String label;
  final String value;
  final bool isPrimary;
  final bool isVerified;
  
  CreateContact({
    required this.type,
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.isVerified = false,
  });
}

// Create multiple contacts (bulk)
class CreateContactsBulk extends ContactsEvent {
  final List<Map<String, dynamic>> contacts;
  
  CreateContactsBulk({required this.contacts});
}

// Update contact
class UpdateContact extends ContactsEvent {
  final int contactId;
  final String? label;
  final String? value;
  final bool? isPrimary;
  final bool? isVerified;
  
  UpdateContact({
    required this.contactId,
    this.label,
    this.value,
    this.isPrimary,
    this.isVerified,
  });
}

// Set contact as primary
class SetContactAsPrimary extends ContactsEvent {
  final int contactId;
  
  SetContactAsPrimary({required this.contactId});
}

// Delete contact
class DeleteContact extends ContactsEvent {
  final int contactId;
  
  DeleteContact({required this.contactId});
}

// Refresh contacts
class RefreshContacts extends ContactsEvent {}
