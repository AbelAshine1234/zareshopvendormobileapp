import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  bool _isPasswordVisible = false;
  String? _resetToken; // Store reset token for password reset

  AuthBloc() : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<CheckAuthenticationStatus>(_onCheckAuthenticationStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      // Call login API
      final result = await ApiService.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );
      
      if (result['success'] == true) {
        // Login successful
        emit(const AuthSuccess());
      } else {
        // Login failed
        emit(AuthError(message: result['error'] ?? 'Login failed'));
        emit(AuthInitial(isPasswordVisible: _isPasswordVisible));
      }
    } catch (e) {
      emit(AuthError(message: 'Network error: ${e.toString()}'));
      emit(AuthInitial(isPasswordVisible: _isPasswordVisible));
    }
  }

  void _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) {
    emit(const AuthSignupRequested());
  }

  void _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      // Call forgot password API to send OTP
      final result = await ApiService.forgotPassword(
        phoneNumber: event.phoneNumber,
      );
      
      if (result['success'] == true) {
        emit(ForgotPasswordOtpSent(phoneNumber: event.phoneNumber));
      } else {
        emit(AuthError(message: result['error'] ?? 'Failed to send OTP'));
        emit(const ForgotPasswordInitial());
      }
    } catch (e) {
      emit(AuthError(message: 'Network error: ${e.toString()}'));
      emit(const ForgotPasswordInitial());
    }
  }

  void _onResetPasswordRequested(
      ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    try {
      // First, verify the OTP and get reset token
      final verifyResult = await ApiService.verifyResetOtp(
        phoneNumber: event.phoneNumber,
        code: event.otp,
      );
      
      if (verifyResult['success'] != true) {
        emit(AuthError(message: verifyResult['error'] ?? 'Invalid OTP'));
        emit(ForgotPasswordOtpSent(phoneNumber: event.phoneNumber));
        return;
      }
      
      // Get reset token from response
      _resetToken = verifyResult['data']['reset_token'];
      
      if (_resetToken == null) {
        emit(const AuthError(message: 'Failed to get reset token'));
        emit(ForgotPasswordOtpSent(phoneNumber: event.phoneNumber));
        return;
      }
      
      // Now reset the password
      final resetResult = await ApiService.resetPassword(
        token: _resetToken!,
        newPassword: event.newPassword,
      );
      
      if (resetResult['success'] == true) {
        emit(const ForgotPasswordSuccess());
      } else {
        emit(AuthError(message: resetResult['error'] ?? 'Password reset failed'));
        emit(ForgotPasswordOtpSent(phoneNumber: event.phoneNumber));
      }
    } catch (e) {
      emit(AuthError(message: 'Network error: ${e.toString()}'));
      emit(ForgotPasswordOtpSent(phoneNumber: event.phoneNumber));
    }
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<AuthState> emit) {
    _isPasswordVisible = !_isPasswordVisible;
    emit(AuthInitial(isPasswordVisible: _isPasswordVisible));
  }

  void _onCheckAuthenticationStatus(
      CheckAuthenticationStatus event, Emitter<AuthState> emit) async {
    print('🔐 [AUTH_BLOC] CheckAuthenticationStatus event received');
    emit(const AuthChecking());
    print('🔐 [AUTH_BLOC] Emitted AuthChecking state');
    
    try {
      print('🔐 [AUTH_BLOC] Getting token from storage...');
      final token = await ApiService.getToken();
      print('🔐 [AUTH_BLOC] Token result: ${token != null ? "Found (${token.substring(0, 20)}...)" : "Not found"}');
      
      if (token != null) {
        print('🔐 [AUTH_BLOC] Token found, verifying with server...');
        // Verify token is still valid by getting current user
        final userResult = await ApiService.getCurrentUser();
        print('🔐 [AUTH_BLOC] User verification result: ${userResult['success']}');
        
        if (userResult['success'] == true) {
          print('🔐 [AUTH_BLOC] Token is valid, emitting AuthAuthenticated');
          emit(const AuthAuthenticated());
        } else {
          print('🔐 [AUTH_BLOC] Token is invalid, clearing and emitting AuthUnauthenticated');
          // Token is invalid, clear it
          await ApiService.removeToken();
          emit(const AuthUnauthenticated());
        }
      } else {
        print('🔐 [AUTH_BLOC] No token found, emitting AuthUnauthenticated');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('🔐 [AUTH_BLOC] Error checking auth: $e, emitting AuthUnauthenticated');
      // Error checking auth, assume unauthenticated
      emit(const AuthUnauthenticated());
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await ApiService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, assume unauthenticated
      emit(const AuthUnauthenticated());
    }
  }
}
