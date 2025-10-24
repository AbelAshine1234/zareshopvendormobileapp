import 'package:equatable/equatable.dart';

abstract class ContactUpdateEvent extends Equatable {
  const ContactUpdateEvent();

  @override
  List<Object?> get props => [];
}

class UpdateContactInfo extends ContactUpdateEvent {
  final Map<String, dynamic> contactData;

  const UpdateContactInfo({required this.contactData});

  @override
  List<Object?> get props => [contactData];
}

class CreateContact extends ContactUpdateEvent {
  final String type;
  final String? label;
  final String value;
  final bool isPrimary;
  final bool isVerified;

  const CreateContact({
    required this.type,
    this.label,
    required this.value,
    this.isPrimary = false,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [type, label, value, isPrimary, isVerified];
}

class UpdateContact extends ContactUpdateEvent {
  final int contactId;
  final String? type;
  final String? label;
  final String? value;
  final bool? isPrimary;
  final bool? isVerified;

  const UpdateContact({
    required this.contactId,
    this.type,
    this.label,
    this.value,
    this.isPrimary,
    this.isVerified,
  });

  @override
  List<Object?> get props => [contactId, type, label, value, isPrimary, isVerified];
}

class DeleteContact extends ContactUpdateEvent {
  final int contactId;

  const DeleteContact({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}
