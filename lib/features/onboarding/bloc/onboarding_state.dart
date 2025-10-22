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
    this.totalSteps = 8,
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

/// Vendor submission successful state
class OnboardingVendorSubmitted extends OnboardingState {
  final OnboardingData data;
  final Map<String, dynamic> apiResponse;
  final String message;

  const OnboardingVendorSubmitted({
    required this.data,
    required this.apiResponse,
    this.message = 'Application submitted for review',
  });

  @override
  List<Object?> get props => [data, apiResponse, message];
}

/// Vendor submission failed state
class OnboardingVendorSubmissionFailed extends OnboardingState {
  final OnboardingData data;
  final Map<String, dynamic> apiResponse;
  final String error;

  const OnboardingVendorSubmissionFailed({
    required this.data,
    required this.apiResponse,
    required this.error,
  });

  @override
  List<Object?> get props => [data, apiResponse, error];
}

/// Loading state
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Business name conflict state - when vendor name already exists
class OnboardingBusinessNameConflict extends OnboardingState {
  final OnboardingData data;
  final String suggestedName;
  final String originalName;

  const OnboardingBusinessNameConflict({
    required this.data,
    required this.suggestedName,
    required this.originalName,
  });

  @override
  List<Object?> get props => [data, suggestedName, originalName];
}

/// Error state
class OnboardingError extends OnboardingState {
  final String message;
  final int step;          // which step the error occurred on
  final String? code;      // machine code e.g. USER_ALREADY_EXISTS, INVALID_OTP
  final bool recoverable;  // whether to show Retry

  const OnboardingError(
    this.message, {
    required this.step,
    this.code,
    this.recoverable = true,
  });

  @override
  List<Object?> get props => [message, step, code, recoverable];
}
