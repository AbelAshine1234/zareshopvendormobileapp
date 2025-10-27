import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../models/address_model.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;

  AddressBloc({required ApiService apiService, required AuthBloc authBloc})
      : _apiService = apiService,
        _authBloc = authBloc,
        super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<LoadVendorAddresses>(_onLoadVendorAddresses);
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetPrimaryAddress>(_onSetPrimaryAddress);
    on<RefreshAddresses>(_onRefreshAddresses);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    
    try {
      print('🔄 [ADDRESS_BLOC] Loading my addresses...');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(AddressError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.getMyShippingAddresses(token: token);
      
      if (result['success'] == true) {
        print('✅ [ADDRESS_BLOC] My addresses loaded successfully');
        final addresses = (result['addresses'] as List)
            .map((json) => AddressModel.fromJson(json))
            .toList();
        
        emit(AddressesLoaded(
          addresses: addresses,
          page: 1,
          limit: addresses.length,
          total: addresses.length,
        ));
      } else {
        print('❌ [ADDRESS_BLOC] Failed to load my addresses: ${result['error']}');
        emit(AddressError(message: result['error'] ?? 'Failed to load my addresses'));
      }
    } catch (e) {
      print('❌ [ADDRESS_BLOC] Error loading my addresses: $e');
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> _onLoadVendorAddresses(
    LoadVendorAddresses event,
    Emitter<AddressState> emit,
  ) async {
    // For vendor endpoints, we use the same "my addresses" endpoint
    // since vendors can only access their own addresses
    add(LoadAddresses());
  }

  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressCreating());
    
    try {
      print('🔄 [ADDRESS_BLOC] Creating my address...');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(AddressCreateError(message: 'No authentication token found'));
        return;
      }
      
      final addressData = {
        'address_line1': event.addressLine1,
        'address_line2': event.addressLine2,
        'city': event.city,
        'state': event.state,
        'region': event.region,
        'subcity': event.subcity,
        'woreda': event.woreda,
        'kebele': event.kebele,
        'postal_code': event.postalCode,
        'country': event.country,
        'is_primary': event.isPrimary,
      };
      
      final result = await ApiService.createMyShippingAddress(
        token: token,
        addressData: addressData,
      );
      
      if (result['success'] == true) {
        print('✅ [ADDRESS_BLOC] My address created successfully');
        emit(AddressCreated(address: AddressModel.fromJson(result['address'])));
      } else {
        print('❌ [ADDRESS_BLOC] Failed to create my address: ${result['error']}');
        emit(AddressCreateError(message: result['error'] ?? 'Failed to create my address'));
      }
    } catch (e) {
      print('❌ [ADDRESS_BLOC] Error creating my address: $e');
      emit(AddressCreateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressUpdating());
    
    try {
      print('🔄 [ADDRESS_BLOC] Updating my address: ${event.addressId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(AddressUpdateError(message: 'No authentication token found'));
        return;
      }
      
      final updateData = <String, dynamic>{};
      if (event.addressLine1 != null) updateData['address_line1'] = event.addressLine1;
      if (event.addressLine2 != null) updateData['address_line2'] = event.addressLine2;
      if (event.city != null) updateData['city'] = event.city;
      if (event.state != null) updateData['state'] = event.state;
      if (event.region != null) updateData['region'] = event.region;
      if (event.subcity != null) updateData['subcity'] = event.subcity;
      if (event.woreda != null) updateData['woreda'] = event.woreda;
      if (event.kebele != null) updateData['kebele'] = event.kebele;
      if (event.postalCode != null) updateData['postal_code'] = event.postalCode;
      if (event.country != null) updateData['country'] = event.country;
      if (event.isPrimary != null) updateData['is_primary'] = event.isPrimary;
      
      final result = await ApiService.updateMyShippingAddress(
        token: token,
        addressId: event.addressId,
        updateData: updateData,
      );
      
      if (result['success'] == true) {
        print('✅ [ADDRESS_BLOC] My address updated successfully');
        emit(AddressUpdated(address: AddressModel.fromJson(result['address'])));
      } else {
        print('❌ [ADDRESS_BLOC] Failed to update my address: ${result['error']}');
        emit(AddressUpdateError(message: result['error'] ?? 'Failed to update my address'));
      }
    } catch (e) {
      print('❌ [ADDRESS_BLOC] Error updating my address: $e');
      emit(AddressUpdateError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressDeleting());
    
    try {
      print('🔄 [ADDRESS_BLOC] Deleting my address: ${event.addressId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(AddressDeleteError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.deleteMyShippingAddress(
        token: token,
        addressId: event.addressId,
      );
      
      if (result['success'] == true) {
        print('✅ [ADDRESS_BLOC] My address deleted successfully');
        emit(AddressDeleted(addressId: event.addressId));
      } else {
        print('❌ [ADDRESS_BLOC] Failed to delete my address: ${result['error']}');
        emit(AddressDeleteError(message: result['error'] ?? 'Failed to delete my address'));
      }
    } catch (e) {
      print('❌ [ADDRESS_BLOC] Error deleting my address: $e');
      emit(AddressDeleteError(message: e.toString()));
    }
  }

  Future<void> _onSetPrimaryAddress(
    SetPrimaryAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressSettingPrimary());
    
    try {
      print('🔄 [ADDRESS_BLOC] Setting my address as primary: ${event.addressId}');
      
      // Get JWT token
      final token = await _getToken();
      if (token == null) {
        emit(AddressSetPrimaryError(message: 'No authentication token found'));
        return;
      }
      
      final result = await ApiService.setMyPrimaryShippingAddress(
        token: token,
        addressId: event.addressId,
      );
      
      if (result['success'] == true) {
        print('✅ [ADDRESS_BLOC] My address set as primary successfully');
        emit(AddressSetAsPrimary(address: AddressModel.fromJson(result['address'])));
      } else {
        print('❌ [ADDRESS_BLOC] Failed to set my address as primary: ${result['error']}');
        emit(AddressSetPrimaryError(message: result['error'] ?? 'Failed to set my address as primary'));
      }
    } catch (e) {
      print('❌ [ADDRESS_BLOC] Error setting my address as primary: $e');
      emit(AddressSetPrimaryError(message: e.toString()));
    }
  }

  Future<void> _onRefreshAddresses(
    RefreshAddresses event,
    Emitter<AddressState> emit,
  ) async {
    add(LoadAddresses());
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
