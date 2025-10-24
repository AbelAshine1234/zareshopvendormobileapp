import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/localization_service.dart';
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
      if (_userPhone == null || _userPhone!.isEmpty) {
        emit(OtpSendError(message: LocalizationService.instance.get('changePassword.phoneNumberNotFound')));
        return;
      }

      // Verify current password first
      final passwordValid = await _verifyCurrentPassword(event.currentPassword);
      if (!passwordValid) {
        emit(OtpSendError(message: LocalizationService.instance.get('changePassword.currentPasswordIncorrect')));
        return;
      }

      // Send OTP via API (using existing forgot password endpoint)
      final result = await ApiService.forgotPassword(
        phoneNumber: _userPhone!,
      );

      if (result['success'] == true) {
        _startOtpTimer();
        final maskedPhone = _maskPhoneNumber(_userPhone!);
        final message = LocalizationService.instance.get('changePassword.otpSentToPhone').replaceAll('{phone}', maskedPhone);
        emit(OtpSent(
          message: message,
          phoneNumber: _userPhone!,
        ));
      } else {
        final errorMessage = result['message'] ?? LocalizationService.instance.get('changePassword.failedToSendOtp');
        emit(OtpSendError(message: errorMessage));
      }
    } catch (e) {
      emit(OtpSendError(message: LocalizationService.instance.get('changePassword.failedToSendOtp')));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<ChangePasswordState> emit) async {
    emit(OtpVerifying());
    
    try {
      if (_userPhone == null) {
        emit(OtpVerifyError(message: LocalizationService.instance.get('changePassword.phoneNumberNotFoundResend')));
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
        emit(OtpVerified(message: LocalizationService.instance.get('changePassword.otpVerifiedSuccess')));
      } else {
        final errorMessage = result['error'] ?? LocalizationService.instance.get('changePassword.invalidOtpMessage');
        emit(OtpVerifyError(message: errorMessage));
      }
    } catch (e) {
      emit(OtpVerifyError(message: LocalizationService.instance.get('changePassword.failedToVerifyOtp')));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<ChangePasswordState> emit) async {
    emit(PasswordChanging());
    
    try {
      if (_resetToken == null) {
        emit(PasswordChangeError(message: LocalizationService.instance.get('changePassword.resetTokenNotFound')));
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
        emit(PasswordChanged(message: LocalizationService.instance.get('changePassword.passwordChangedSuccess')));
      } else {
        final errorMessage = result['error'] ?? LocalizationService.instance.get('changePassword.failedToChangePassword');
        emit(PasswordChangeError(message: errorMessage));
      }
    } catch (e) {
      emit(PasswordChangeError(message: LocalizationService.instance.get('changePassword.failedToChangePasswordRetry')));
    }
  }

  Future<void> _onResendOtp(ResendOtp event, Emitter<ChangePasswordState> emit) async {
    if (_userPhone == null) {
      emit(OtpSendError(message: LocalizationService.instance.get('changePassword.phoneNumberNotFound')));
      return;
    }

    try {
      final result = await ApiService.forgotPassword(
        phoneNumber: _userPhone!,
      );

      if (result['success'] == true) {
        _startOtpTimer();
        final maskedPhone = _maskPhoneNumber(_userPhone!);
        final message = LocalizationService.instance.get('changePassword.otpSentToPhone').replaceAll('{phone}', maskedPhone);
        emit(OtpSent(
          message: message,
          phoneNumber: _userPhone!,
        ));
      } else {
        final errorMessage = result['error'] ?? LocalizationService.instance.get('changePassword.failedToSendOtp');
        emit(OtpSendError(message: errorMessage));
      }
    } catch (e) {
      emit(OtpSendError(message: LocalizationService.instance.get('changePassword.failedToSendOtp')));
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
