import '../../../core/services/api_service.dart';
import '../models/payment_model.dart';

class PaymentService {
  // Create Payment
  static Future<PaymentResponse> createPayment({
    required String token,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentProvider paymentProvider,
    String currency = 'ETB',
  }) async {
    try {
      final response = await ApiService.createPayment(
        token: token,
        amount: amount,
        paymentMethod: paymentMethod.name,
        paymentProvider: paymentProvider.name,
        currency: currency,
      );
      
      if (response['success'] == true) {
        return PaymentResponse.fromJson(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to create payment');
      }
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Create Mobile Payment
  static Future<PaymentResponse> createMobilePayment({
    required String token,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentProvider paymentProvider,
    String currency = 'ETB',
  }) async {
    try {
      final response = await ApiService.createMobilePayment(
        token: token,
        amount: amount,
        paymentMethod: paymentMethod.name,
        paymentProvider: paymentProvider.name,
        currency: currency,
      );
      
      if (response['success'] == true) {
        return PaymentResponse.fromJson(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to create mobile payment');
      }
    } catch (e) {
      throw Exception('Failed to create mobile payment: $e');
    }
  }

  // Get Payment by ID
  static Future<Payment> getPaymentById({
    required String token,
    required int paymentId,
  }) async {
    try {
      final response = await ApiService.getPaymentById(
        token: token,
        paymentId: paymentId,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to get payment');
      }
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // Get My Payments
  static Future<PaymentListResponse> getMyPayments({
    required String token,
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentMethod,
  }) async {
    try {
      final response = await ApiService.getMyPayments(
        token: token,
        page: page,
        limit: limit,
        status: status,
        paymentMethod: paymentMethod,
      );
      
      if (response['success'] == true) {
        return PaymentListResponse.fromJson(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get payments');
      }
    } catch (e) {
      throw Exception('Failed to get payments: $e');
    }
  }

  // Update Payment Status
  static Future<Payment> updatePaymentStatus({
    required String token,
    required int paymentId,
    required PaymentStatus status,
    String? externalPaymentId,
    String? paymentReference,
  }) async {
    try {
      final response = await ApiService.updatePaymentStatus(
        token: token,
        paymentId: paymentId,
        status: status.name,
        externalPaymentId: externalPaymentId,
        paymentReference: paymentReference,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to update payment status');
      }
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Process Integrated Payment
  static Future<Payment> processIntegratedPayment({
    required String token,
    required int paymentId,
    required String externalPaymentId,
    required String paymentReference,
  }) async {
    try {
      final response = await ApiService.processIntegratedPayment(
        token: token,
        paymentId: paymentId,
        externalPaymentId: externalPaymentId,
        paymentReference: paymentReference,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to process integrated payment');
      }
    } catch (e) {
      throw Exception('Failed to process integrated payment: $e');
    }
  }

  // Upload Payment Proof
  static Future<Payment> uploadPaymentProof({
    required String token,
    required int paymentId,
    required int imageId,
  }) async {
    try {
      final response = await ApiService.uploadPaymentProof(
        token: token,
        paymentId: paymentId,
        imageId: imageId,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to upload payment proof');
      }
    } catch (e) {
      throw Exception('Failed to upload payment proof: $e');
    }
  }

  // Upload Payment Proof File
  static Future<Payment> uploadPaymentProofFile({
    required String token,
    required int paymentId,
    required String filePath,
  }) async {
    try {
      final response = await ApiService.uploadPaymentProofFile(
        token: token,
        paymentId: paymentId,
        filePath: filePath,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to upload payment proof file');
      }
    } catch (e) {
      throw Exception('Failed to upload payment proof file: $e');
    }
  }

  // Proceed to Next Step
  static Future<NextStep> proceedToNextStep({
    required String token,
    required int paymentId,
    bool forceProceed = false,
  }) async {
    try {
      final response = await ApiService.proceedToNextStep(
        token: token,
        paymentId: paymentId,
        forceProceed: forceProceed,
      );
      
      if (response['success'] == true) {
        return NextStep.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to proceed to next step');
      }
    } catch (e) {
      throw Exception('Failed to proceed to next step: $e');
    }
  }

  // Generate QR Code
  static Future<PaymentQRData> generateQrCode({
    required String token,
    required int paymentId,
  }) async {
    try {
      final response = await ApiService.generateQRCode(
        token: token,
        paymentId: paymentId,
      );
      
      if (response['success'] == true) {
        return PaymentQRData.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to generate QR code');
      }
    } catch (e) {
      throw Exception('Failed to generate QR code: $e');
    }
  }

  // Admin - Get All Payments
  static Future<PaymentListResponse> getAllPayments({
    required String token,
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentMethod,
    String? paymentProvider,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await ApiService.getAllPayments(
        token: token,
        page: page,
        limit: limit,
        status: status,
        paymentMethod: paymentMethod,
        paymentProvider: paymentProvider,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (response['success'] == true) {
        return PaymentListResponse.fromJson(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get all payments');
      }
    } catch (e) {
      throw Exception('Failed to get all payments: $e');
    }
  }

  // Admin - Get Pending Payments
  static Future<PaymentListResponse> getPendingPayments({
    required String token,
  }) async {
    try {
      final response = await ApiService.getPendingPayments(
        token: token,
      );
      
      if (response['success'] == true) {
        return PaymentListResponse.fromJson(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get pending payments');
      }
    } catch (e) {
      throw Exception('Failed to get pending payments: $e');
    }
  }

  // Admin - Verify Manual Payment
  static Future<Payment> verifyManualPayment({
    required String token,
    required int paymentId,
    required bool approved,
    String? adminNotes,
  }) async {
    try {
      final response = await ApiService.verifyManualPayment(
        token: token,
        paymentId: paymentId,
        approved: approved,
        adminNotes: adminNotes,
      );
      
      if (response['success'] == true) {
        return Payment.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to verify manual payment');
      }
    } catch (e) {
      throw Exception('Failed to verify manual payment: $e');
    }
  }

  // Admin - Get Payment Statistics
  static Future<PaymentStatistics> getPaymentStatistics({
    required String token,
  }) async {
    try {
      final response = await ApiService.getPaymentStatistics(
        token: token,
      );
      
      if (response['success'] == true) {
        return PaymentStatistics.fromJson(response['data']);
      } else {
        throw Exception(response['error'] ?? 'Failed to get payment statistics');
      }
    } catch (e) {
      throw Exception('Failed to get payment statistics: $e');
    }
  }

}