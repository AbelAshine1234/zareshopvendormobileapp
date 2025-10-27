import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'contacts_event.dart';
import 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;

  ContactsBloc({required ApiService apiService, required AuthBloc authBloc})
      : _apiService = apiService,
        _authBloc = authBloc,
        super(ContactsInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<LoadContactsByType>(_onLoadContactsByType);
    on<CreateContact>(_onCreateContact);
    on<CreateContactsBulk>(_onCreateContactsBulk);
    on<UpdateContact>(_onUpdateContact);
    on<SetContactAsPrimary>(_onSetContactAsPrimary);
    on<DeleteContact>(_onDeleteContact);
    on<RefreshContacts>(_onRefreshContacts);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());
    
    try {
      print('🔄 [CONTACTS_BLOC] Loading all contacts...');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactsError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.getVendorContacts(token: token);
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contacts loaded successfully');
        emit(ContactsLoaded(
          contacts: List<Map<String, dynamic>>.from(result['contacts'] ?? []),
          count: result['count'] ?? 0,
        ));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to load contacts: ${result['error']}');
        emit(ContactsError(message: result['error'] ?? 'Failed to load contacts'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error loading contacts: $e');
      emit(ContactsError(message: e.toString()));
    }
  }

  Future<void> _onLoadContactsByType(
    LoadContactsByType event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());
    
    try {
      print('🔄 [CONTACTS_BLOC] Loading contacts by type: ${event.type}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactsError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.getVendorContactsByType(
        token: token,
        type: event.type,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contacts by type loaded successfully');
        emit(ContactsLoaded(
          contacts: List<Map<String, dynamic>>.from(result['contacts'] ?? []),
          count: result['count'] ?? 0,
          type: result['type'],
        ));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to load contacts by type: ${result['error']}');
        emit(ContactsError(message: result['error'] ?? 'Failed to load contacts by type'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error loading contacts by type: $e');
      emit(ContactsError(message: e.toString()));
    }
  }

  Future<void> _onCreateContact(
    CreateContact event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactCreating());
    
    try {
      print('🔄 [CONTACTS_BLOC] Creating contact...');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactCreateError(message: 'No authentication token found'));
        return;
      }
      
      final contactData = {
        'type': event.type,
        'label': event.label,
        'value': event.value,
        'is_primary': event.isPrimary,
        'is_verified': event.isVerified,
      };
      
      final result = await ApiService.createVendorContact(
        token: token,
        contactData: contactData,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contact created successfully');
        emit(ContactCreated(contact: result['contact']));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to create contact: ${result['error']}');
        emit(ContactCreateError(message: result['error'] ?? 'Failed to create contact'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error creating contact: $e');
      emit(ContactCreateError(message: e.toString()));
    }
  }

  Future<void> _onCreateContactsBulk(
    CreateContactsBulk event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsBulkCreating());
    
    try {
      print('🔄 [CONTACTS_BLOC] Creating contacts in bulk...');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactsBulkCreateError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.createVendorContactsBulk(
        token: token,
        contacts: event.contacts,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contacts created in bulk successfully');
        emit(ContactsBulkCreated(
          contacts: List<Map<String, dynamic>>.from(result['contacts'] ?? []),
          count: result['count'] ?? 0,
        ));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to create contacts in bulk: ${result['error']}');
        emit(ContactsBulkCreateError(message: result['error'] ?? 'Failed to create contacts in bulk'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error creating contacts in bulk: $e');
      emit(ContactsBulkCreateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContact(
    UpdateContact event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactUpdating());
    
    try {
      print('🔄 [CONTACTS_BLOC] Updating contact: ${event.contactId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactUpdateError(message: 'No authentication token found'));
        return;
      }
      
      final updateData = <String, dynamic>{};
      if (event.label != null) updateData['label'] = event.label;
      if (event.value != null) updateData['value'] = event.value;
      if (event.isPrimary != null) updateData['is_primary'] = event.isPrimary;
      if (event.isVerified != null) updateData['is_verified'] = event.isVerified;
      
      final result = await ApiService.updateVendorContact(
        token: token,
        contactId: event.contactId,
        updateData: updateData,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contact updated successfully');
        emit(ContactUpdated(contact: result['contact']));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to update contact: ${result['error']}');
        emit(ContactUpdateError(message: result['error'] ?? 'Failed to update contact'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error updating contact: $e');
      emit(ContactUpdateError(message: e.toString()));
    }
  }

  Future<void> _onSetContactAsPrimary(
    SetContactAsPrimary event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactSettingPrimary());
    
    try {
      print('🔄 [CONTACTS_BLOC] Setting contact as primary: ${event.contactId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactSetPrimaryError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.setVendorContactAsPrimary(
        token: token,
        contactId: event.contactId,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contact set as primary successfully');
        emit(ContactSetAsPrimary(contact: result['contact']));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to set contact as primary: ${result['error']}');
        emit(ContactSetPrimaryError(message: result['error'] ?? 'Failed to set contact as primary'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error setting contact as primary: $e');
      emit(ContactSetPrimaryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactDeleting());
    
    try {
      print('🔄 [CONTACTS_BLOC] Deleting contact: ${event.contactId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(ContactDeleteError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.deleteVendorContact(
        token: token,
        contactId: event.contactId,
      );
      
      if (result['success'] == true) {
        print('✅ [CONTACTS_BLOC] Contact deleted successfully');
        emit(ContactDeleted(contactId: event.contactId));
      } else {
        print('❌ [CONTACTS_BLOC] Failed to delete contact: ${result['error']}');
        emit(ContactDeleteError(message: result['error'] ?? 'Failed to delete contact'));
      }
    } catch (e) {
      print('❌ [CONTACTS_BLOC] Error deleting contact: $e');
      emit(ContactDeleteError(message: e.toString()));
    }
  }

  Future<void> _onRefreshContacts(
    RefreshContacts event,
    Emitter<ContactsState> emit,
  ) async {
    add(LoadContacts());
  }

  Future<String?> _getToken() async {
    final authState = _authBloc.state;
    String? token;
    
    if (authState is AuthLoginResponse) {
      token = authState.data['token'] as String?;
    }
    
    if (token == null) {
      token = await ApiService.getToken();
    }
    
    return token;
  }
}
