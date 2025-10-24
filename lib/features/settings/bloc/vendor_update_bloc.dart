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

  VendorUpdateBloc({required ApiService apiService, required AuthBloc authBloc})
      : _apiService = apiService,
        _authBloc = authBloc,
        super(VendorUpdateInitial()) {
    on<UpdateVendorCoverImage>(_onUpdateVendorCoverImage);
    on<UpdateVendorInfo>(_onUpdateVendorInfo);
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
        print('✅ [VENDOR_UPDATE_BLOC] Cover image updated successfully');
        emit(VendorUpdateSuccess(updatedVendor: result['vendor']));
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
}
