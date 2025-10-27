import 'package:equatable/equatable.dart';

class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Map<String, dynamic>> contacts;
  final int count;
  final String? type;
  final Map<String, dynamic>? vendor;

  const ContactsLoaded({
    required this.contacts,
    required this.count,
    this.type,
    this.vendor,
  });

  @override
  List<Object?> get props => [contacts, count, type, vendor];
}

class ContactsError extends ContactsState {
  final String message;

  const ContactsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Contact creation states
class ContactCreating extends ContactsState {}

class ContactCreated extends ContactsState {
  final Map<String, dynamic> contact;

  const ContactCreated({required this.contact});

  @override
  List<Object?> get props => [contact];
}

class ContactCreateError extends ContactsState {
  final String message;

  const ContactCreateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bulk creation states
class ContactsBulkCreating extends ContactsState {}

class ContactsBulkCreated extends ContactsState {
  final List<Map<String, dynamic>> contacts;
  final int count;

  const ContactsBulkCreated({
    required this.contacts,
    required this.count,
  });

  @override
  List<Object?> get props => [contacts, count];
}

class ContactsBulkCreateError extends ContactsState {
  final String message;

  const ContactsBulkCreateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Contact update states
class ContactUpdating extends ContactsState {}

class ContactUpdated extends ContactsState {
  final Map<String, dynamic> contact;

  const ContactUpdated({required this.contact});

  @override
  List<Object?> get props => [contact];
}

class ContactUpdateError extends ContactsState {
  final String message;

  const ContactUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Set primary states
class ContactSettingPrimary extends ContactsState {}

class ContactSetAsPrimary extends ContactsState {
  final Map<String, dynamic> contact;

  const ContactSetAsPrimary({required this.contact});

  @override
  List<Object?> get props => [contact];
}

class ContactSetPrimaryError extends ContactsState {
  final String message;

  const ContactSetPrimaryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Contact deletion states
class ContactDeleting extends ContactsState {}

class ContactDeleted extends ContactsState {
  final int contactId;

  const ContactDeleted({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}

class ContactDeleteError extends ContactsState {
  final String message;

  const ContactDeleteError({required this.message});

  @override
  List<Object?> get props => [message];
}
