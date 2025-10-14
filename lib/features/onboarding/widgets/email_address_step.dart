import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class EmailAddressStep extends StatefulWidget {
  const EmailAddressStep({super.key});

  @override
  State<EmailAddressStep> createState() => _EmailAddressStepState();
}

class _EmailAddressStepState extends State<EmailAddressStep> {
  late TextEditingController _controller;
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    
    // Initialize with current value if exists
    final state = context.read<OnboardingBloc>().state;
    if (state is OnboardingInProgress) {
      _controller.text = state.data.emailAddress;
      _isValidEmail = _validateEmail(state.data.emailAddress);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _isValidEmail = _validateEmail(value);
                  });
                  context.read<OnboardingBloc>().add(UpdateEmailAddress(value));
                },
                onSubmitted: (_) {
                  if (state.canProceed) {
                    context.read<OnboardingBloc>().add(const NextStep());
                  }
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: state.canProceed
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                        )
                      : (_controller.text.isNotEmpty && !_isValidEmail)
                          ? const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                            )
                          : null,
                ),
                textInputAction: TextInputAction.done,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              if (_controller.text.isNotEmpty && !_isValidEmail)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 5 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Please enter a valid email address',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (state.canProceed)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Email: ${state.data.emailAddress}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
