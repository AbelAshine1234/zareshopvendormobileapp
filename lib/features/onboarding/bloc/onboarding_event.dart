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

class UpdatePassword extends OnboardingEvent {
  final String password;
  const UpdatePassword(this.password);
  @override
  List<Object?> get props => [password];
}

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
class UpdateFirstName extends OnboardingEvent {
  final String firstName;
  const UpdateFirstName(this.firstName);
  @override
  List<Object?> get props => [firstName];
}

class UpdateLastName extends OnboardingEvent {
  final String lastName;
  const UpdateLastName(this.lastName);
  @override
  List<Object?> get props => [lastName];
}

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

class UpdateCoverPhoto extends OnboardingEvent {
  final String coverPhotoUrl;
  const UpdateCoverPhoto(this.coverPhotoUrl);
  @override
  List<Object?> get props => [coverPhotoUrl];
}

class UpdateAddress extends OnboardingEvent {
  final String? street;
  final String? city;
  final String? region;
  final String? zone;
  final String? addressLine1;
  final String? addressLine2;
  final String? state;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final String? postalCode;
  final String? country;
  
  const UpdateAddress({
    this.street,
    this.city,
    this.region,
    this.zone,
    this.addressLine1,
    this.addressLine2,
    this.state,
    this.subcity,
    this.woreda,
    this.kebele,
    this.postalCode,
    this.country,
  });
  
  @override
  List<Object?> get props => [
    street,
    city,
    region,
    zone,
    addressLine1,
    addressLine2,
    state,
    subcity,
    woreda,
    kebele,
    postalCode,
    country,
  ];
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

// Step 5: Subscription Events
/// Event to select a subscription
class SelectSubscription extends OnboardingEvent {
  final int subscriptionId;
  final String subscriptionName;
  
  const SelectSubscription({
    required this.subscriptionId,
    required this.subscriptionName,
  });
  
  @override
  List<Object?> get props => [subscriptionId, subscriptionName];
}

/// Event to toggle terms agreement checkbox
class ToggleTermsAgreement extends OnboardingEvent {
  final bool agreed;
  
  const ToggleTermsAgreement(this.agreed);
  
  @override
  List<Object?> get props => [agreed];
}

/// Event to update shipping address
class UpdateShippingAddress extends OnboardingEvent {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? region;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final String? postalCode;
  final String? country;
  final String? latitude;
  final String? longitude;
  
  const UpdateShippingAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.region,
    this.subcity,
    this.woreda,
    this.kebele,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
  });
  
  @override
  List<Object?> get props => [addressLine1, addressLine2, city, state, region, subcity, woreda, kebele, postalCode, country, latitude, longitude];
}

/// Event to update payout method
class UpdatePayoutMethod extends OnboardingEvent {
  final String payoutMethod; // 'bank' or 'wallet'
  
  const UpdatePayoutMethod(this.payoutMethod);
  
  @override
  List<Object?> get props => [payoutMethod];
}

/// Event to update bank account information
class UpdateBankAccount extends OnboardingEvent {
  final String? accountHolderName;
  final String? bankName;
  final String? bankAccountNumber;
  
  const UpdateBankAccount({this.accountHolderName, this.bankName, this.bankAccountNumber});
  
  @override
  List<Object?> get props => [accountHolderName, bankName, bankAccountNumber];
}

/// Event to update mobile wallet number
class UpdateMobileWallet extends OnboardingEvent {
  final String mobileWalletNumber;
  
  const UpdateMobileWallet(this.mobileWalletNumber);
  
  @override
  List<Object?> get props => [mobileWalletNumber];
}

/// Event to update payout checkboxes
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

/// Event to update selected subscription
class UpdateSubscription extends OnboardingEvent {
  final int subscriptionId;
  
  const UpdateSubscription(this.subscriptionId);
  
  @override
  List<Object?> get props => [subscriptionId];
}

/// Event to complete onboarding
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

// Additional events for step files
class UpdateBusinessCategory extends OnboardingEvent {
  final int categoryId;
  const UpdateBusinessCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class UpdateAddressLine1 extends OnboardingEvent {
  final String addressLine1;
  const UpdateAddressLine1(this.addressLine1);
  @override
  List<Object?> get props => [addressLine1];
}

class UpdateAddressLine2 extends OnboardingEvent {
  final String addressLine2;
  const UpdateAddressLine2(this.addressLine2);
  @override
  List<Object?> get props => [addressLine2];
}

class UpdateCity extends OnboardingEvent {
  final String city;
  const UpdateCity(this.city);
  @override
  List<Object?> get props => [city];
}

class UpdateState extends OnboardingEvent {
  final String state;
  const UpdateState(this.state);
  @override
  List<Object?> get props => [state];
}

class UpdatePostalCode extends OnboardingEvent {
  final String postalCode;
  const UpdatePostalCode(this.postalCode);
  @override
  List<Object?> get props => [postalCode];
}

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

class UpdateFaydaImage extends OnboardingEvent {
  final dynamic file;
  const UpdateFaydaImage(this.file);
  @override
  List<Object?> get props => [file];
}

class UpdatePaymentMethod extends OnboardingEvent {
  final String paymentMethod;
  const UpdatePaymentMethod(this.paymentMethod);
  @override
  List<Object?> get props => [paymentMethod];
}

class UpdateAccountHolder extends OnboardingEvent {
  final String accountHolder;
  const UpdateAccountHolder(this.accountHolder);
  @override
  List<Object?> get props => [accountHolder];
}

class UpdateAccountNumber extends OnboardingEvent {
  final String accountNumber;
  const UpdateAccountNumber(this.accountNumber);
  @override
  List<Object?> get props => [accountNumber];
}
