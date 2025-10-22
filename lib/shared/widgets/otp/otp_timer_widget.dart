import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable OTP countdown timer widget that can be used across the app
class OTPTimerWidget extends StatefulWidget {
  /// The initial countdown duration in seconds (default: 60)
  final int initialDuration;
  
  /// Callback when the timer reaches zero
  final VoidCallback? onTimerComplete;
  
  /// Callback when the timer is manually reset
  final VoidCallback? onTimerReset;
  
  /// Custom text style for the countdown display
  final TextStyle? textStyle;
  
  /// Custom text color for the countdown display
  final Color? textColor;
  
  /// Whether to show "Resend" text when timer is complete
  final bool showResendText;
  
  /// Custom "Resend" text
  final String resendText;
  
  /// Whether to auto-start the timer when widget is created
  final bool autoStart;

  const OTPTimerWidget({
    super.key,
    this.initialDuration = 60,
    this.onTimerComplete,
    this.onTimerReset,
    this.textStyle,
    this.textColor,
    this.showResendText = true,
    this.resendText = 'Resend',
    this.autoStart = true,
  });

  @override
  State<OTPTimerWidget> createState() => _OTPTimerWidgetState();
}

class _OTPTimerWidgetState extends State<OTPTimerWidget> {
  Timer? _timer;
  int _countdown = 0;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = widget.initialDuration;
      _isActive = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _onTimerComplete();
      }
    });
  }

  /// Handle timer completion
  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _isActive = false);
    widget.onTimerComplete?.call();
  }

  /// Reset the timer to initial duration
  void resetTimer() {
    _startTimer();
    widget.onTimerReset?.call();
  }

  /// Get the current countdown value
  int get currentCountdown => _countdown;

  /// Check if timer is currently active
  bool get isActive => _isActive;

  /// Check if timer has completed
  bool get isCompleted => !_isActive && _countdown == 0;

  @override
  Widget build(BuildContext context) {
    if (_isActive) {
      // Show countdown
      return Text(
        '${_countdown}s',
        style: widget.textStyle ?? 
          TextStyle(
            color: widget.textColor ?? Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
      );
    } else if (widget.showResendText) {
      // Show resend text when timer is complete
      return Text(
        widget.resendText,
        style: widget.textStyle ?? 
          TextStyle(
            color: widget.textColor ?? Theme.of(context).primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
      );
    } else {
      // Show nothing when timer is complete and resend text is disabled
      return const SizedBox.shrink();
    }
  }
}

/// A more advanced OTP timer widget with resend button functionality
class OTPTimerWithResendWidget extends StatefulWidget {
  /// The initial countdown duration in seconds (default: 60)
  final int initialDuration;
  
  /// Callback when resend button is pressed
  final VoidCallback? onResendPressed;
  
  /// Custom text style for the countdown display
  final TextStyle? textStyle;
  
  /// Custom text color for the countdown display
  final Color? textColor;
  
  /// Custom "Resend" text
  final String resendText;
  
  /// Whether to auto-start the timer when widget is created
  final bool autoStart;
  
  /// Whether the resend button is enabled
  final bool isResendEnabled;

  const OTPTimerWithResendWidget({
    super.key,
    this.initialDuration = 60,
    this.onResendPressed,
    this.textStyle,
    this.textColor,
    this.resendText = 'Resend',
    this.autoStart = true,
    this.isResendEnabled = true,
  });

  @override
  State<OTPTimerWithResendWidget> createState() => _OTPTimerWithResendWidgetState();
}

class _OTPTimerWithResendWidgetState extends State<OTPTimerWithResendWidget> {
  final GlobalKey<_OTPTimerWidgetState> _timerKey = GlobalKey<_OTPTimerWidgetState>();

  /// Reset the timer and call the resend callback
  void _handleResend() {
    if (widget.isResendEnabled && !_timerKey.currentState!.isActive) {
      _timerKey.currentState!.resetTimer();
      widget.onResendPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OTPTimerWidget(
          key: _timerKey,
          initialDuration: widget.initialDuration,
          textStyle: widget.textStyle,
          textColor: widget.textColor,
          showResendText: false,
          autoStart: widget.autoStart,
        ),
        if (!(_timerKey.currentState?.isActive ?? false))
          GestureDetector(
            onTap: _handleResend,
            child: Text(
              widget.resendText,
              style: widget.textStyle ?? 
                TextStyle(
                  color: widget.isResendEnabled 
                    ? (widget.textColor ?? Theme.of(context).primaryColor)
                    : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: widget.isResendEnabled 
                    ? TextDecoration.underline 
                    : TextDecoration.none,
                ),
            ),
          ),
      ],
    );
  }
}
