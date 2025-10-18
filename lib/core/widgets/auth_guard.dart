import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';

/// Widget that protects routes by checking authentication status using BLoC
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo = '/splash',
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    print('🔒 [AUTH_GUARD] initState() called');
    print('🔒 [AUTH_GUARD] Child widget: ${widget.child.runtimeType}');
    print('🔒 [AUTH_GUARD] Redirect to: ${widget.redirectTo}');
    // Check authentication status when the guard is initialized
    context.read<AuthBloc>().add(const CheckAuthenticationStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔒 [AUTH_GUARD] BlocListener received state: ${state.runtimeType}');
        if (state is AuthUnauthenticated) {
          print('🔒 [AUTH_GUARD] User is unauthenticated, redirecting to: ${widget.redirectTo}');
          // Redirect to splash screen if not authenticated
          if (mounted) {
            print('🔒 [AUTH_GUARD] Widget is mounted, performing redirect...');
            context.go(widget.redirectTo);
          } else {
            print('🔒 [AUTH_GUARD] Widget not mounted, skipping redirect');
          }
        } else if (state is AuthAuthenticated) {
          print('🔒 [AUTH_GUARD] User is authenticated, showing protected content');
        } else if (state is AuthChecking) {
          print('🔒 [AUTH_GUARD] Checking authentication status...');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('🔒 [AUTH_GUARD] BlocBuilder building with state: ${state.runtimeType}');
          if (state is AuthChecking) {
            print('🔒 [AUTH_GUARD] Showing loading indicator (checking auth)');
            // Show loading while checking authentication
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthAuthenticated) {
            print('🔒 [AUTH_GUARD] User authenticated, showing protected content: ${widget.child.runtimeType}');
            // User is authenticated, show the protected content
            return widget.child;
          } else {
            print('🔒 [AUTH_GUARD] User not authenticated, showing loading (will redirect via listener)');
            // User is not authenticated, show loading (will redirect via listener)
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
