import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/user_service.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ApiService _apiService;
  final StorageService _storageService;
  
  String? _resetToken;
  String? _userPhone;
  Timer? _otpTimer;
  int _otpTimerSeconds = 0;

  ChangePasswordBloc({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService,
       super(ChangePasswordInitial()) {
    
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<ChangePassword>(_onChangePassword);
    on<ResendOtp>(_onResendOtp);
    on<ResetChangePasswordState>(_onResetState);
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }

  Future<void> _onSendOtp(SendOtp event, Emitter<ChangePasswordState> emit) async {
    emit(OtpSending());
    
    try {
      // Get phone number from global user service
      _userPhone = await UserService.instance.getPhoneNumber();
      print('📱 [CHANGE_PASSWORD_BLOC] Retrieved phone number: $_userPhone');
      if (_userPhone == null || _userPhone!.isEmpty) {
        print('❌ [CHANGE_PASSWORD_BLOC] Phone number is null or empty');
        emit(OtpSendError(message: 'Phone number not found. Please login again.'));
        return;
      }

      // Verify current password first
      final passwordValid = await _verifyCurrentPassword(event.currentPassword);
      if (!passwordValid) {
        emit(OtpSendError(message: 'Current password is incorrect'));
        return;
      }

      // Send OTP via API (using existing forgot password endpoint)
      final result = await ApiService.forgotPassword(
        phoneNumber: _userPhone!,
      );

      if (result['success'] == true) {
        _startOtpTimer();
        emit(OtpSent(
          message: 'OTP sent to ${_maskPhoneNumber(_userPhone!)}',
          phoneNumber: _userPhone!,
        ));
      } else {
        emit(OtpSendError(message: result['message'] ?? 'Failed to send OTP'));
      }
    } catch (e) {
      print('Error sending OTP: $e');
      emit(OtpSendError(message: 'Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<ChangePasswordState> emit) async {
    emit(OtpVerifying());
    
    try {
      if (_userPhone == null) {
        emit(OtpVerifyError(message: 'Phone number not found. Please request a new OTP.'));
        return;
      }

      // Verify OTP with server
      final result = await ApiService.verifyResetOtp(
        phoneNumber: _userPhone!,
        code: event.otp,
      );

      if (result['success'] == true) {
        // Store the reset token from the response
        final data = result['data'] as Map<String, dynamic>?;
        _resetToken = data?['token'] ?? data?['reset_token'];
        _otpTimer?.cancel();
        emit(OtpVerified(message: 'OTP verified successfully!'));
      } else {
        emit(OtpVerifyError(message: result['error'] ?? 'Invalid OTP. Please try again.'));
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      emit(OtpVerifyError(message: 'Failed to verify OTP. Please try again.'));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<ChangePasswordState> emit) async {
    emit(PasswordChanging());
    
    try {
      if (_resetToken == null) {
        emit(PasswordChangeError(message: 'Reset token not found. Please verify OTP again.'));
        return;
      }

      // Reset password using the reset token
      final result = await ApiService.resetPassword(
        token: _resetToken!,
        newPassword: event.newPassword,
      );

      if (result['success'] == true) {
        _resetToken = null;
        _otpTimer?.cancel();
        emit(PasswordChanged(message: 'Password changed successfully!'));
      } else {
        emit(PasswordChangeError(message: result['error'] ?? 'Failed to change password'));
      }
    } catch (e) {
      print('Error changing password: $e');
      emit(PasswordChangeError(message: 'Failed to change password. Please try again.'));
    }
  }

  Future<void> _onResendOtp(ResendOtp event, Emitter<ChangePasswordState> emit) async {
    if (_userPhone == null) {
      emit(OtpSendError(message: 'Phone number not available'));
      return;
    }

    try {
      final result = await ApiService.forgotPassword(
        phoneNumber: _userPhone!,
      );

      if (result['success'] == true) {
        _startOtpTimer();
        emit(OtpSent(
          message: 'OTP resent to ${_maskPhoneNumber(_userPhone!)}',
          phoneNumber: _userPhone!,
        ));
      } else {
        emit(OtpSendError(message: result['error'] ?? 'Failed to resend OTP'));
      }
    } catch (e) {
      print('Error resending OTP: $e');
      emit(OtpSendError(message: 'Failed to resend OTP. Please try again.'));
    }
  }

  void _onResetState(ResetChangePasswordState event, Emitter<ChangePasswordState> emit) {
    _resetToken = null;
    _userPhone = null;
    _otpTimer?.cancel();
    _otpTimerSeconds = 0;
    emit(ChangePasswordInitial());
  }

  Future<Map<String, dynamic>?> _getUserInfo() async {
    try {
      // Get user data from global user service
      final userData = await UserService.instance.getUserData();
      if (userData != null) {
        return userData;
      }
      
      // Fallback to API call if not available locally
      final token = await _storageService.getToken();
      if (token == null) return null;

      final result = await _apiService.getVendorCompleteInfo();
      return result;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  Future<bool> _verifyCurrentPassword(String password) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      // Use login endpoint to verify current password
      final result = await ApiService.login(
        phoneNumber: _userPhone ?? '',
        password: password,
      );

      return result['success'] == true;
    } catch (e) {
      print('Error verifying current password: $e');
      return false;
    }
  }


  String _maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final start = phone.substring(0, 3);
    final end = phone.substring(phone.length - 2);
    final middle = '*' * (phone.length - 5);
    return '$start$middle$end';
  }

  void _startOtpTimer() {
    _otpTimerSeconds = 60;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _otpTimerSeconds--;
      if (_otpTimerSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  int get otpTimerSeconds => _otpTimerSeconds;
  bool get isOtpTimerActive => _otpTimerSeconds > 0;
}
