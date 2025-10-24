import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'vendor_info_event.dart';
import 'vendor_info_state.dart';

class VendorInfoBloc extends Bloc<VendorInfoEvent, VendorInfoState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;

  VendorInfoBloc({required ApiService apiService, required AuthBloc authBloc})
      : _apiService = apiService,
        _authBloc = authBloc,
        super(VendorInfoInitial()) {
    on<LoadVendorInfo>(_onLoadVendorInfo);
    on<RefreshVendorInfo>(_onRefreshVendorInfo);
  }

  Future<void> _onLoadVendorInfo(
    LoadVendorInfo event,
    Emitter<VendorInfoState> emit,
  ) async {
    emit(VendorInfoLoading());
    
    try {
      print('🔄 [VENDOR_BLOC] Loading vendor info...');
      print('🔄 [VENDOR_BLOC] Checking auth state for JWT token...');
      
      // Get current auth state
      final authState = _authBloc.state;
      print('🔄 [VENDOR_BLOC] Current auth state: ${authState.runtimeType}');
      
      String? token;
      if (authState is AuthLoginResponse) {
        token = authState.data['token'] as String?;
        print('🔄 [VENDOR_BLOC] Token from auth state: ${token != null ? 'Found' : 'Not found'}');
        if (token != null) {
          print('🔄 [VENDOR_BLOC] JWT token: ${token.substring(0, 20)}...');
        }
      }
      
      // Fallback to getting token from storage if not in auth state
      if (token == null) {
        print('🔄 [VENDOR_BLOC] Token not in auth state, checking storage...');
        token = await ApiService.getToken();
      }
      
      if (token == null) {
        print('❌ [VENDOR_BLOC] No JWT token found in auth state or storage');
        emit(VendorInfoError(message: 'No authentication token found'));
        return;
      }
      
      print('✅ [VENDOR_BLOC] JWT token found: ${token.substring(0, 20)}...');
      print('🔄 [VENDOR_BLOC] Sending JWT token with request...');
      
      final vendorInfo = await _apiService.getVendorCompleteInfo();
      print('✅ [VENDOR_BLOC] Vendor info loaded successfully: $vendorInfo');
      emit(VendorInfoLoaded(vendorInfo: vendorInfo));
    } catch (e) {
      print('❌ [VENDOR_BLOC] Error loading vendor info: $e');
      emit(VendorInfoError(message: e.toString()));
    }
  }

  Future<void> _onRefreshVendorInfo(
    RefreshVendorInfo event,
    Emitter<VendorInfoState> emit,
  ) async {
    add(LoadVendorInfo());
  }
}
