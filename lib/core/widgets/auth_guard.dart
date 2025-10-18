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
    // Check authentication status when the guard is initialized
    context.read<AuthBloc>().add(const CheckAuthenticationStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Redirect to splash screen if not authenticated
          if (mounted) {
            context.go(widget.redirectTo);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthChecking) {
            // Show loading while checking authentication
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthAuthenticated) {
            // User is authenticated, show the protected content
            return widget.child;
          } else {
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
