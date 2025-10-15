abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  final bool isPasswordVisible;

  const AuthInitial({this.isPasswordVisible = false});
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthSignupRequested extends AuthState {
  const AuthSignupRequested();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}

class ForgotPasswordInitial extends AuthState {
  const ForgotPasswordInitial();
}

class ForgotPasswordOtpSent extends AuthState {
  final String phoneNumber;

  const ForgotPasswordOtpSent({required this.phoneNumber});
}

class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}
