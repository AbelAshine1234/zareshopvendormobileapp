import 'package:equatable/equatable.dart';

/// Model to hold all onboarding data
class OnboardingData extends Equatable {
  // Step 1: Phone Number
  final String phoneNumber;
  final String vendorType; // 'individual' or 'business'
  
  // Step 2: OTP
  final String otp;
  
  // Step 3: Basic Info
  final String fullName;
  final String businessName;
  final String email;
  final String languagePreference; // 'am', 'en', 'om'
  final String coverPhotoUrl;
  final String street;
  final String city;
  final String region;
  final String zone;
  final String businessDescription;
  final String category;
  
  // Step 4: Documents
  final String faydaIdNumber;
  final String faydaIdPhotoUrl;
  final String businessLicenseNumber;
  final String businessLicensePhotoUrl;
  final String taxId;
  
  // Step 5: Payout
  final String preferredPayoutMethod; // 'wallet' or 'bank'
  final String bankAccountNumber;
  final String bankName;
  final String mobileWalletNumber;

  const OnboardingData({
    this.phoneNumber = '',
    this.vendorType = 'individual',
    this.otp = '',
    this.fullName = '',
    this.businessName = '',
    this.email = '',
    this.languagePreference = 'en',
    this.coverPhotoUrl = '',
    this.street = '',
    this.city = '',
    this.region = '',
    this.zone = '',
    this.businessDescription = '',
    this.category = '',
    this.faydaIdNumber = '',
    this.faydaIdPhotoUrl = '',
    this.businessLicenseNumber = '',
    this.businessLicensePhotoUrl = '',
    this.taxId = '',
    this.preferredPayoutMethod = 'wallet',
    this.bankAccountNumber = '',
    this.bankName = '',
    this.mobileWalletNumber = '',
  });

  OnboardingData copyWith({
    String? phoneNumber,
    String? vendorType,
    String? otp,
    String? fullName,
    String? businessName,
    String? email,
    String? languagePreference,
    String? coverPhotoUrl,
    String? street,
    String? city,
    String? region,
    String? zone,
    String? businessDescription,
    String? category,
    String? faydaIdNumber,
    String? faydaIdPhotoUrl,
    String? businessLicenseNumber,
    String? businessLicensePhotoUrl,
    String? taxId,
    String? preferredPayoutMethod,
    String? bankAccountNumber,
    String? bankName,
    String? mobileWalletNumber,
  }) {
    return OnboardingData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vendorType: vendorType ?? this.vendorType,
      otp: otp ?? this.otp,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      languagePreference: languagePreference ?? this.languagePreference,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      businessDescription: businessDescription ?? this.businessDescription,
      category: category ?? this.category,
      faydaIdNumber: faydaIdNumber ?? this.faydaIdNumber,
      faydaIdPhotoUrl: faydaIdPhotoUrl ?? this.faydaIdPhotoUrl,
      businessLicenseNumber: businessLicenseNumber ?? this.businessLicenseNumber,
      businessLicensePhotoUrl: businessLicensePhotoUrl ?? this.businessLicensePhotoUrl,
      taxId: taxId ?? this.taxId,
      preferredPayoutMethod: preferredPayoutMethod ?? this.preferredPayoutMethod,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      mobileWalletNumber: mobileWalletNumber ?? this.mobileWalletNumber,
    );
  }

  bool get isIndividual => vendorType == 'individual';
  bool get isBusiness => vendorType == 'business';

  bool isStepCompleted(int step) {
    switch (step) {
      case 0: // Phone Number
        return phoneNumber.isNotEmpty && phoneNumber.length >= 10;
      case 1: // OTP
        return otp.isNotEmpty && otp.length == 6;
      case 2: // Basic Info
        if (isIndividual) {
          return fullName.isNotEmpty &&
              street.isNotEmpty &&
              city.isNotEmpty &&
              businessDescription.isNotEmpty &&
              category.isNotEmpty;
        } else {
          return businessName.isNotEmpty &&
              street.isNotEmpty &&
              city.isNotEmpty &&
              businessDescription.isNotEmpty &&
              category.isNotEmpty;
        }
      case 3: // Documents
        if (isIndividual) {
          return faydaIdNumber.isNotEmpty;
        } else {
          return businessLicenseNumber.isNotEmpty;
        }
      case 4: // Payout
        if (preferredPayoutMethod == 'bank') {
          return bankAccountNumber.isNotEmpty && bankName.isNotEmpty;
        } else {
          return mobileWalletNumber.isNotEmpty;
        }
      case 5: // Admin Approval (always allow to view)
        return true;
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        vendorType,
        otp,
        fullName,
        businessName,
        email,
        languagePreference,
        coverPhotoUrl,
        street,
        city,
        region,
        zone,
        businessDescription,
        category,
        faydaIdNumber,
        faydaIdPhotoUrl,
        businessLicenseNumber,
        businessLicensePhotoUrl,
        taxId,
        preferredPayoutMethod,
        bankAccountNumber,
        bankName,
        mobileWalletNumber,
      ];
}
