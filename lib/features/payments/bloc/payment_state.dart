import 'package:equatable/equatable.dart';
import '../models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

// Initial State
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

// Loading States
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentListLoading extends PaymentState {
  const PaymentListLoading();
}

class PaymentStatisticsLoading extends PaymentState {
  const PaymentStatisticsLoading();
}

// Success States
class PaymentCreated extends PaymentState {
  final Payment payment;
  final PaymentInstructions? paymentInstructions;

  const PaymentCreated({
    required this.payment,
    this.paymentInstructions,
  });

  @override
  List<Object?> get props => [payment, paymentInstructions];
}

class PaymentLoaded extends PaymentState {
  final Payment payment;

  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentListLoaded extends PaymentState {
  final List<Payment> payments;
  final Pagination pagination;

  const PaymentListLoaded({
    required this.payments,
    required this.pagination,
  });

  @override
  List<Object?> get props => [payments, pagination];
}

class PaymentStatusUpdated extends PaymentState {
  final Payment payment;

  const PaymentStatusUpdated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentProofUploaded extends PaymentState {
  final Payment payment;

  const PaymentProofUploaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentProcessed extends PaymentState {
  final Payment payment;

  const PaymentProcessed(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentProceeded extends PaymentState {
  final Payment payment;
  final NextStep nextStep;

  const PaymentProceeded({
    required this.payment,
    required this.nextStep,
  });

  @override
  List<Object?> get props => [payment, nextStep];
}

class QRCodeGenerated extends PaymentState {
  final String qrData;
  final String qrCode;

  const QRCodeGenerated({
    required this.qrData,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [qrData, qrCode];
}

class PaymentStatisticsLoaded extends PaymentState {
  final PaymentStatistics statistics;

  const PaymentStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class PaymentVerified extends PaymentState {
  final Payment payment;

  const PaymentVerified(this.payment);

  @override
  List<Object?> get props => [payment];
}

class VendorApplicationReviewed extends PaymentState {
  final String message;

  const VendorApplicationReviewed(this.message);

  @override
  List<Object?> get props => [message];
}

// Error States
class PaymentError extends PaymentState {
  final String message;
  final String? errorCode;

  const PaymentError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class PaymentListError extends PaymentState {
  final String message;

  const PaymentListError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentStatisticsError extends PaymentState {
  final String message;

  const PaymentStatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Next Step Model
class NextStep extends Equatable {
  final String step;
  final bool canProceed;
  final String message;
  final List<NextStepAction> actions;

  const NextStep({
    required this.step,
    required this.canProceed,
    required this.message,
    required this.actions,
  });

  factory NextStep.fromJson(Map<String, dynamic> json) {
    return NextStep(
      step: json['step'] as String,
      canProceed: json['can_proceed'] as bool,
      message: json['message'] as String,
      actions: (json['actions'] as List)
          .map((action) => NextStepAction.fromJson(action))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [step, canProceed, message, actions];
}

class NextStepAction extends Equatable {
  final String action;
  final String label;
  final String description;
  final bool primary;
  final bool warning;
  final String? url;

  const NextStepAction({
    required this.action,
    required this.label,
    required this.description,
    required this.primary,
    this.warning = false,
    this.url,
  });

  factory NextStepAction.fromJson(Map<String, dynamic> json) {
    return NextStepAction(
      action: json['action'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      primary: json['primary'] as bool,
      warning: json['warning'] as bool? ?? false,
      url: json['url'] as String?,
    );
  }

  @override
  List<Object?> get props => [action, label, description, primary, warning, url];
}

