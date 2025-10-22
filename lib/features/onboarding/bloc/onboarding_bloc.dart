import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/onboarding_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/localization_service.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Navigation events
    on<InitializeOnboarding>(_onInitializeOnboarding);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<GoToStep>(_onGoToStep);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<RetryVendorSubmission>(_onRetryVendorSubmission);
    on<RetryWithNewBusinessName>(_onRetryWithNewBusinessName);
    
    // Step 0: Phone Number & Password
    on<UpdatePhoneNumber>(_onUpdatePhoneNumber);
    on<UpdatePassword>(_onUpdatePassword);
    
    // Step 1: OTP
    on<UpdateOTP>(_onUpdateOTP);
    on<ResendOTP>(_onResendOTP);
    
    // Step 2: Basic Info
    on<UpdateBusinessName>(_onUpdateBusinessName);
    on<UpdateBusinessDescription>(_onUpdateBusinessDescription);
    on<UpdateCategories>(_onUpdateCategories);
    
    // Step 3: Shipping Address
    on<UpdateCity>(_onUpdateCity);
    on<UpdateSubcity>(_onUpdateSubcity);
    on<UpdateWoreda>(_onUpdateWoreda);
    on<UpdateState>(_onUpdateState);
    
    // Step 4: Documents
    on<UpdateBusinessLicense>(_onUpdateBusinessLicense);
    on<UpdateCoverImage>(_onUpdateCoverImage);
    
    // Step 5: Payout
    on<UpdatePayoutMethod>(_onUpdatePayoutMethod);
    on<UpdateBankAccount>(_onUpdateBankAccount);
    on<UpdateMobileWallet>(_onUpdateMobileWallet);
    on<UpdatePayoutCheckboxes>(_onUpdatePayoutCheckboxes);
    
    // Step 6: Subscription
    on<UpdateSubscription>(_onUpdateSubscription);
    on<ToggleTermsAgreement>(_onToggleTermsAgreement);
  }

  // Helper methods for common operations
  void _logInfo(String message, {String? details}) {
    developer.log(message, name: 'OnboardingBloc');
    if (details != null) {
      print('$message\n$details');
    } else {
      print(message);
    }
  }

  void _logError(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'OnboardingBloc', error: error, stackTrace: stackTrace);
    print('❌ $message');
    if (error != null) {
      print('   Error: $error');
    }
  }

  void _handleApiError(Emitter<OnboardingState> emit, OnboardingInProgress currentState, 
      String errorMessage, {Map<String, dynamic>? apiResponse, String? code}) {
    _logError('API Error: $errorMessage');
    emit(OnboardingError(errorMessage, step: currentState.currentStep, code: code));
    emit(currentState); // Return to current state
  }

  void _handleNetworkError(Emitter<OnboardingState> emit, OnboardingInProgress currentState, 
      Object error) {
    _logError('Network Error', error: error);
    emit(OnboardingError('Network error: ${error.toString()}', step: currentState.currentStep, code: 'NETWORK_ERROR'));
    emit(currentState); // Return to current state
  }

  Future<void> _performLogin(Emitter<OnboardingState> emit, OnboardingInProgress currentState) async {
    try {
      _logInfo('🔑 Logging in to get authentication token...');
      final loginResult = await ApiService.login(
        phoneNumber: currentState.data.phoneNumber,
        password: currentState.data.password,
      );
      
      if (loginResult['success'] == true) {
        _logInfo('✅ Login successful! Token saved.');
        return;
      } else {
        _handleApiError(emit, currentState, loginResult['error'] ?? 'Login failed');
        return;
      }
    } catch (e) {
      _handleNetworkError(emit, currentState, e);
      return;
    }
  }

  Future<void> _handleRegistration(OnboardingInProgress currentState, Emitter<OnboardingState> emit) async {
    _logInfo('Starting registration...');
    emit(const OnboardingLoading());
    
    try {
      final phoneNumber = currentState.data.phoneNumber;
      final password = currentState.data.password;
      final name = currentState.data.businessName.isNotEmpty 
          ? currentState.data.businessName 
          : phoneNumber;
      
      _logInfo('📝 Registration Details:', details: 'Phone: $phoneNumber');
      _logInfo('🔑 Using password: ${password.replaceAll(RegExp(r'.'), '*')}');
      _logInfo('🚀 Calling register-vendor-owner API...');
      
      final result = await ApiService.registerVendorOwner(
        name: name,
        phoneNumber: phoneNumber,
        password: password,
        email: '', // Not used in current flow
      );
      
      _logInfo('📥 API Response:', details: '''
        Full Response: $result
        Response Keys: ${result.keys.toList()}
        Success: ${result['success']}
        Error: ${result['error']}
        Data: ${result['data']}
      ''');
      
      if (result['success'] == true) {
        bool isOtpVerified = result['is_otp_verified'] ?? false;
        
        if (isOtpVerified) {
          _logInfo('✅ User exists and OTP already verified!');
          await _performLogin(emit, currentState);
          if (state is! OnboardingError) {
            emit(currentState.copyWith(currentStep: 2)); // Go to Basic Info
          }
        } else {
          _logInfo('✅ Registration successful! Moving to OTP step...');
          emit(currentState.copyWith(currentStep: 1));
        }
      } else {
        final rawError = (result['error'] ?? 'Registration failed').toString();
        final lower = rawError.toLowerCase();
        if (_isUserAlreadyExistsError(lower)) {
          final localized = LocalizationService.instance.get('onboarding.userExists.banner');
          _handleApiError(emit, currentState, localized, code: 'USER_ALREADY_EXISTS');
        } else {
          _handleApiError(emit, currentState, rawError, code: 'REGISTRATION_FAILED');
        }
      }
    } catch (e) {
      _handleNetworkError(emit, currentState, e);
    }
  }

  Future<void> _handleOtpVerification(OnboardingInProgress currentState, Emitter<OnboardingState> emit) async {
    emit(const OnboardingLoading());
    
    try {
      _logInfo('🔐 Step 1: Verifying OTP...');
      final result = await ApiService.verifyOtp(
        phoneNumber: currentState.data.phoneNumber,
        code: currentState.data.otp,
      );
      
      if (result['success'] == true) {
        _logInfo('✅ OTP verified successfully!');
        await _performLogin(emit, currentState);
        if (state is! OnboardingError) {
          emit(currentState.copyWith(currentStep: 2));
        }
      } else {
        final rawError = (result['error'] ?? 'Invalid OTP').toString();
        final lower = rawError.toLowerCase();
        final isExpired = lower.contains('expired') || lower.contains('timeout') || lower.contains('time out');
        final localizedMsg = isExpired
            ? LocalizationService.instance.get('errors.otpExpired')
            : LocalizationService.instance.get('errors.invalidOtp');
        _handleApiError(emit, currentState, localizedMsg, code: isExpired ? 'OTP_EXPIRED' : 'INVALID_OTP');
      }
    } catch (e) {
      _handleNetworkError(emit, currentState, e);
    }
  }

  void _onInitializeOnboarding(
    InitializeOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.useMockData) {
      // Initialize with mock data for testing
      emit(const OnboardingInProgress(
        currentStep: 0,
        data: OnboardingData(
          phoneNumber: '+251912345678',
          password: 'Test@123',
          otp: '123456',
          businessName: 'Test Business',
          businessDescription: 'Selling quality products',
          categories: ['1'],
          city: 'Addis Ababa',
          subcity: 'Bole',
          woreda: 'Woreda 1',
          state: 'Addis Ababa',
          preferredPayoutMethod: 'wallet',
          accountHolderName: 'Test User',
          mobileWalletNumber: '+251912345678',
        ),
      ));
    } else {
      // Initialize with empty data
      emit(const OnboardingInProgress(
        currentStep: 0,
        data: OnboardingData(),
      ));
    }
  }

  void _onNextStep(
    NextStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Check if current step is completed
      if (!currentState.canProceed) {
        return;
      }

      // Handle Step 0 → Step 1: Register user and send OTP
      if (currentState.currentStep == 0) {
        await _handleRegistration(currentState, emit);
        return;
      }

      // Handle Step 1 → Step 2: Verify OTP
      if (currentState.currentStep == 1) {
        await _handleOtpVerification(currentState, emit);
        return;
      }

      // Check if we just completed the subscription step (step 6)
      if (currentState.currentStep == 6) {
        // Immediately attempt vendor creation; UI will route based on result state
        await _createBusinessVendor(currentState, emit);
        return;
      } else if (currentState.isLastStep) {
        add(const CompleteOnboarding());
      } else {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      }
    }
  }

  void _onPreviousStep(
    PreviousStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      if (!currentState.isFirstStep) {
        emit(currentState.copyWith(
          currentStep: currentState.currentStep - 1,
        ));
      }
    }
  }

  void _onGoToStep(
    GoToStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Only allow going to completed steps or the next incomplete step
      if (event.step >= 0 && event.step < currentState.totalSteps) {
        bool canGoToStep = true;
        
        // Check if all previous steps are completed
        for (int i = 0; i < event.step; i++) {
          if (!currentState.data.isStepCompleted(i)) {
            canGoToStep = false;
            break;
          }
        }
        
        if (canGoToStep) {
          emit(currentState.copyWith(currentStep: event.step));
        }
      }
    }
  }

  // Helper method for simple field updates
  void _updateField(Emitter<OnboardingState> emit, OnboardingData Function(OnboardingData) updateFn) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(data: updateFn(currentState.data)));
    }
  }

  // Step 0: Phone Number & Password Events
  void _onUpdatePhoneNumber(UpdatePhoneNumber event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(phoneNumber: event.phoneNumber));
  }

  void _onUpdatePassword(UpdatePassword event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(password: event.password));
  }

  // Step 1: OTP Events
  void _onUpdateOTP(UpdateOTP event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(otp: event.otp));
  }

  void _onResendOTP(ResendOTP event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      _logInfo('📲 Resending OTP to ${currentState.data.phoneNumber}...');
      
      try {
        final result = await ApiService.resendOtp(
          phoneNumber: currentState.data.phoneNumber,
        );
        
        _logInfo('📥 Resend OTP Response: $result');
        
        if (result['success'] != true) {
          _handleApiError(emit, currentState, result['error'] ?? 'Failed to resend OTP', code: 'RESEND_OTP_FAILED');
        } else {
          _logInfo('✅ OTP resent successfully!');
        }
      } catch (e) {
        _handleNetworkError(emit, currentState, e);
      }
    }
  }

  // Step 2: Basic Info Events
  void _onUpdateBusinessName(UpdateBusinessName event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(businessName: event.businessName));
  }

  void _onUpdateBusinessDescription(UpdateBusinessDescription event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(businessDescription: event.businessDescription));
  }

  void _onUpdateCategories(UpdateCategories event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(categories: event.categories));
  }

  // Step 3: Shipping Address Events
  void _onUpdateCity(UpdateCity event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(city: event.city));
  }

  void _onUpdateSubcity(UpdateSubcity event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(subcity: event.subcity));
  }

  void _onUpdateWoreda(UpdateWoreda event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(woreda: event.woreda));
  }

  void _onUpdateState(UpdateState event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(state: event.state));
  }

  // Step 4: Documents Events
  void _onUpdateBusinessLicense(UpdateBusinessLicense event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(businessLicenseFile: event.file));
  }

  void _onUpdateCoverImage(UpdateCoverImage event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(coverImageFile: event.file));
  }

  // Step 5: Payout Events
  void _onUpdatePayoutMethod(UpdatePayoutMethod event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(preferredPayoutMethod: event.payoutMethod));
  }

  void _onUpdateBankAccount(UpdateBankAccount event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          accountHolderName: event.accountHolderName ?? currentState.data.accountHolderName,
          bankName: event.bankName ?? currentState.data.bankName,
          bankAccountNumber: event.bankAccountNumber ?? currentState.data.bankAccountNumber,
          // Keep generic accountNumber in sync so step completion works (only if provided)
          accountNumber: (event.bankAccountNumber != null && event.bankAccountNumber!.isNotEmpty)
              ? event.bankAccountNumber!
              : currentState.data.accountNumber,
        ),
      ));
    }
  }

  void _onUpdateMobileWallet(UpdateMobileWallet event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(
      mobileWalletNumber: event.mobileWalletNumber,
      // Also populate generic accountNumber for completion check
      accountNumber: event.mobileWalletNumber.isNotEmpty
          ? event.mobileWalletNumber
          : data.accountNumber,
    ));
  }

  void _onUpdatePayoutCheckboxes(UpdatePayoutCheckboxes event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          confirmDetailsCheck: event.confirmDetailsCheck,
          agreeTermsCheck: event.agreeTermsCheck,
          authorizePayoutCheck: event.authorizePayoutCheck,
        ),
      ));
    }
  }

  // Step 6: Subscription Events
  void _onUpdateSubscription(UpdateSubscription event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(selectedSubscriptionId: event.subscriptionId));
  }

  void _onToggleTermsAgreement(ToggleTermsAgreement event, Emitter<OnboardingState> emit) {
    _updateField(emit, (data) => data.copyWith(agreeTermsCheck: event.agreed));
  }

  void _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    _logInfo('🎯 ===== COMPLETE ONBOARDING EVENT RECEIVED =====');
    _logInfo('🎯 Starting vendor creation process...');
    
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      if (!_validateAllStepsCompleted(currentState, emit)) {
        return;
      }

      await _createBusinessVendor(currentState, emit);
    }
  }

  bool _validateAllStepsCompleted(OnboardingInProgress currentState, Emitter<OnboardingState> emit) {
    // Validate all previous steps are completed
    for (int i = 0; i < currentState.currentStep; i++) {
      if (!currentState.data.isStepCompleted(i)) {
        emit(OnboardingError('Please complete all previous steps', step: currentState.currentStep, code: 'INCOMPLETE_STEPS'));
        return false;
      }
    }
    
    // Validate current step (Payout) is also completed
    if (!currentState.data.isStepCompleted(currentState.currentStep)) {
      emit(OnboardingError('Please complete the payout information', step: currentState.currentStep, code: 'INCOMPLETE_PAYOUT'));
      return false;
    }
    
    return true;
  }

  Future<void> _createBusinessVendor(OnboardingInProgress currentState, Emitter<OnboardingState> emit) async {
    _logInfo('Creating business vendor...');
    emit(const OnboardingLoading());
    
    try {
      final data = currentState.data;
      
      // Validate required files
      if (!_validateRequiredFiles(data, emit, currentState)) {
        return;
      }
      
      // Prepare vendor data
      final vendorData = await _prepareVendorData(data);
      if (vendorData == null) {
        return; // Error already handled in _prepareVendorData
      }
      
      // Create vendor
      final result = await ApiService.registerBusinessVendor(
        name: data.businessName,
        description: data.businessDescription,
        fullName: data.businessName.isNotEmpty ? data.businessName : 'Unknown User',
        email: 'user@example.com',
        phoneNumber: data.phoneNumber,
        addressLine1: data.city.isNotEmpty ? data.city : 'Addis Ababa',
        addressLine2: null,
        city: data.city.isNotEmpty ? data.city : null,
        state: data.state.isNotEmpty ? data.state : null,
        region: null,
        subcity: data.subcity.isNotEmpty ? data.subcity : null,
        woreda: data.woreda.isNotEmpty ? data.woreda : null,
        kebele: null,
        postalCode: null,
        country: 'Ethiopia',
        categoryIds: vendorData['categoryIds'],
        paymentMethodType: vendorData['paymentMethodType'],
        accountHolderName: data.accountHolderName,
        accountNumber: vendorData['accountNumber'],
        accountName: vendorData['accountName'],
        coverImagePath: vendorData['coverImagePath'],
        businessLicenseImagePath: vendorData['businessLicensePath'],
        subscriptionId: data.selectedSubscriptionId ?? 1,
        paymentAmount: 150.0,
        paymentMethod: 'manual',
        paymentProvider: 'bank_transfer',
        currency: 'ETB',
      );
      
      _logInfo('Business Vendor Creation Response: $result');
      
      if (result['success'] == true) {
        _logInfo('Business vendor created successfully!');
        emit(OnboardingVendorSubmitted(
          data: currentState.data,
          apiResponse: result,
          message: result['message'] ?? 'Application submitted for review',
        ));
      } else {
        _handleVendorCreationError(result, currentState, emit);
      }
    } catch (e, stackTrace) {
      _logError('Exception during business vendor creation', error: e, stackTrace: stackTrace);
      emit(OnboardingVendorSubmissionFailed(
        data: currentState.data,
        apiResponse: {'success': false, 'error': e.toString()},
        error: 'Network error: ${e.toString()}',
      ));
    }
  }

  bool _validateRequiredFiles(OnboardingData data, Emitter<OnboardingState> emit, OnboardingInProgress currentState) {
    if (data.coverImageFile == null || data.businessLicenseFile == null) {
      emit(OnboardingVendorSubmissionFailed(
        data: currentState.data,
        apiResponse: {'success': false, 'error': 'Missing required document images'},
        error: 'Please upload both cover image and business license',
      ));
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>?> _prepareVendorData(OnboardingData data) async {
    try {
      // Parse categories
      List<int> categoryIds = [1]; // Default category ID
      if (data.categories.isNotEmpty) {
        try {
          categoryIds = data.categories.map((id) => int.parse(id)).toList();
        } catch (e) {
          categoryIds = [1];
        }
      }
      
      // Prepare payment method details
      final isBank = data.preferredPayoutMethod == 'bank_account';
      final paymentMethodType = isBank ? 'bank' : 'wallet';
      
      // Get account number from the appropriate field
      String accountNumber = '';
      if (isBank) {
        accountNumber = data.bankAccountNumber.isNotEmpty 
            ? data.bankAccountNumber 
            : data.accountNumber;
      } else {
        accountNumber = data.mobileWalletNumber.isNotEmpty 
            ? data.mobileWalletNumber 
            : data.accountNumber;
      }
      
      // Get account name (bank name or wallet provider)
      String accountName = '';
      if (isBank) {
        accountName = data.bankName.isNotEmpty ? data.bankName : 'Bank';
      } else {
        if (data.preferredPayoutMethod == 'telebirr') {
          accountName = 'Telebirr';
        } else if (data.preferredPayoutMethod == 'cbe_birr') {
          accountName = 'CBE Birr';
        } else {
          accountName = 'Mobile Wallet';
        }
      }
      
      // Process image files
      final imagePaths = await _processImageFiles(data);
      if (imagePaths == null) {
        return null; // Error already handled
      }
      
      return {
        'categoryIds': categoryIds,
        'paymentMethodType': paymentMethodType,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'coverImagePath': imagePaths['coverImagePath'],
        'businessLicensePath': imagePaths['businessLicensePath'],
      };
    } catch (e) {
      _logError('Error preparing vendor data', error: e);
      return null;
    }
  }

  Future<Map<String, String>?> _processImageFiles(OnboardingData data) async {
    try {
      String coverImagePath = '';
      String businessLicensePath = '';
      
      if (kIsWeb) {
        // On web, read bytes and convert to data URL
        final coverBytes = await data.coverImageFile!.readAsBytes();
        final licenseBytes = await data.businessLicenseFile!.readAsBytes();
        
        final coverBase64 = base64Encode(coverBytes);
        final licenseBase64 = base64Encode(licenseBytes);
        
        // Determine MIME type from file name
        String coverMime = data.coverImageFile!.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
        String licenseMime = data.businessLicenseFile!.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
        
        coverImagePath = 'data:$coverMime;base64,$coverBase64';
        businessLicensePath = 'data:$licenseMime;base64,$licenseBase64';
      } else {
        coverImagePath = data.coverImageFile!.path;
        businessLicensePath = data.businessLicenseFile!.path;
      }
      
      return {
        'coverImagePath': coverImagePath,
        'businessLicensePath': businessLicensePath,
      };
    } catch (e) {
      _logError('Error processing image files', error: e);
      return null;
    }
  }

  void _handleVendorCreationError(Map<String, dynamic> result, OnboardingInProgress currentState, Emitter<OnboardingState> emit) {
    _logError('Business vendor creation failed: ${result['error']}');
    final errorMessageRaw = result['error']?.toString() ?? 'Failed to create business vendor';
    final errorMessage = errorMessageRaw.toLowerCase();
    
    if (_isUserAlreadyExistsError(errorMessage)) {
      final localized = LocalizationService.instance.get('onboarding.userExists.banner');
      emit(OnboardingError(
        localized,
        step: currentState.currentStep,
        code: 'USER_ALREADY_EXISTS',
        recoverable: false,
      ));
      emit(currentState); // keep UI on the same screen
    } else if (_isVendorNameExistsError(errorMessage)) {
      // Handle vendor name conflict with better UI
      final originalName = currentState.data.businessName;
      final suggestedName = _generateSuggestedName(originalName);
      emit(OnboardingBusinessNameConflict(
        data: currentState.data,
        originalName: originalName,
        suggestedName: suggestedName,
      ));
    } else {
      emit(OnboardingVendorSubmissionFailed(
        data: currentState.data,
        apiResponse: result,
        error: errorMessageRaw,
      ));
    }
  }

  bool _isUserAlreadyExistsError(String errorMessage) {
    return errorMessage.contains('user already exists') || 
           errorMessage.contains('email already exists') || 
           errorMessage.contains('phone already exists') ||
           errorMessage.contains('already registered') ||
           errorMessage.contains('duplicate user') ||
           errorMessage.contains('user exists');
  }

  bool _isVendorNameExistsError(String errorMessage) {
    return errorMessage.contains('vendor name already exists') ||
           errorMessage.contains('name already exists') ||
           errorMessage.contains('business name already exists') ||
           errorMessage.contains('choose a different name');
  }

  String _generateSuggestedName(String originalName) {
    // Generate a suggested name by adding a number or suffix
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return '$originalName $timestamp';
  }

  void _onRetryVendorSubmission(
    RetryVendorSubmission event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingVendorSubmissionFailed) {
      final failedState = state as OnboardingVendorSubmissionFailed;
      
      // Go back to the previous step (payout step) to allow user to review and retry
      emit(OnboardingInProgress(
        currentStep: 5, // Payout step
        data: failedState.data,
      ));
    }
  }

  void _onRetryWithNewBusinessName(
    RetryWithNewBusinessName event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingBusinessNameConflict) {
      final conflictState = state as OnboardingBusinessNameConflict;
      
      // Update the business name and immediately retry vendor creation
      final updatedData = conflictState.data.copyWith(businessName: event.newBusinessName);
      final updatedState = OnboardingInProgress(
        currentStep: 6, // Stay at subscription step
        data: updatedData,
      );
      
      // Immediately attempt vendor creation with the new name
      await _createBusinessVendor(updatedState, emit);
    }
  }
}