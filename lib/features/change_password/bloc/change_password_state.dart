abstract class ChangePasswordState {}

// Initial state
class ChangePasswordInitial extends ChangePasswordState {}

// Loading states
class ChangePasswordLoading extends ChangePasswordState {}

class OtpSending extends ChangePasswordState {}

class OtpVerifying extends ChangePasswordState {}

class PasswordChanging extends ChangePasswordState {}

// Success states
class OtpSent extends ChangePasswordState {
  final String message;
  final String phoneNumber;

  OtpSent({required this.message, required this.phoneNumber});
}

class OtpVerified extends ChangePasswordState {
  final String message;

  OtpVerified({required this.message});
}

class PasswordChanged extends ChangePasswordState {
  final String message;

  PasswordChanged({required this.message});
}

// Error states
class ChangePasswordError extends ChangePasswordState {
  final String message;

  ChangePasswordError({required this.message});
}

class OtpSendError extends ChangePasswordState {
  final String message;

  OtpSendError({required this.message});
}

class OtpVerifyError extends ChangePasswordState {
  final String message;

  OtpVerifyError({required this.message});
}

class PasswordChangeError extends ChangePasswordState {
  final String message;

  PasswordChangeError({required this.message});
}
