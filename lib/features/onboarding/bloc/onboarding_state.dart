import 'package:equatable/equatable.dart';
import '../models/onboarding_data.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// In-progress state with current step and data
class OnboardingInProgress extends OnboardingState {
  final int currentStep;
  final OnboardingData data;
  final int totalSteps;

  const OnboardingInProgress({
    required this.currentStep,
    required this.data,
    this.totalSteps = 6,
  });

  OnboardingInProgress copyWith({
    int? currentStep,
    OnboardingData? data,
    int? totalSteps,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  bool get canProceed => data.isStepCompleted(currentStep);
  
  double get progress => (currentStep + 1) / totalSteps;

  @override
  List<Object?> get props => [currentStep, data, totalSteps];
}

/// Completed state
class OnboardingCompleted extends OnboardingState {
  final OnboardingData data;

  const OnboardingCompleted(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
