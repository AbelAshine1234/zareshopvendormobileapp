import 'package:equatable/equatable.dart';
import '../models/payment_model.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

// Create Payment Events
class CreatePayment extends PaymentEvent {
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentProvider paymentProvider;
  final String currency;

  const CreatePayment({
    required this.amount,
    required this.paymentMethod,
    required this.paymentProvider,
    this.currency = 'ETB',
  });

  @override
  List<Object?> get props => [amount, paymentMethod, paymentProvider, currency];
}

class CreateMobilePayment extends PaymentEvent {
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentProvider paymentProvider;
  final String currency;

  const CreateMobilePayment({
    required this.amount,
    required this.paymentMethod,
    required this.paymentProvider,
    this.currency = 'ETB',
  });

  @override
  List<Object?> get props => [amount, paymentMethod, paymentProvider, currency];
}

// Get Payment Events
class GetPaymentById extends PaymentEvent {
  final int paymentId;

  const GetPaymentById(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class GetMyPayments extends PaymentEvent {
  final PaymentStatus? status;
  final PaymentMethod? paymentMethod;
  final int page;
  final int limit;

  const GetMyPayments({
    this.status,
    this.paymentMethod,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, paymentMethod, page, limit];
}

class RefreshPayments extends PaymentEvent {
  const RefreshPayments();
}

// Update Payment Events
class UpdatePaymentStatus extends PaymentEvent {
  final int paymentId;
  final PaymentStatus status;
  final String? externalPaymentId;
  final String? paymentReference;

  const UpdatePaymentStatus({
    required this.paymentId,
    required this.status,
    this.externalPaymentId,
    this.paymentReference,
  });

  @override
  List<Object?> get props => [paymentId, status, externalPaymentId, paymentReference];
}

class ProcessIntegratedPayment extends PaymentEvent {
  final int paymentId;
  final String externalPaymentId;
  final String paymentReference;

  const ProcessIntegratedPayment({
    required this.paymentId,
    required this.externalPaymentId,
    required this.paymentReference,
  });

  @override
  List<Object?> get props => [paymentId, externalPaymentId, paymentReference];
}

// Payment Proof Events
class UploadPaymentProof extends PaymentEvent {
  final int paymentId;
  final int imageId;

  const UploadPaymentProof({
    required this.paymentId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [paymentId, imageId];
}

class UploadPaymentProofFile extends PaymentEvent {
  final int paymentId;
  final String filePath;

  const UploadPaymentProofFile({
    required this.paymentId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [paymentId, filePath];
}

// Payment Flow Events
class ProceedToNextStep extends PaymentEvent {
  final int paymentId;
  final bool forceProceed;

  const ProceedToNextStep({
    required this.paymentId,
    this.forceProceed = false,
  });

  @override
  List<Object?> get props => [paymentId, forceProceed];
}

class GenerateQRCode extends PaymentEvent {
  final int paymentId;

  const GenerateQRCode(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

// Admin Events
class GetAdminPayments extends PaymentEvent {
  final PaymentStatus? status;
  final PaymentMethod? paymentMethod;
  final PaymentProvider? paymentProvider;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  const GetAdminPayments({
    this.status,
    this.paymentMethod,
    this.paymentProvider,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
        status,
        paymentMethod,
        paymentProvider,
        startDate,
        endDate,
        page,
        limit,
      ];
}

class GetPendingPayments extends PaymentEvent {
  const GetPendingPayments();
}

class VerifyManualPayment extends PaymentEvent {
  final int paymentId;
  final bool approved;
  final String? adminNotes;

  const VerifyManualPayment({
    required this.paymentId,
    required this.approved,
    this.adminNotes,
  });

  @override
  List<Object?> get props => [paymentId, approved, adminNotes];
}

class GetPaymentStatistics extends PaymentEvent {
  const GetPaymentStatistics();
}

class GetVendorApplications extends PaymentEvent {
  const GetVendorApplications();
}

class ReviewVendorApplication extends PaymentEvent {
  final int applicationId;
  final bool approved;
  final String? adminNotes;
  final bool paymentApproved;

  const ReviewVendorApplication({
    required this.applicationId,
    required this.approved,
    this.adminNotes,
    this.paymentApproved = false,
  });

  @override
  List<Object?> get props => [applicationId, approved, adminNotes, paymentApproved];
}

// Clear Events
class ClearPaymentError extends PaymentEvent {
  const ClearPaymentError();
}

class ResetPaymentState extends PaymentEvent {
  const ResetPaymentState();
}

