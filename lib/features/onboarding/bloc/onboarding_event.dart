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

/// Event to update full name
class UpdateFullName extends OnboardingEvent {
  final String fullName;

  const UpdateFullName(this.fullName);

  @override
  List<Object?> get props => [fullName];
}

/// Event to update whether user sells products online
class UpdateSellsProductsOnline extends OnboardingEvent {
  final bool sellsProductsOnline;

  const UpdateSellsProductsOnline(this.sellsProductsOnline);

  @override
  List<Object?> get props => [sellsProductsOnline];
}

/// Event to update monthly revenue
class UpdateMonthlyRevenue extends OnboardingEvent {
  final String monthlyRevenue;

  const UpdateMonthlyRevenue(this.monthlyRevenue);

  @override
  List<Object?> get props => [monthlyRevenue];
}

/// Event to update email address
class UpdateEmailAddress extends OnboardingEvent {
  final String emailAddress;

  const UpdateEmailAddress(this.emailAddress);

  @override
  List<Object?> get props => [emailAddress];
}

/// Event to complete onboarding
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}
