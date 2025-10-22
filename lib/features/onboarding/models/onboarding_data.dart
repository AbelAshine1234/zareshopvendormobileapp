import 'package:equatable/equatable.dart';

/// Model to hold all onboarding data - cleaned up version
class OnboardingData extends Equatable {
  // Step 0: Phone Number & Password
  final String phoneNumber;
  final String password;
  
  // Step 1: OTP
  final String otp;
  
  // Step 2: Basic Info (Business only)
  final String businessName;
  final String businessDescription;
  final List<String> categories;
  
  // Step 3: Shipping Address
  final String city;
  final String subcity;
  final String woreda;
  final String state;
  
  // Step 4: Documents (Business only)
  final dynamic businessLicenseFile;
  final dynamic coverImageFile;
  
  // Step 5: Payout Information
  final String preferredPayoutMethod; // 'bank_account' or 'wallet'
  final String accountHolderName;
  final String bankName;
  final String bankAccountNumber;
  final String accountNumber; // Generic account number field
  final String mobileWalletNumber;
  final bool confirmDetailsCheck;
  final bool authorizePayoutCheck;
  
  // Step 6: Subscription Selection
  final int? selectedSubscriptionId;
  final String selectedSubscriptionName;
  final bool agreeTermsCheck;

  const OnboardingData({
    this.phoneNumber = '',
    this.password = '',
    this.otp = '',
    this.businessName = '',
    this.businessDescription = '',
    this.categories = const [],
    this.city = '',
    this.subcity = '',
    this.woreda = '',
    this.state = '',
    this.businessLicenseFile,
    this.coverImageFile,
    this.preferredPayoutMethod = 'wallet',
    this.accountHolderName = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.accountNumber = '',
    this.mobileWalletNumber = '',
    this.confirmDetailsCheck = false,
    this.authorizePayoutCheck = false,
    this.selectedSubscriptionId,
    this.selectedSubscriptionName = '',
    this.agreeTermsCheck = false,
  });

  OnboardingData copyWith({
    String? phoneNumber,
    String? password,
    String? otp,
    String? businessName,
    String? businessDescription,
    List<String>? categories,
    String? city,
    String? subcity,
    String? woreda,
    String? state,
    dynamic businessLicenseFile,
    dynamic coverImageFile,
    String? preferredPayoutMethod,
    String? accountHolderName,
    String? bankName,
    String? bankAccountNumber,
    String? accountNumber,
    String? mobileWalletNumber,
    bool? confirmDetailsCheck,
    bool? authorizePayoutCheck,
    int? selectedSubscriptionId,
    String? selectedSubscriptionName,
    bool? agreeTermsCheck,
  }) {
    return OnboardingData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      otp: otp ?? this.otp,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      categories: categories ?? this.categories,
      city: city ?? this.city,
      subcity: subcity ?? this.subcity,
      woreda: woreda ?? this.woreda,
      state: state ?? this.state,
      businessLicenseFile: businessLicenseFile ?? this.businessLicenseFile,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      preferredPayoutMethod: preferredPayoutMethod ?? this.preferredPayoutMethod,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      mobileWalletNumber: mobileWalletNumber ?? this.mobileWalletNumber,
      confirmDetailsCheck: confirmDetailsCheck ?? this.confirmDetailsCheck,
      authorizePayoutCheck: authorizePayoutCheck ?? this.authorizePayoutCheck,
      selectedSubscriptionId: selectedSubscriptionId ?? this.selectedSubscriptionId,
      selectedSubscriptionName: selectedSubscriptionName ?? this.selectedSubscriptionName,
      agreeTermsCheck: agreeTermsCheck ?? this.agreeTermsCheck,
    );
  }

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
            categories.isNotEmpty;
      case 3: // Shipping Address
        return city.isNotEmpty && subcity.isNotEmpty && woreda.isNotEmpty && state.isNotEmpty;
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
        password,
        otp,
        businessName,
        businessDescription,
        categories,
        city,
        subcity,
        woreda,
        state,
        businessLicenseFile,
        coverImageFile,
        preferredPayoutMethod,
        accountHolderName,
        bankName,
        bankAccountNumber,
        accountNumber,
        mobileWalletNumber,
        confirmDetailsCheck,
        authorizePayoutCheck,
        selectedSubscriptionId,
        selectedSubscriptionName,
        agreeTermsCheck,
      ];
}