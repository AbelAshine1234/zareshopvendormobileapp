import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import 'contact_update_event.dart';
import 'contact_update_state.dart';

class ContactUpdateBloc extends Bloc<ContactUpdateEvent, ContactUpdateState> {
  final ApiService _apiService;

  ContactUpdateBloc({required ApiService apiService})
      : _apiService = apiService,
        super(ContactUpdateInitial()) {
    on<UpdateContactInfo>(_onUpdateContactInfo);
    on<CreateContact>(_onCreateContact);
    on<UpdateContact>(_onUpdateContact);
    on<DeleteContact>(_onDeleteContact);
  }

  Future<void> _onUpdateContactInfo(
    UpdateContactInfo event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      // Get JWT token
      final token = await ApiService.getToken();
      if (token == null) {
        emit(ContactUpdateError(message: 'No authentication token found'));
        return;
      }

      // Update vendor info with contact data
      final result = await _apiService.updateVendorInfo(
        token: token,
        name: event.contactData['name'],
        description: event.contactData['description'],
      );

      if (result['success'] == true) {
        emit(ContactUpdateSuccess(message: 'Contact information updated successfully'));
      } else {
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to update contact information'));
      }
    } catch (e) {
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onCreateContact(
    CreateContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      // Get JWT token
      final token = await ApiService.getToken();
      if (token == null) {
        emit(ContactUpdateError(message: 'No authentication token found'));
        return;
      }

      // Create contact via API
      final result = await _apiService.createVendorContact(
        token: token,
        type: event.type,
        label: event.label,
        value: event.value,
        isPrimary: event.isPrimary,
        isVerified: event.isVerified,
      );

      if (result['success'] == true) {
        emit(ContactUpdateSuccess(message: 'Contact created successfully'));
      } else {
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to create contact'));
      }
    } catch (e) {
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContact(
    UpdateContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      // Get JWT token
      final token = await ApiService.getToken();
      if (token == null) {
        emit(ContactUpdateError(message: 'No authentication token found'));
        return;
      }

      // Update contact via API
      final result = await _apiService.updateVendorContact(
        token: token,
        contactId: event.contactId,
        type: event.type,
        label: event.label,
        value: event.value,
        isPrimary: event.isPrimary,
        isVerified: event.isVerified,
      );

      if (result['success'] == true) {
        emit(ContactUpdateSuccess(message: 'Contact updated successfully'));
      } else {
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to update contact'));
      }
    } catch (e) {
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      // Get JWT token
      final token = await ApiService.getToken();
      if (token == null) {
        emit(ContactUpdateError(message: 'No authentication token found'));
        return;
      }

      // Delete contact via API
      final result = await _apiService.deleteVendorContact(
        token: token,
        contactId: event.contactId,
      );

      if (result['success'] == true) {
        emit(ContactUpdateSuccess(message: 'Contact deleted successfully'));
      } else {
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to delete contact'));
      }
    } catch (e) {
      emit(ContactUpdateError(message: e.toString()));
    }
  }
}
