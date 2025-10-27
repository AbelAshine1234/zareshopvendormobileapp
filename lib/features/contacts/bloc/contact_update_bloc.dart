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
      print('🔄 [CONTACT_UPDATE_BLOC] Updating contact info...');
      
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
        print('✅ [CONTACT_UPDATE_BLOC] Contact info updated successfully');
        emit(ContactUpdateSuccess(message: 'Contact information updated successfully'));
      } else {
        print('❌ [CONTACT_UPDATE_BLOC] Failed to update contact info: ${result['error']}');
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to update contact information'));
      }
    } catch (e) {
      print('❌ [CONTACT_UPDATE_BLOC] Error updating contact info: $e');
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onCreateContact(
    CreateContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      print('🔄 [CONTACT_UPDATE_BLOC] Creating contact...');
      
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
        print('✅ [CONTACT_UPDATE_BLOC] Contact created successfully');
        emit(ContactUpdateSuccess(message: 'Contact created successfully'));
      } else {
        print('❌ [CONTACT_UPDATE_BLOC] Failed to create contact: ${result['error']}');
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to create contact'));
      }
    } catch (e) {
      print('❌ [CONTACT_UPDATE_BLOC] Error creating contact: $e');
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContact(
    UpdateContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      print('🔄 [CONTACT_UPDATE_BLOC] Updating contact...');
      
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
        print('✅ [CONTACT_UPDATE_BLOC] Contact updated successfully');
        emit(ContactUpdateSuccess(message: 'Contact updated successfully'));
      } else {
        print('❌ [CONTACT_UPDATE_BLOC] Failed to update contact: ${result['error']}');
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to update contact'));
      }
    } catch (e) {
      print('❌ [CONTACT_UPDATE_BLOC] Error updating contact: $e');
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactUpdateState> emit,
  ) async {
    emit(ContactUpdateLoading());
    
    try {
      print('🔄 [CONTACT_UPDATE_BLOC] Deleting contact...');
      
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
        print('✅ [CONTACT_UPDATE_BLOC] Contact deleted successfully');
        emit(ContactUpdateSuccess(message: 'Contact deleted successfully'));
      } else {
        print('❌ [CONTACT_UPDATE_BLOC] Failed to delete contact: ${result['error']}');
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to delete contact'));
      }
    } catch (e) {
      print('❌ [CONTACT_UPDATE_BLOC] Error deleting contact: $e');
      emit(ContactUpdateError(message: e.toString()));
    }
  }
}
