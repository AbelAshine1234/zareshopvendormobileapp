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
    on<UpdateFullName>(_onUpdateFullName);
    on<UpdateSellsProductsOnline>(_onUpdateSellsProductsOnline);
    on<UpdateMonthlyRevenue>(_onUpdateMonthlyRevenue);
    on<UpdateEmailAddress>(_onUpdateEmailAddress);
    on<CompleteOnboarding>(_onCompleteOnboarding);
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
          fullName: 'Arthur Taylor',
          sellsProductsOnline: true,
          monthlyRevenue: '5k_10k',
          emailAddress: 'arthur.taylor@zareshop.com',
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

  void _onUpdateFullName(
    UpdateFullName event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(fullName: event.fullName),
      ));
    }
  }

  void _onUpdateSellsProductsOnline(
    UpdateSellsProductsOnline event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          sellsProductsOnline: event.sellsProductsOnline,
        ),
      ));
    }
  }

  void _onUpdateMonthlyRevenue(
    UpdateMonthlyRevenue event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(monthlyRevenue: event.monthlyRevenue),
      ));
    }
  }

  void _onUpdateEmailAddress(
    UpdateEmailAddress event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(emailAddress: event.emailAddress),
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
