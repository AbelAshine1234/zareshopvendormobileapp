abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginRequested({
    required this.phoneNumber,
    required this.password,
  });
}

class SignupRequested extends AuthEvent {
  const SignupRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String phoneNumber;

  const ForgotPasswordRequested({required this.phoneNumber});
}

class ResetPasswordRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;
  final String newPassword;

  const ResetPasswordRequested({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
  });
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}
