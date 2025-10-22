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

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

class AuthWaitingApproval extends AuthState {
  const AuthWaitingApproval();
}

class AuthLoginResponse extends AuthState {
  final Map<String, dynamic> data;
  const AuthLoginResponse(this.data);
}
