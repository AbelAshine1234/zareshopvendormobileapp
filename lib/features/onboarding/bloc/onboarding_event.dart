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

// Step 1: Phone Number Events
class UpdatePhoneNumber extends OnboardingEvent {
  final String phoneNumber;
  const UpdatePhoneNumber(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class UpdateVendorType extends OnboardingEvent {
  final String vendorType;
  const UpdateVendorType(this.vendorType);
  @override
  List<Object?> get props => [vendorType];
}

// Step 2: OTP Events
class UpdateOTP extends OnboardingEvent {
  final String otp;
  const UpdateOTP(this.otp);
  @override
  List<Object?> get props => [otp];
}

class ResendOTP extends OnboardingEvent {
  const ResendOTP();
}

// Step 3: Basic Info Events
class UpdateFullName extends OnboardingEvent {
  final String fullName;
  const UpdateFullName(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class UpdateBusinessName extends OnboardingEvent {
  final String businessName;
  const UpdateBusinessName(this.businessName);
  @override
  List<Object?> get props => [businessName];
}

class UpdateEmail extends OnboardingEvent {
  final String email;
  const UpdateEmail(this.email);
  @override
  List<Object?> get props => [email];
}

class UpdateLanguagePreference extends OnboardingEvent {
  final String languagePreference;
  const UpdateLanguagePreference(this.languagePreference);
  @override
  List<Object?> get props => [languagePreference];
}

class UpdateAddress extends OnboardingEvent {
  final String? street;
  final String? city;
  final String? region;
  final String? zone;
  
  const UpdateAddress({this.street, this.city, this.region, this.zone});
  
  @override
  List<Object?> get props => [street, city, region, zone];
}

class UpdateBusinessDescription extends OnboardingEvent {
  final String businessDescription;
  const UpdateBusinessDescription(this.businessDescription);
  @override
  List<Object?> get props => [businessDescription];
}

class UpdateCategory extends OnboardingEvent {
  final String category;
  const UpdateCategory(this.category);
  @override
  List<Object?> get props => [category];
}

// Step 4: Documents Events
class UpdateFaydaIdNumber extends OnboardingEvent {
  final String faydaIdNumber;
  const UpdateFaydaIdNumber(this.faydaIdNumber);
  @override
  List<Object?> get props => [faydaIdNumber];
}

class UpdateBusinessLicenseNumber extends OnboardingEvent {
  final String businessLicenseNumber;
  const UpdateBusinessLicenseNumber(this.businessLicenseNumber);
  @override
  List<Object?> get props => [businessLicenseNumber];
}

class UpdateTaxId extends OnboardingEvent {
  final String taxId;
  const UpdateTaxId(this.taxId);
  @override
  List<Object?> get props => [taxId];
}

// Step 5: Payout Events
class UpdatePayoutMethod extends OnboardingEvent {
  final String payoutMethod;
  const UpdatePayoutMethod(this.payoutMethod);
  @override
  List<Object?> get props => [payoutMethod];
}

class UpdateBankAccount extends OnboardingEvent {
  final String? bankAccountNumber;
  final String? bankName;
  
  const UpdateBankAccount({this.bankAccountNumber, this.bankName});
  
  @override
  List<Object?> get props => [bankAccountNumber, bankName];
}

class UpdateMobileWallet extends OnboardingEvent {
  final String mobileWalletNumber;
  const UpdateMobileWallet(this.mobileWalletNumber);
  @override
  List<Object?> get props => [mobileWalletNumber];
}

/// Event to complete onboarding
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}
