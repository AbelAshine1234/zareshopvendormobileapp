import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/onboarding_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<InitializeOnboarding>(_onInitializeOnboarding);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<GoToStep>(_onGoToStep);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    
    // Step 1: Phone Number
    on<UpdatePhoneNumber>(_onUpdatePhoneNumber);
    on<UpdateVendorType>(_onUpdateVendorType);
    
    // Step 2: OTP
    on<UpdateOTP>(_onUpdateOTP);
    on<ResendOTP>(_onResendOTP);
    
    // Step 3: Basic Info
    on<UpdateFullName>(_onUpdateFullName);
    on<UpdateBusinessName>(_onUpdateBusinessName);
    on<UpdateEmail>(_onUpdateEmail);
    on<UpdateLanguagePreference>(_onUpdateLanguagePreference);
    on<UpdateAddress>(_onUpdateAddress);
    on<UpdateBusinessDescription>(_onUpdateBusinessDescription);
    on<UpdateCategory>(_onUpdateCategory);
    
    // Step 4: Documents
    on<UpdateFaydaIdNumber>(_onUpdateFaydaIdNumber);
    on<UpdateBusinessLicenseNumber>(_onUpdateBusinessLicenseNumber);
    on<UpdateTaxId>(_onUpdateTaxId);
    
    // Step 5: Payout
    on<UpdatePayoutMethod>(_onUpdatePayoutMethod);
    on<UpdateBankAccount>(_onUpdateBankAccount);
    on<UpdateMobileWallet>(_onUpdateMobileWallet);
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
          vendorType: 'individual',
          otp: '123456',
          fullName: 'Arthur Taylor',
          email: 'arthur.taylor@zareshop.com',
          street: 'Bole Road',
          city: 'Addis Ababa',
          category: 'electronics',
          businessDescription: 'Selling quality electronics',
          faydaIdNumber: 'FYD123456',
          preferredPayoutMethod: 'wallet',
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
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Check if current step is completed
      if (!currentState.canProceed) {
        return;
      }

      // Check if it's the last step
      if (currentState.isLastStep) {
        emit(OnboardingCompleted(currentState.data));
      } else {
        // Move to next step
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

  // Step 2: OTP Events
  void _onUpdateOTP(UpdateOTP event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(otp: event.otp),
      ));
    }
  }

  void _onResendOTP(ResendOTP event, Emitter<OnboardingState> emit) {
    // TODO: Implement OTP resend logic
    // This would typically call a backend service to resend OTP
  }

  // Step 3: Basic Info Events
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

  void _onUpdateAddress(UpdateAddress event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          street: event.street,
          city: event.city,
          region: event.region,
          zone: event.zone,
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

  // Step 5: Payout Events
  void _onUpdatePayoutMethod(UpdatePayoutMethod event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(preferredPayoutMethod: event.payoutMethod),
      ));
    }
  }

  void _onUpdateBankAccount(UpdateBankAccount event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          bankAccountNumber: event.bankAccountNumber,
          bankName: event.bankName,
        ),
      ));
    }
  }

  void _onUpdateMobileWallet(UpdateMobileWallet event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(mobileWalletNumber: event.mobileWalletNumber),
      ));
    }
  }

  void _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Validate all steps are completed
      bool allStepsCompleted = true;
      for (int i = 0; i < currentState.totalSteps; i++) {
        if (!currentState.data.isStepCompleted(i)) {
          allStepsCompleted = false;
          break;
        }
      }
      
      if (allStepsCompleted) {
        emit(OnboardingCompleted(currentState.data));
      } else {
        emit(const OnboardingError('Please complete all steps'));
      }
    }
  }
}
