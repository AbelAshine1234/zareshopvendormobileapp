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
      // Get current auth state
      final authState = _authBloc.state;
      
      String? token;
      if (authState is AuthLoginResponse) {
        token = authState.data['token'] as String?;
      }
      
      // Fallback to getting token from storage if not in auth state
      if (token == null) {
        token = await ApiService.getToken();
      }
      
      if (token == null) {
        emit(VendorInfoError(message: 'No authentication token found'));
        return;
      }
      
      final vendorInfo = await _apiService.getVendorCompleteInfo();
      emit(VendorInfoLoaded(vendorInfo: vendorInfo));
    } catch (e) {
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
