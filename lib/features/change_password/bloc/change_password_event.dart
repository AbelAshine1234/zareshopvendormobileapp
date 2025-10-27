abstract class ChangePasswordEvent {}

// Send OTP to user's phone
class SendOtp extends ChangePasswordEvent {
  final String currentPassword;

  SendOtp({required this.currentPassword});
}

// Verify OTP
class VerifyOtp extends ChangePasswordEvent {
  final String otp;

  VerifyOtp({required this.otp});
}

// Change password
class ChangePassword extends ChangePasswordEvent {
  final String newPassword;

  ChangePassword({required this.newPassword});
}

// Resend OTP
class ResendOtp extends ChangePasswordEvent {}

// Reset state
class ResetChangePasswordState extends ChangePasswordEvent {}
