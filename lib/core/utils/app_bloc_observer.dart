import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('✨ BlocCreated: ${bloc.runtimeType}');
    developer.log(
      '✨ BlocCreated: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('📤 Event: ${bloc.runtimeType} -> ${event.runtimeType}');
    developer.log(
      '📤 Event: ${bloc.runtimeType} -> ${event.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔄 State Change: ${bloc.runtimeType}');
    print('   From: ${change.currentState.runtimeType}');
    print('   To:   ${change.nextState.runtimeType}');
    developer.log(
      '🔄 State Change: ${bloc.runtimeType}\n'
      '   From: ${change.currentState.runtimeType}\n'
      '   To:   ${change.nextState.runtimeType}',
      name: 'BlocObserver',
    );
    
    // Log detailed state info for debugging
    _logDetailedState(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('➡️  Transition: ${bloc.runtimeType}');
    print('   Event: ${transition.event.runtimeType}');
    print('   From:  ${transition.currentState.runtimeType}');
    print('   To:    ${transition.nextState.runtimeType}');
    developer.log(
      '➡️  Transition: ${bloc.runtimeType}\n'
      '   Event: ${transition.event.runtimeType}\n'
      '   From:  ${transition.currentState.runtimeType}\n'
      '   To:    ${transition.nextState.runtimeType}',
      name: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('❌ Error in ${bloc.runtimeType}: $error');
    developer.log(
      '❌ Error in ${bloc.runtimeType}: $error',
      name: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('🔚 BlocClosed: ${bloc.runtimeType}');
    developer.log(
      '🔚 BlocClosed: ${bloc.runtimeType}',
      name: 'BlocObserver',
    );
  }

  // Helper method to log detailed state information
  void _logDetailedState(BlocBase bloc, Change change) {
    // Log OnboardingInProgress details
    if (change.nextState.runtimeType.toString().contains('OnboardingInProgress')) {
      try {
        final state = change.nextState as dynamic;
        if (state.currentStep != null && state.data != null) {
          print('📊 Onboarding Details:');
          print('   Current Step: ${state.currentStep}');
          print('   Total Steps: ${state.totalSteps}');
          print('   Progress: ${(state.progress * 100).toStringAsFixed(1)}%');
          print('   Phone: ${state.data.phoneNumber}');
          print('   Vendor Type: ${state.data.vendorType}');
          print('   Can Proceed: ${state.canProceed}');
          developer.log(
            '📊 Onboarding Details:\n'
            '   Current Step: ${state.currentStep}\n'
            '   Total Steps: ${state.totalSteps}\n'
            '   Progress: ${(state.progress * 100).toStringAsFixed(1)}%\n'
            '   Phone: ${state.data.phoneNumber}\n'
            '   Vendor Type: ${state.data.vendorType}\n'
            '   Can Proceed: ${state.canProceed}',
            name: 'BlocObserver',
          );
        }
      } catch (e) {
        // Ignore if casting fails
      }
    }

    // Log OnboardingError details
    if (change.nextState.runtimeType.toString().contains('OnboardingError')) {
      try {
        final state = change.nextState as dynamic;
        if (state.message != null) {
          print('⚠️  Onboarding Error: ${state.message}');
          developer.log(
            '⚠️  Onboarding Error: ${state.message}',
            name: 'BlocObserver',
          );
        }
      } catch (e) {
        // Ignore if casting fails
      }
    }

    // Log AuthError details
    if (change.nextState.runtimeType.toString().contains('AuthError')) {
      try {
        final state = change.nextState as dynamic;
        if (state.message != null) {
          print('⚠️  Auth Error: ${state.message}');
          developer.log(
            '⚠️  Auth Error: ${state.message}',
            name: 'BlocObserver',
          );
        }
      } catch (e) {
        // Ignore if casting fails
      }
    }
  }
}
