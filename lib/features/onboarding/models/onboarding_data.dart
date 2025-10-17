import 'package:equatable/equatable.dart';

/// Model to hold all onboarding data
class OnboardingData extends Equatable {
  // Step 0: Phone Number
  final String phoneNumber;
  final String vendorType; // Always 'business' - kept for compatibility
  final String password;
  final bool userExists;
  final bool isOtpVerified;
  final bool hasVendor;
  
  // Step 1: OTP
  final String otp;
  
  // Step 2: Basic Info
  final String firstName;
  final String lastName;
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
  
  // Step 4: Shipping Address
  final String addressLine1;
  final String addressLine2;
  final String shippingCity;
  final String state;
  final String shippingRegion;
  final String subcity;
  final String woreda;
  final String kebele;
  final String postalCode;
  final String country;
  final String latitude;
  final String longitude;
  
  // Step 5: Subscription Selection
  final int? selectedSubscriptionId;
  final String selectedSubscriptionName;
  final bool agreeTermsCheck;
  
  // Step 6: Payout Information
  final String preferredPayoutMethod; // 'bank' or 'wallet'
  final String accountHolderName; // Account holder's full name
  final String bankName;
  final String bankAccountNumber;
  final String accountNumber; // Generic account number field
  final String mobileWalletNumber;
  final bool confirmDetailsCheck;
  final bool authorizePayoutCheck;
  
  // File fields for document uploads
  final dynamic businessLicenseFile;
  final dynamic coverImageFile;
  final dynamic faydaImageFile;

  const OnboardingData({
    this.phoneNumber = '',
    this.vendorType = 'business',
    this.password = '',
    this.userExists = false,
    this.isOtpVerified = false,
    this.hasVendor = false,
    this.otp = '',
    this.firstName = '',
    this.lastName = '',
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
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.shippingCity = '',
    this.state = '',
    this.shippingRegion = '',
    this.subcity = '',
    this.woreda = '',
    this.kebele = '',
    this.postalCode = '',
    this.country = 'Ethiopia',
    this.latitude = '',
    this.longitude = '',
    this.selectedSubscriptionId,
    this.selectedSubscriptionName = '',
    this.agreeTermsCheck = false,
    this.preferredPayoutMethod = 'wallet',
    this.accountHolderName = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.accountNumber = '',
    this.mobileWalletNumber = '',
    this.confirmDetailsCheck = false,
    this.authorizePayoutCheck = false,
    this.businessLicenseFile,
    this.coverImageFile,
    this.faydaImageFile,
  });

  OnboardingData copyWith({
    String? phoneNumber,
    String? vendorType,
    String? password,
    bool? userExists,
    bool? isOtpVerified,
    bool? hasVendor,
    String? otp,
    String? firstName,
    String? lastName,
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
    String? addressLine1,
    String? addressLine2,
    String? shippingCity,
    String? state,
    String? shippingRegion,
    String? subcity,
    String? woreda,
    String? kebele,
    String? postalCode,
    String? country,
    String? latitude,
    String? longitude,
    int? selectedSubscriptionId,
    String? selectedSubscriptionName,
    bool? agreeTermsCheck,
    String? preferredPayoutMethod,
    String? accountHolderName,
    String? bankName,
    String? bankAccountNumber,
    String? accountNumber,
    String? mobileWalletNumber,
    bool? confirmDetailsCheck,
    bool? authorizePayoutCheck,
    dynamic businessLicenseFile,
    dynamic coverImageFile,
    dynamic faydaImageFile,
  }) {
    return OnboardingData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vendorType: vendorType ?? this.vendorType,
      password: password ?? this.password,
      userExists: userExists ?? this.userExists,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      hasVendor: hasVendor ?? this.hasVendor,
      otp: otp ?? this.otp,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
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
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      shippingCity: shippingCity ?? this.shippingCity,
      state: state ?? this.state,
      shippingRegion: shippingRegion ?? this.shippingRegion,
      subcity: subcity ?? this.subcity,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedSubscriptionId: selectedSubscriptionId ?? this.selectedSubscriptionId,
      selectedSubscriptionName: selectedSubscriptionName ?? this.selectedSubscriptionName,
      agreeTermsCheck: agreeTermsCheck ?? this.agreeTermsCheck,
      preferredPayoutMethod: preferredPayoutMethod ?? this.preferredPayoutMethod,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      mobileWalletNumber: mobileWalletNumber ?? this.mobileWalletNumber,
      confirmDetailsCheck: confirmDetailsCheck ?? this.confirmDetailsCheck,
      authorizePayoutCheck: authorizePayoutCheck ?? this.authorizePayoutCheck,
      businessLicenseFile: businessLicenseFile ?? this.businessLicenseFile,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      faydaImageFile: faydaImageFile ?? this.faydaImageFile,
    );
  }

  bool get isIndividual => vendorType == 'individual';
  bool get isBusiness => vendorType == 'business';

  bool isStepCompleted(int step) {
    switch (step) {
      case 0: // Phone Number & Password
        return phoneNumber.isNotEmpty && 
               phoneNumber.length >= 10 && 
               password.isNotEmpty && 
               password.length >= 6;
      case 1: // OTP - If user got past this step, it was verified by API
        return true; // Always true - verified by backend when moving to step 2
      case 2: // Basic Info (Business only)
        return businessName.isNotEmpty &&
            businessDescription.isNotEmpty &&
            category.isNotEmpty;
      case 3: // Shipping Address
        return addressLine1.isNotEmpty && addressLine1.length >= 3;
      case 4: // Documents (Business only)
        return businessLicenseFile != null && coverImageFile != null;
      case 5: // Payout Information
        // Check if payout method is selected and details are filled
        final isBank = preferredPayoutMethod == 'bank_account';
        final hasPaymentData = isBank 
            ? accountNumber.isNotEmpty && accountHolderName.isNotEmpty
            : accountNumber.isNotEmpty && accountHolderName.isNotEmpty;
        return hasPaymentData && confirmDetailsCheck && authorizePayoutCheck;
      case 6: // Subscription Selection
        return selectedSubscriptionId != null && agreeTermsCheck;
      case 7: // Admin Approval (always true - user just waits)
        return true;
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        vendorType,
        password,
        userExists,
        isOtpVerified,
        hasVendor,
        otp,
        firstName,
        lastName,
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
        addressLine1,
        addressLine2,
        shippingCity,
        state,
        shippingRegion,
        subcity,
        woreda,
        kebele,
        postalCode,
        country,
        latitude,
        longitude,
        selectedSubscriptionId,
        selectedSubscriptionName,
        agreeTermsCheck,
        preferredPayoutMethod,
        accountHolderName,
        bankName,
        bankAccountNumber,
        accountNumber,
        mobileWalletNumber,
        confirmDetailsCheck,
        authorizePayoutCheck,
        businessLicenseFile,
        coverImageFile,
        faydaImageFile,
      ];
}
