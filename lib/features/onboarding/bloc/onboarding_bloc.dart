import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/onboarding_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../../../core/services/api_service.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<InitializeOnboarding>(_onInitializeOnboarding);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<GoToStep>(_onGoToStep);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    
    // Step 1: Phone Number & Vendor Type
    on<UpdatePhoneNumber>(_onUpdatePhoneNumber);
    on<UpdateVendorType>(_onUpdateVendorType);
    on<UpdatePassword>(_onUpdatePassword);
    
    // Step 2: OTP
    on<UpdateOTP>(_onUpdateOTP);
    on<ResendOTP>(_onResendOTP);
    
    // Step 3: Basic Info
    on<UpdateFirstName>(_onUpdateFirstName);
    on<UpdateLastName>(_onUpdateLastName);
    on<UpdateFullName>(_onUpdateFullName);
    on<UpdateBusinessName>(_onUpdateBusinessName);
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdateLanguagePreference>(_onUpdateLanguagePreference);
    on<UpdateCoverPhoto>(_onUpdateCoverPhoto);
    on<UpdateAddress>(_onUpdateAddress);
    on<UpdateBusinessDescription>(_onUpdateBusinessDescription);
    on<UpdateCategory>(_onUpdateCategory);
    
    // Step 4: Documents
    on<UpdateFaydaIdNumber>(_onUpdateFaydaIdNumber);
    on<UpdateBusinessLicenseNumber>(_onUpdateBusinessLicenseNumber);
    on<UpdateTaxId>(_onUpdateTaxId);
    
    // Step 4: Shipping Address
    on<UpdateShippingAddress>(_onUpdateShippingAddress);
    
    // Step 5: Subscription
    on<SelectSubscription>(_onSelectSubscription);
    on<ToggleTermsAgreement>(_onToggleTermsAgreement);
    
    // Step 6: Payout
    on<UpdatePayoutMethod>(_onUpdatePayoutMethod);
    on<UpdateBankAccount>(_onUpdateBankAccount);
    on<UpdateMobileWallet>(_onUpdateMobileWallet);
    on<UpdatePayoutCheckboxes>(_onUpdatePayoutCheckboxes);
    
    // Step 7: Subscription
    on<UpdateSubscription>(_onUpdateSubscription);
    
    // Additional events for step files
    on<UpdateBusinessCategory>(_onUpdateBusinessCategory);
    on<UpdateAddressLine1>(_onUpdateAddressLine1);
    on<UpdateAddressLine2>(_onUpdateAddressLine2);
    on<UpdateCity>(_onUpdateCity);
    on<UpdateState>(_onUpdateState);
    on<UpdatePostalCode>(_onUpdatePostalCode);
    on<UpdateBusinessLicense>(_onUpdateBusinessLicense);
    on<UpdateCoverImage>(_onUpdateCoverImage);
    // on<UpdateFaydaImage>(_onUpdateFaydaImage); // Removed for business vendors
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<UpdateAccountHolder>(_onUpdateAccountHolder);
    on<UpdateAccountNumber>(_onUpdateAccountNumber);
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
          vendorType: 'business',
          otp: '123456',
          businessName: 'Test Business',
          email: 'test@zareshop.com',
          street: 'Bole Road',
          city: 'Addis Ababa',
          category: 'electronics',
          businessDescription: 'Selling quality electronics',
          businessLicenseNumber: 'BL123456',
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
    print('🎯 [ONBOARDING_BLOC] ===== NEXT STEP EVENT RECEIVED =====');
    print('🎯 [ONBOARDING_BLOC] Current state type: ${state.runtimeType}');
    
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      print('🎯 [ONBOARDING_BLOC] Current step: ${currentState.currentStep}');
      print('🎯 [ONBOARDING_BLOC] Can proceed: ${currentState.canProceed}');
      print('🎯 [ONBOARDING_BLOC] Is last step: ${currentState.isLastStep}');
      
      // Check if current step is completed
      if (!currentState.canProceed) {
        print('❌ [ONBOARDING_BLOC] Cannot proceed - current step not completed');
        return;
      }

      // Handle Step 0 → Step 1: Register user and send OTP
      if (currentState.currentStep == 0) {
        print('📞 Starting registration...');
        developer.log('📞 Starting registration...', name: 'OnboardingBloc');
        emit(const OnboardingLoading());
        
        try {
          final vendorType = currentState.data.vendorType;
          final phoneNumber = currentState.data.phoneNumber;
          
          print('📝 Registration Details:');
          print('   Vendor Type: $vendorType');
          print('   Phone: $phoneNumber');
          developer.log(
            '📝 Registration Details:\n'
            '   Vendor Type: $vendorType\n'
            '   Phone: $phoneNumber',
            name: 'OnboardingBloc',
          );
          
          // Get name from basic info or use phone as fallback
          final name = currentState.data.fullName.isNotEmpty 
              ? currentState.data.fullName 
              : phoneNumber;
          
          // Use password from state
          final password = currentState.data.password.isNotEmpty 
              ? currentState.data.password 
              : 'Temp@${phoneNumber.replaceAll('+', '')}123'; // Fallback if password not set
          
          print('🔑 Using password: ${password.replaceAll(RegExp(r'.'), '*')}');
          developer.log('🔑 Using password: ${password.replaceAll(RegExp(r'.'), '*')}', name: 'OnboardingBloc');
          
          // Always register as VENDOR_OWNER (business only)
          print('🚀 Calling register-vendor-owner API...');
          developer.log('🚀 Calling register-vendor-owner API...', name: 'OnboardingBloc');
          
          final result = await ApiService.registerVendorOwner(
            name: name,
            phoneNumber: phoneNumber,
            password: password,
            email: currentState.data.email,
          );
          
          print('📥 API Response: $result');
          print('   Response Keys: ${result.keys.toList()}');
          print('   Success: ${result['success']}');
          print('   Error: ${result['error']}');
          print('   Data: ${result['data']}');
          developer.log(
            '📥 API Response:\n'
            '   Full Response: $result\n'
            '   Response Keys: ${result.keys.toList()}\n'
            '   Success: ${result['success']}\n'
            '   Error: ${result['error']}\n'
            '   Data: ${result['data']}',
            name: 'OnboardingBloc',
          );
          
          if (result['success'] == true) {
            // Check if OTP is already verified
            bool isOtpVerified = result['is_otp_verified'] ?? false;
            
            if (isOtpVerified) {
              print('✅ User exists and OTP already verified!');
              developer.log('✅ User exists and OTP already verified!', name: 'OnboardingBloc');
              
              // Login to get authentication token
              print('🔑 Logging in to get authentication token...');
              try {
                final loginResult = await ApiService.login(
                  phoneNumber: currentState.data.phoneNumber,
                  password: currentState.data.password,
                );
                
                if (loginResult['success'] == true) {
                  print('✅ Login successful! Token saved. Going to Basic Info...');
                  // OTP already verified and logged in, go directly to step 2 (Basic Info)
                  emit(currentState.copyWith(currentStep: 2));
                } else {
                  print('❌ Login failed: ${loginResult['error']}');
                  emit(OnboardingError(loginResult['error'] ?? 'Login failed'));
                  emit(currentState); // Return to current state
                }
              } catch (e) {
                print('❌ Login error: $e');
                emit(OnboardingError('Login error: ${e.toString()}'));
                emit(currentState);
              }
            } else {
              print('✅ Registration successful! Moving to OTP step...');
              developer.log('✅ Registration successful! Moving to OTP step...', name: 'OnboardingBloc');
              // OTP not verified, go to step 1 (OTP verification)
              emit(currentState.copyWith(currentStep: 1));
            }
          } else {
            print('❌ Registration failed: ${result['error']}');
            developer.log('❌ Registration failed: ${result['error']}', name: 'OnboardingBloc');
            // Registration failed
            emit(OnboardingError(result['error'] ?? 'Registration failed'));
            emit(currentState); // Return to current state
          }
        } catch (e) {
          print('💥 Exception during registration: $e');
          developer.log('💥 Exception during registration: $e', name: 'OnboardingBloc', error: e);
          emit(OnboardingError('Network error: ${e.toString()}'));
          emit(currentState); // Return to current state
        }
        return;
      }

      // Handle Step 1 → Step 2: Verify OTP
      if (currentState.currentStep == 1) {
        emit(const OnboardingLoading());
        
        try {
          print('🔐 Step 1: Verifying OTP...');
          final result = await ApiService.verifyOtp(
            phoneNumber: currentState.data.phoneNumber,
            code: currentState.data.otp,
          );
          
          if (result['success'] == true) {
            print('✅ OTP verified successfully!');
            
            // IMPORTANT: Now login to get the authentication token
            print('🔑 Logging in to get authentication token...');
            final loginResult = await ApiService.login(
              phoneNumber: currentState.data.phoneNumber,
              password: currentState.data.password,
            );
            
            if (loginResult['success'] == true) {
              print('✅ Login successful! Token saved.');
              // OTP verified and logged in successfully - proceed to next step
              emit(currentState.copyWith(currentStep: 2));
            } else {
              print('❌ Login failed after OTP verification: ${loginResult['error']}');
              emit(OnboardingError(loginResult['error'] ?? 'Login failed after OTP verification'));
              emit(currentState); // Return to current state
            }
          } else {
            // OTP verification failed - show error
            print('❌ OTP Error: ${result['error']}');
            emit(OnboardingError(result['error'] ?? 'Invalid OTP'));
            emit(currentState); // Return to current state
          }
        } catch (e) {
          print('❌ Network Error: ${e.toString()}');
          emit(OnboardingError('Network error: ${e.toString()}'));
          emit(currentState); // Return to current state
        }
        return;
      }

      // Check if we just completed the subscription step (step 6)
      print('🔍 [ONBOARDING_BLOC] Step check:');
      print('   Current Step: ${currentState.currentStep}');
      print('   Total Steps: ${currentState.totalSteps}');
      print('   Is Last Step: ${currentState.isLastStep}');
      print('   Expected Last Step: ${currentState.totalSteps - 1}');
      print('   Current Step Completed: ${currentState.data.isStepCompleted(currentState.currentStep)}');
      
      // Log step validation details
      for (int i = 0; i < currentState.totalSteps; i++) {
        bool stepCompleted = currentState.data.isStepCompleted(i);
        print('   Step $i: ${stepCompleted ? "✅ Complete" : "❌ Incomplete"}');
      }
      
      if (currentState.currentStep == 6) {
        print('🎯 [ONBOARDING_BLOC] Completed subscription step (step 6) - triggering vendor creation');
        add(const CompleteOnboarding());
      } else if (currentState.isLastStep) {
        print('🏁 [ONBOARDING_BLOC] Reached last step - triggering CompleteOnboarding event');
        add(const CompleteOnboarding());
      } else {
        print('➡️ [ONBOARDING_BLOC] Moving to next step: ${currentState.currentStep + 1}');
        // Move to next step (for other steps)
        emit(currentState.copyWith(
          currentStep: currentState.currentStep + 1,
        ));
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

  // Step 1: Phone Number Events
  void _onUpdatePhoneNumber(UpdatePhoneNumber event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(phoneNumber: event.phoneNumber),
      ));
    }
  }

  void _onUpdateVendorType(UpdateVendorType event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(vendorType: event.vendorType),
      ));
    }
  }

  void _onUpdatePassword(UpdatePassword event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(password: event.password),
      ));
    }
  }

  // Step 2: OTP Events
  void _onUpdateOTP(UpdateOTP event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(otp: event.otp),
      ));
    }
  }

  void _onResendOTP(ResendOTP event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      developer.log('📲 Resending OTP to ${currentState.data.phoneNumber}...', name: 'OnboardingBloc');
      
      try {
        final result = await ApiService.resendOtp(
          phoneNumber: currentState.data.phoneNumber,
        );
        
        developer.log('📥 Resend OTP Response: $result', name: 'OnboardingBloc');
        
        if (result['success'] != true) {
          developer.log('❌ Failed to resend OTP: ${result['error']}', name: 'OnboardingBloc');
          emit(OnboardingError(result['error'] ?? 'Failed to resend OTP'));
          emit(currentState); // Return to current state
        } else {
          developer.log('✅ OTP resent successfully!', name: 'OnboardingBloc');
        }
        // If successful, just stay on current state (OTP has been resent)
      } catch (e) {
        developer.log('💥 Exception during resend OTP: $e', name: 'OnboardingBloc', error: e);
        emit(OnboardingError('Network error: ${e.toString()}'));
        emit(currentState); // Return to current state
      }
    }
  }

  // Step 3: Basic Info Events
  void _onUpdateFirstName(UpdateFirstName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(firstName: event.firstName),
      ));
    }
  }

  void _onUpdateLastName(UpdateLastName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(lastName: event.lastName),
      ));
    }
  }

  void _onUpdateFullName(UpdateFullName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(fullName: event.fullName),
      ));
    }
  }

  void _onUpdateBusinessName(UpdateBusinessName event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(businessName: event.businessName),
      ));
    }
  }

  void _onUpdateEmail(UpdateEmail event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(email: event.email),
      ));
    }
  }

  void _onUpdateLanguagePreference(UpdateLanguagePreference event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(languagePreference: event.languagePreference),
      ));
    }
  }

  void _onUpdateCoverPhoto(UpdateCoverPhoto event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(coverPhotoUrl: event.coverPhotoUrl),
      ));
    }
  }

  void _onUpdateAddress(UpdateAddress event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          street: event.street,
          city: event.city,
          region: event.region,
          zone: event.zone,
          addressLine1: event.addressLine1,
          addressLine2: event.addressLine2,
          state: event.state,
          subcity: event.subcity,
          woreda: event.woreda,
          kebele: event.kebele,
          postalCode: event.postalCode,
          country: event.country,
        ),
      ));
    }
  }

  void _onUpdateBusinessDescription(UpdateBusinessDescription event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(businessDescription: event.businessDescription),
      ));
    }
  }

  void _onUpdateCategory(UpdateCategory event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(category: event.category),
      ));
    }
  }

  // Step 4: Documents Events
  void _onUpdateFaydaIdNumber(UpdateFaydaIdNumber event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(faydaIdNumber: event.faydaIdNumber),
      ));
    }
  }

  void _onUpdateBusinessLicenseNumber(UpdateBusinessLicenseNumber event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(businessLicenseNumber: event.businessLicenseNumber),
      ));
    }
  }

  void _onUpdateTaxId(UpdateTaxId event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(taxId: event.taxId),
      ));
    }
  }

  // Step 5: Subscription Events
  void _onSelectSubscription(SelectSubscription event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          selectedSubscriptionId: event.subscriptionId,
          selectedSubscriptionName: event.subscriptionName,
        ),
      ));
    }
  }

  void _onToggleTermsAgreement(ToggleTermsAgreement event, Emitter<OnboardingState> emit) {
    print('📋 [BLOC] ToggleTermsAgreement event received');
    print('📋 [BLOC] Agreed: ${event.agreed}');
    print('📋 [BLOC] Current state type: ${state.runtimeType}');
    
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      print('📋 [BLOC] Current agree terms: ${currentState.data.agreeTermsCheck}');
      
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          agreeTermsCheck: event.agreed,
        ),
      ));
      
      print('✅ [BLOC] Terms agreement updated to: ${event.agreed}');
    } else {
      print('⚠️ [BLOC] State is not OnboardingInProgress, cannot update terms agreement');
    }
  }

  // Shipping Address Event Handler
  void _onUpdateShippingAddress(UpdateShippingAddress event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          addressLine1: event.addressLine1,
          addressLine2: event.addressLine2,
          shippingCity: event.city,
          state: event.state,
          shippingRegion: event.region,
          subcity: event.subcity,
          woreda: event.woreda,
          kebele: event.kebele,
          postalCode: event.postalCode,
          country: event.country,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      ));
    }
  }

  // Step 6: Payout Event Handlers
  void _onUpdatePayoutMethod(UpdatePayoutMethod event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          preferredPayoutMethod: event.payoutMethod,
        ),
      ));
    }
  }

  void _onUpdateBankAccount(UpdateBankAccount event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          accountHolderName: event.accountHolderName,
          bankName: event.bankName,
          bankAccountNumber: event.bankAccountNumber,
        ),
      ));
    }
  }

  void _onUpdateMobileWallet(UpdateMobileWallet event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          mobileWalletNumber: event.mobileWalletNumber,
        ),
      ));
    }
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

  void _onUpdateSubscription(UpdateSubscription event, Emitter<OnboardingState> emit) {
    print('📦 [BLOC] UpdateSubscription event received');
    print('📦 [BLOC] Subscription ID: ${event.subscriptionId}');
    print('📦 [BLOC] Current state type: ${state.runtimeType}');
    
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      print('📦 [BLOC] Current selected subscription: ${currentState.data.selectedSubscriptionId}');
      
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          selectedSubscriptionId: event.subscriptionId,
        ),
      ));
      
      print('✅ [BLOC] Subscription updated successfully to: ${event.subscriptionId}');
    } else {
      print('⚠️ [BLOC] State is not OnboardingInProgress, cannot update subscription');
    }
  }

  void _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    print('🎯 [ONBOARDING_BLOC] ===== COMPLETE ONBOARDING EVENT RECEIVED =====');
    print('🎯 [ONBOARDING_BLOC] Starting vendor creation process...');
    
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Validate all previous steps are completed (don't check current step)
      bool allPreviousStepsCompleted = true;
      print('🔍 Validating steps...');
      print('   Current Step: ${currentState.currentStep}');
      print('   OTP Value: "${currentState.data.otp}" (length: ${currentState.data.otp.length})');
      print('   Phone: ${currentState.data.phoneNumber}');
      
      for (int i = 0; i < currentState.currentStep; i++) {
        bool stepCompleted = currentState.data.isStepCompleted(i);
        print('   Step $i: ${stepCompleted ? "✅ Complete" : "❌ Incomplete"}');
        if (!stepCompleted) {
          print('❌ Step $i is not completed');
          allPreviousStepsCompleted = false;
          break;
        }
      }
      
      if (!allPreviousStepsCompleted) {
        emit(const OnboardingError('Please complete all previous steps'));
        return;
      }
      
      // Validate current step (Payout) is also completed
      if (!currentState.data.isStepCompleted(currentState.currentStep)) {
        emit(const OnboardingError('Please complete the payout information'));
        return;
      }

      // Create business vendor (only business type supported)
      print('🏢 [ONBOARDING_BLOC] Starting business vendor creation...');
      print('🏢 [ONBOARDING_BLOC] Current step: ${currentState.currentStep}');
      print('🏢 [ONBOARDING_BLOC] Selected subscription: ${currentState.data.selectedSubscriptionId}');
      developer.log('🏢 Creating business vendor...', name: 'OnboardingBloc');
      emit(const OnboardingLoading());
        
        try {
          // Prepare data
          final data = currentState.data;
          
          // Parse single category
          int categoryId = 1; // Default category ID
          print('🏷️ [ONBOARDING_BLOC] Raw category data: "${data.category}"');
          
          if (data.category.isNotEmpty) {
            try {
              // Try to parse as direct ID if it's a number
              categoryId = int.parse(data.category);
              print('✅ [ONBOARDING_BLOC] Parsed category ID: $categoryId');
            } catch (e) {
              print('⚠️ [ONBOARDING_BLOC] Failed to parse category ID: ${data.category}, using default ID: 1');
              categoryId = 1; // Fallback to default
            }
          } else {
            print('⚠️ [ONBOARDING_BLOC] No category selected, using default category ID: 1');
            categoryId = 1;
          }
          
          print('✅ [ONBOARDING_BLOC] Final category ID: $categoryId');
          
          // Prepare payment method details
          print('💳 [ONBOARDING_BLOC] ===== PAYMENT METHOD DETAILS =====');
          print('💳 [ONBOARDING_BLOC] Preferred Payout Method: "${data.preferredPayoutMethod}"');
          print('💳 [ONBOARDING_BLOC] Bank Account Number: "${data.bankAccountNumber}"');
          print('💳 [ONBOARDING_BLOC] Mobile Wallet Number: "${data.mobileWalletNumber}"');
          print('💳 [ONBOARDING_BLOC] Account Holder Name: "${data.accountHolderName}"');
          print('💳 [ONBOARDING_BLOC] Bank Name: "${data.bankName}"');
          print('💳 [ONBOARDING_BLOC] Account Number (generic): "${data.accountNumber}"');
          
          final isBank = data.preferredPayoutMethod == 'bank_account';
          final paymentMethodType = isBank ? 'bank' : 'wallet';
          
          // Get account number from the appropriate field
          String accountNumber = '';
          if (isBank) {
            accountNumber = data.bankAccountNumber.isNotEmpty 
                ? data.bankAccountNumber 
                : data.accountNumber; // Fallback to generic accountNumber
          } else {
            accountNumber = data.mobileWalletNumber.isNotEmpty 
                ? data.mobileWalletNumber 
                : data.accountNumber; // Fallback to generic accountNumber
          }
          
          // Get account name (bank name or wallet provider)
          String accountName = '';
          if (isBank) {
            accountName = data.bankName.isNotEmpty ? data.bankName : 'Bank';
          } else {
            // Determine wallet provider from payment method
            if (data.preferredPayoutMethod == 'telebirr') {
              accountName = 'Telebirr';
            } else if (data.preferredPayoutMethod == 'cbe_birr') {
              accountName = 'CBE Birr';
            } else {
              accountName = 'Mobile Wallet';
            }
          }
          
          print('💳 [ONBOARDING_BLOC] ===== PROCESSED PAYMENT DATA =====');
          print('💳 [ONBOARDING_BLOC] Is Bank: $isBank');
          print('💳 [ONBOARDING_BLOC] Payment Method Type: $paymentMethodType');
          print('💳 [ONBOARDING_BLOC] Final Account Number: "$accountNumber"');
          print('💳 [ONBOARDING_BLOC] Final Account Name: "$accountName"');
          
          print('📝 [ONBOARDING_BLOC] Business Vendor Creation Data:');
          print('📝 [ONBOARDING_BLOC] Business Name: ${data.businessName}');
          print('📝 [ONBOARDING_BLOC] Description: ${data.businessDescription}');
          print('📝 [ONBOARDING_BLOC] Address Line 1: ${data.addressLine1}');
          print('📝 [ONBOARDING_BLOC] Address Line 2: ${data.addressLine2}');
          print('📝 [ONBOARDING_BLOC] City: ${data.shippingCity}');
          print('📝 [ONBOARDING_BLOC] State: ${data.state}');
          print('📝 [ONBOARDING_BLOC] Country: ${data.country}');
          print('📝 [ONBOARDING_BLOC] Category ID: $categoryId');
          print('📝 [ONBOARDING_BLOC] Subscription ID: ${data.selectedSubscriptionId}');
          print('👤 [ONBOARDING_BLOC] User Info:');
          print('   Full Name: ${data.fullName}');
          print('   Email: ${data.email}');
          print('   Phone: ${data.phoneNumber}');
          print('🏠 [ONBOARDING_BLOC] Ethiopian Address Fields:');
          print('   Region: ${data.shippingRegion}');
          print('   Subcity: ${data.subcity}');
          print('   Woreda: ${data.woreda}');
          print('   Kebele: ${data.kebele}');
          
          // Get file paths from XFile objects
          print('📄 [ONBOARDING_BLOC] ===== DOCUMENT FILES =====');
          print('📄 [ONBOARDING_BLOC] Cover Image File: ${data.coverImageFile}');
          print('📄 [ONBOARDING_BLOC] Cover Image Type: ${data.coverImageFile?.runtimeType}');
          print('📄 [ONBOARDING_BLOC] Business License File: ${data.businessLicenseFile}');
          print('📄 [ONBOARDING_BLOC] Business License Type: ${data.businessLicenseFile?.runtimeType}');
          
          // Validate files exist
          if (data.coverImageFile == null || data.businessLicenseFile == null) {
            print('❌ [ONBOARDING_BLOC] Missing required images!');
            emit(OnboardingVendorSubmissionFailed(
              data: currentState.data,
              apiResponse: {'success': false, 'error': 'Missing required document images'},
              error: 'Please upload both cover image and business license',
            ));
            return;
          }
          
          // For web: Read bytes directly from XFile, For mobile: Use path
          String coverImagePath = '';
          String businessLicensePath = '';
          
          try {
            if (kIsWeb) {
              print('🌐 [ONBOARDING_BLOC] Web platform - reading bytes from XFile...');
              // On web, we need to read bytes and convert to data URL
              final coverBytes = await data.coverImageFile.readAsBytes();
              final licenseBytes = await data.businessLicenseFile.readAsBytes();
              
              print('✅ [ONBOARDING_BLOC] Cover image bytes read: ${coverBytes.length} bytes');
              print('✅ [ONBOARDING_BLOC] License image bytes read: ${licenseBytes.length} bytes');
              
              // Convert to base64 data URLs
              final coverBase64 = base64Encode(coverBytes);
              final licenseBase64 = base64Encode(licenseBytes);
              
              // Determine MIME type from file name or default to jpeg
              String coverMime = 'image/jpeg';
              String licenseMime = 'image/jpeg';
              
              if (data.coverImageFile.name.toLowerCase().endsWith('.png')) {
                coverMime = 'image/png';
              }
              if (data.businessLicenseFile.name.toLowerCase().endsWith('.png')) {
                licenseMime = 'image/png';
              }
              
              coverImagePath = 'data:$coverMime;base64,$coverBase64';
              businessLicensePath = 'data:$licenseMime;base64,$licenseBase64';
              
              print('✅ [ONBOARDING_BLOC] Cover data URL created (${coverImagePath.length} chars)');
              print('✅ [ONBOARDING_BLOC] License data URL created (${businessLicensePath.length} chars)');
            } else {
              print('📱 [ONBOARDING_BLOC] Mobile platform - using file paths...');
              coverImagePath = data.coverImageFile.path;
              businessLicensePath = data.businessLicenseFile.path;
              print('✅ [ONBOARDING_BLOC] Cover image path: $coverImagePath');
              print('✅ [ONBOARDING_BLOC] Business license path: $businessLicensePath');
            }
          } catch (e) {
            print('❌ [ONBOARDING_BLOC] Error processing image files: $e');
            emit(OnboardingVendorSubmissionFailed(
              data: currentState.data,
              apiResponse: {'success': false, 'error': 'Failed to process images'},
              error: 'Error reading image files: ${e.toString()}',
            ));
            return;
          }
          
          print('🏢 [ONBOARDING_BLOC] ===== UNIFIED VENDOR REGISTRATION =====');
          print('⏳ [ONBOARDING_BLOC] Calling ApiService.registerBusinessVendor (unified)...');
          
          // Unified registration: handles both payment and vendor creation
          final result = await ApiService.registerBusinessVendor(
            name: data.businessName,
            description: data.businessDescription,
            fullName: data.fullName.isNotEmpty ? data.fullName : 'Unknown User',
            email: data.email.isNotEmpty ? data.email : 'user@example.com',
            phoneNumber: data.phoneNumber,
            addressLine1: data.addressLine1,
            addressLine2: data.addressLine2.isNotEmpty ? data.addressLine2 : null,
            city: data.shippingCity.isNotEmpty ? data.shippingCity : null,
            state: data.state.isNotEmpty ? data.state : null,
            region: data.shippingRegion.isNotEmpty ? data.shippingRegion : null,
            subcity: data.subcity.isNotEmpty ? data.subcity : null,
            woreda: data.woreda.isNotEmpty ? data.woreda : null,
            kebele: data.kebele.isNotEmpty ? data.kebele : null,
            postalCode: data.postalCode.isNotEmpty ? data.postalCode : null,
            country: data.country,
            categoryIds: [categoryId],
            paymentMethodType: paymentMethodType,
            accountHolderName: data.accountHolderName,
            accountNumber: accountNumber,
            accountName: accountName,
            coverImagePath: coverImagePath,
            businessLicenseImagePath: businessLicensePath,
            subscriptionId: data.selectedSubscriptionId ?? 1, // Default to subscription 1 if not selected
            // Payment configuration - using defaults for unified registration
            paymentAmount: 150.0, // Updated default amount
            paymentMethod: 'manual', // Manual payment method
            paymentProvider: 'bank_transfer', // Default provider
            currency: 'ETB', // Ethiopian Birr
          );
          
          print('📥 [ONBOARDING_BLOC] ===== API RESPONSE RECEIVED =====');
          print('📥 [ONBOARDING_BLOC] Full Response: $result');
          print('📥 [ONBOARDING_BLOC] Response Type: ${result.runtimeType}');
          print('📥 [ONBOARDING_BLOC] Success: ${result['success']}');
          print('📥 [ONBOARDING_BLOC] Keys: ${result.keys.toList()}');
          developer.log('📥 Business Vendor Creation Response: $result', name: 'OnboardingBloc');
          
          if (result['success'] == true) {
            print('✅ [ONBOARDING_BLOC] ===== VENDOR CREATION SUCCESSFUL =====');
            print('✅ [ONBOARDING_BLOC] Vendor Data: ${result['vendor']}');
            print('✅ [ONBOARDING_BLOC] Message: ${result['message']}');
            print('✅ [ONBOARDING_BLOC] Application submitted for review!');
            developer.log('✅ Business vendor created successfully!', name: 'OnboardingBloc');
            
            emit(OnboardingVendorSubmitted(
              data: currentState.data,
              apiResponse: result,
              message: result['message'] ?? 'Application submitted for review',
            ));
          } else {
            print('❌ [ONBOARDING_BLOC] ===== VENDOR CREATION FAILED =====');
            print('❌ [ONBOARDING_BLOC] Error: ${result['error']}');
            print('❌ [ONBOARDING_BLOC] Full Error Response: $result');
            developer.log('❌ Business vendor creation failed: ${result['error']}', name: 'OnboardingBloc');
            
            // Check if error indicates user already exists
            final errorMessage = result['error']?.toString().toLowerCase() ?? '';
            if (errorMessage.contains('user already exists') || 
                errorMessage.contains('email already exists') || 
                errorMessage.contains('phone already exists') ||
                errorMessage.contains('already registered') ||
                errorMessage.contains('duplicate user') ||
                errorMessage.contains('user exists')) {
              print('🔄 [ONBOARDING_BLOC] User already exists - redirecting to login');
              emit(OnboardingUserAlreadyExists(
                data: currentState.data,
                message: 'An account with this information already exists. Please login instead.',
                phoneNumber: currentState.data.phoneNumber,
                email: currentState.data.email,
              ));
            } else {
              emit(OnboardingVendorSubmissionFailed(
                data: currentState.data,
                apiResponse: result,
                error: result['error'] ?? 'Failed to create business vendor',
              ));
            }
          }
        } catch (e, stackTrace) {
          print('💥 [ONBOARDING_BLOC] ===== EXCEPTION DURING VENDOR CREATION =====');
          print('💥 [ONBOARDING_BLOC] Exception: $e');
          print('💥 [ONBOARDING_BLOC] Stack Trace: $stackTrace');
          developer.log('💥 Exception during business vendor creation: $e', name: 'OnboardingBloc', error: e, stackTrace: stackTrace);
          
          emit(OnboardingVendorSubmissionFailed(
            data: currentState.data,
            apiResponse: {'success': false, 'error': e.toString()},
            error: 'Network error: ${e.toString()}',
          ));
        }
    }
  }

  // Additional event handlers for step files
  void _onUpdateBusinessCategory(UpdateBusinessCategory event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(category: event.categoryId.toString()),
      ));
    }
  }

  void _onUpdateAddressLine1(UpdateAddressLine1 event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(addressLine1: event.addressLine1),
      ));
    }
  }

  void _onUpdateAddressLine2(UpdateAddressLine2 event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(addressLine2: event.addressLine2),
      ));
    }
  }

  void _onUpdateCity(UpdateCity event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(city: event.city),
      ));
    }
  }

  void _onUpdateState(UpdateState event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(state: event.state),
      ));
    }
  }

  void _onUpdatePostalCode(UpdatePostalCode event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(postalCode: event.postalCode),
      ));
    }
  }

  void _onUpdateBusinessLicense(UpdateBusinessLicense event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(businessLicenseFile: event.file),
      ));
    }
  }

  void _onUpdateCoverImage(UpdateCoverImage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(coverImageFile: event.file),
      ));
    }
  }

  // Fayda image not needed for business vendors
  // void _onUpdateFaydaImage(UpdateFaydaImage event, Emitter<OnboardingState> emit) {
  //   if (state is OnboardingInProgress) {
  //     final currentState = state as OnboardingInProgress;
  //     emit(currentState.copyWith(
  //       data: currentState.data.copyWith(faydaImageFile: event.file),
  //     ));
  //   }
  // }

  void _onUpdatePaymentMethod(UpdatePaymentMethod event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(preferredPayoutMethod: event.paymentMethod),
      ));
    }
  }

  void _onUpdateAccountHolder(UpdateAccountHolder event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(accountHolderName: event.accountHolder),
      ));
    }
  }

  void _onUpdateAccountNumber(UpdateAccountNumber event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(accountNumber: event.accountNumber),
      ));
    }
  }
}
