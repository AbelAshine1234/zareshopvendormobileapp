import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'vendor_update_event.dart';
import 'vendor_update_state.dart';

class VendorUpdateBloc extends Bloc<VendorUpdateEvent, VendorUpdateState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 60; // 60 attempts

  VendorUpdateBloc({required ApiService apiService, required AuthBloc authBloc})
      : _apiService = apiService,
        _authBloc = authBloc,
        super(VendorUpdateInitial()) {
    on<UpdateVendorCoverImage>(_onUpdateVendorCoverImage);
    on<UpdateVendorInfo>(_onUpdateVendorInfo);
    on<_PollingCheckEvent>(_onPollingCheck);
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onUpdateVendorCoverImage(
    UpdateVendorCoverImage event,
    Emitter<VendorUpdateState> emit,
  ) async {
    emit(VendorUpdateLoading());
    
    try {
      print('🔄 [VENDOR_UPDATE_BLOC] Updating cover image...');
      print('🔄 [VENDOR_UPDATE_BLOC] Image path: ${event.imagePath}');
      
      // Get JWT token from auth bloc
      final authState = _authBloc.state;
      String? token;
      
      if (authState is AuthLoginResponse) {
        token = authState.data['token'] as String?;
      }
      
      if (token == null) {
        token = await ApiService.getToken();
      }
      
      if (token == null) {
        print('❌ [VENDOR_UPDATE_BLOC] No JWT token found');
        emit(VendorUpdateError(message: 'No authentication token found'));
        return;
      }
      
      print('✅ [VENDOR_UPDATE_BLOC] JWT token found: ${token.substring(0, 20)}...');
      
      // Update vendor with cover image
      final result = await _apiService.updateVendorInfo(
        token: token,
        coverImagePath: event.imagePath,
      );
      
      if (result['success'] == true) {
        print('✅ [VENDOR_UPDATE_BLOC] Cover image updated successfully, starting polling...');
        // Start polling for Cloudinary URL
        _startPollingForCloudinaryUrl(emit);
      } else {
        print('❌ [VENDOR_UPDATE_BLOC] Failed to update cover image: ${result['error']}');
        emit(VendorUpdateError(message: result['error'] ?? 'Failed to update cover image'));
      }
    } catch (e) {
      print('❌ [VENDOR_UPDATE_BLOC] Error updating cover image: $e');
      emit(VendorUpdateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateVendorInfo(
    UpdateVendorInfo event,
    Emitter<VendorUpdateState> emit,
  ) async {
    emit(VendorUpdateLoading());
    
    try {
      print('🔄 [VENDOR_UPDATE_BLOC] Updating vendor info...');
      
      // Get JWT token from auth bloc
      final authState = _authBloc.state;
      String? token;
      
      if (authState is AuthLoginResponse) {
        token = authState.data['token'] as String?;
      }
      
      if (token == null) {
        token = await ApiService.getToken();
      }
      
      if (token == null) {
        print('❌ [VENDOR_UPDATE_BLOC] No JWT token found');
        emit(VendorUpdateError(message: 'No authentication token found'));
        return;
      }
      
      print('✅ [VENDOR_UPDATE_BLOC] JWT token found: ${token.substring(0, 20)}...');
      
      // Update vendor with provided info
      final result = await _apiService.updateVendorInfo(
        token: token,
        name: event.name,
        description: event.description,
        coverImagePath: event.coverImagePath,
        faydaImagePath: event.faydaImagePath,
        businessLicenseImagePath: event.businessLicenseImagePath,
      );
      
      if (result['success'] == true) {
        print('✅ [VENDOR_UPDATE_BLOC] Vendor info updated successfully');
        emit(VendorUpdateSuccess(updatedVendor: result['vendor']));
      } else {
        print('❌ [VENDOR_UPDATE_BLOC] Failed to update vendor info: ${result['error']}');
        emit(VendorUpdateError(message: result['error'] ?? 'Failed to update vendor info'));
      }
    } catch (e) {
      print('❌ [VENDOR_UPDATE_BLOC] Error updating vendor info: $e');
      emit(VendorUpdateError(message: e.toString()));
    }
  }

  void _startPollingForCloudinaryUrl(Emitter<VendorUpdateState> emit) {
    _pollingAttempts = 0;
    emit(VendorUpdatePolling(attempts: 0, maxAttempts: _maxPollingAttempts));
    
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _pollingAttempts++;
      
      // Use add() to trigger a new event instead of emit() directly
      add(_PollingCheckEvent());
    });
  }

  Future<void> _onPollingCheck(
    _PollingCheckEvent event,
    Emitter<VendorUpdateState> emit,
  ) async {
    try {
      print('🔄 [VENDOR_UPDATE_BLOC] Polling attempt $_pollingAttempts/$_maxPollingAttempts');
      
      // Fetch vendor info to check for Cloudinary URL
      final vendorInfo = await _apiService.getVendorCompleteInfo();
      final vendorData = vendorInfo['vendor'];
      
      if (vendorData != null) {
        final images = vendorData['images'];
        if (images != null && images['cover'] != null) {
          final coverImageUrl = images['cover']['image_url'] as String?;
          
          if (coverImageUrl != null && coverImageUrl.contains('cloudinary.com')) {
            // Success! Cloudinary URL found
            print('✅ [VENDOR_UPDATE_BLOC] Cloudinary URL found: $coverImageUrl');
            _pollingTimer?.cancel();
            emit(VendorUpdateSuccess(updatedVendor: vendorData));
            return;
          }
        }
      }
      
      // Update polling state with current attempts
      emit(VendorUpdatePolling(attempts: _pollingAttempts, maxAttempts: _maxPollingAttempts));
      
      // Check for timeout
      if (_pollingAttempts >= _maxPollingAttempts) {
        print('⏰ [VENDOR_UPDATE_BLOC] Polling timeout after $_maxPollingAttempts attempts');
        _pollingTimer?.cancel();
        emit(VendorUpdatePollingTimeout());
      }
    } catch (e) {
      print('❌ [VENDOR_UPDATE_BLOC] Error during polling: $e');
      // Continue polling on error, don't stop
    }
  }
}

// Private event for polling checks
class _PollingCheckEvent extends VendorUpdateEvent {}
