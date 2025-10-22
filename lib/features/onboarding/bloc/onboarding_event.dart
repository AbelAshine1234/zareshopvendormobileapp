import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize onboarding with mock data (for testing)
class InitializeOnboarding extends OnboardingEvent {
  final bool useMockData;

  const InitializeOnboarding({this.useMockData = false});

  @override
  List<Object?> get props => [useMockData];
}

/// Event to move to the next step
class NextStep extends OnboardingEvent {
  const NextStep();
}

/// Event to move to the previous step
class PreviousStep extends OnboardingEvent {
  const PreviousStep();
}

/// Event to jump to a specific step
class GoToStep extends OnboardingEvent {
  final int step;

  const GoToStep(this.step);

  @override
  List<Object?> get props => [step];
}

// Step 0: Phone Number & Password Events
class UpdatePhoneNumber extends OnboardingEvent {
  final String phoneNumber;
  const UpdatePhoneNumber(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class UpdatePassword extends OnboardingEvent {
  final String password;
  const UpdatePassword(this.password);
  @override
  List<Object?> get props => [password];
}

// Step 1: OTP Events
class UpdateOTP extends OnboardingEvent {
  final String otp;
  const UpdateOTP(this.otp);
  @override
  List<Object?> get props => [otp];
}

class ResendOTP extends OnboardingEvent {
  const ResendOTP();
}

// Step 2: Basic Info Events
class UpdateBusinessName extends OnboardingEvent {
  final String businessName;
  const UpdateBusinessName(this.businessName);
  @override
  List<Object?> get props => [businessName];
}

class UpdateBusinessDescription extends OnboardingEvent {
  final String businessDescription;
  const UpdateBusinessDescription(this.businessDescription);
  @override
  List<Object?> get props => [businessDescription];
}

class UpdateCategories extends OnboardingEvent {
  final List<String> categories;
  const UpdateCategories(this.categories);
  @override
  List<Object?> get props => [categories];
}

// Step 3: Shipping Address Events
class UpdateCity extends OnboardingEvent {
  final String city;
  const UpdateCity(this.city);
  @override
  List<Object?> get props => [city];
}

class UpdateSubcity extends OnboardingEvent {
  final String subcity;
  const UpdateSubcity(this.subcity);
  @override
  List<Object?> get props => [subcity];
}

class UpdateWoreda extends OnboardingEvent {
  final String woreda;
  const UpdateWoreda(this.woreda);
  @override
  List<Object?> get props => [woreda];
}

class UpdateState extends OnboardingEvent {
  final String state;
  const UpdateState(this.state);
  @override
  List<Object?> get props => [state];
}

// Step 4: Documents Events
class UpdateBusinessLicense extends OnboardingEvent {
  final dynamic file;
  const UpdateBusinessLicense(this.file);
  @override
  List<Object?> get props => [file];
}

class UpdateCoverImage extends OnboardingEvent {
  final dynamic file;
  const UpdateCoverImage(this.file);
  @override
  List<Object?> get props => [file];
}

// Step 5: Payout Events
class UpdatePayoutMethod extends OnboardingEvent {
  final String payoutMethod; // 'bank_account' or 'wallet'
  const UpdatePayoutMethod(this.payoutMethod);
  @override
  List<Object?> get props => [payoutMethod];
}

class UpdateBankAccount extends OnboardingEvent {
  final String? accountHolderName;
  final String? bankName;
  final String? bankAccountNumber;
  const UpdateBankAccount({this.accountHolderName, this.bankName, this.bankAccountNumber});
  @override
  List<Object?> get props => [accountHolderName, bankName, bankAccountNumber];
}

class UpdateMobileWallet extends OnboardingEvent {
  final String mobileWalletNumber;
  const UpdateMobileWallet(this.mobileWalletNumber);
  @override
  List<Object?> get props => [mobileWalletNumber];
}

class UpdatePayoutCheckboxes extends OnboardingEvent {
  final bool? confirmDetailsCheck;
  final bool? agreeTermsCheck;
  final bool? authorizePayoutCheck;
  const UpdatePayoutCheckboxes({
    this.confirmDetailsCheck,
    this.agreeTermsCheck,
    this.authorizePayoutCheck,
  });
  @override
  List<Object?> get props => [confirmDetailsCheck, agreeTermsCheck, authorizePayoutCheck];
}

// Step 6: Subscription Events
class UpdateSubscription extends OnboardingEvent {
  final int subscriptionId;
  const UpdateSubscription(this.subscriptionId);
  @override
  List<Object?> get props => [subscriptionId];
}

class ToggleTermsAgreement extends OnboardingEvent {
  final bool agreed;
  const ToggleTermsAgreement(this.agreed);
  @override
  List<Object?> get props => [agreed];
}

// Completion Events
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class RetryVendorSubmission extends OnboardingEvent {
  const RetryVendorSubmission();
}

class RetryWithNewBusinessName extends OnboardingEvent {
  final String newBusinessName;
  const RetryWithNewBusinessName(this.newBusinessName);
  @override
  List<Object?> get props => [newBusinessName];
}