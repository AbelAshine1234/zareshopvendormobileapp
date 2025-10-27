import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/payment_model.dart' as models;
import 'payment_event.dart';
import 'payment_state.dart';
import '../../../core/services/api_service.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentInitial()) {
    // Create Payment Events
    on<CreatePayment>(_onCreatePayment);
    on<CreateMobilePayment>(_onCreateMobilePayment);
    
    // Get Payment Events
    on<GetPaymentById>(_onGetPaymentById);
    on<GetMyPayments>(_onGetMyPayments);
    on<RefreshPayments>(_onRefreshPayments);
    
    // Update Payment Events
    on<UpdatePaymentStatus>(_onUpdatePaymentStatus);
    on<ProcessIntegratedPayment>(_onProcessIntegratedPayment);
    
    // Payment Proof Events
    on<UploadPaymentProof>(_onUploadPaymentProof);
    on<UploadPaymentProofFile>(_onUploadPaymentProofFile);
    
    // Payment Flow Events
    on<ProceedToNextStep>(_onProceedToNextStep);
    on<GenerateQRCode>(_onGenerateQRCode);
    
    // Admin Events
    on<GetAdminPayments>(_onGetAdminPayments);
    on<GetPendingPayments>(_onGetPendingPayments);
    on<VerifyManualPayment>(_onVerifyManualPayment);
    on<GetPaymentStatistics>(_onGetPaymentStatistics);
    
    // Clear Events
    on<ClearPaymentError>(_onClearPaymentError);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  // Create Payment
  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      // Get user token from storage or auth service
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      // Get user ID from storage or auth service
      final userId = await _getUserId();
      if (userId == null) {
        emit(const PaymentError(message: 'User ID not found'));
        return;
      }

      final response = await ApiService.createPayment(
        token: token,
        amount: event.amount,
        paymentMethod: event.paymentMethod.name,
        paymentProvider: event.paymentProvider.name,
        currency: event.currency,
      );

      // Check if response has success field (error case) or is direct data (success case)
      if (response.containsKey('success') && response['success'] == false) {
        emit(PaymentError(message: response['error'] ?? 'Failed to create payment'));
      } else {
        // Handle successful response - API returns data directly
        try {
          emit(PaymentCreated(
            payment: models.Payment.fromJson(response),
            paymentInstructions: response['paymentInstructions'] != null 
                ? models.PaymentInstructions.fromJson(response['paymentInstructions'])
                : null,
          ));
        } catch (e) {
          emit(PaymentError(message: 'Failed to parse payment data: ${e.toString()}'));
        }
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to create payment: $e'));
    }
  }

  // Create Mobile Payment
  Future<void> _onCreateMobilePayment(
    CreateMobilePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.createMobilePayment(
        token: token,
        amount: event.amount,
        paymentMethod: event.paymentMethod.name,
        paymentProvider: event.paymentProvider.name,
        currency: event.currency,
      );

      if (response['success'] == true) {
        emit(PaymentCreated(
          payment: models.Payment.fromJson(response['data']),
          paymentInstructions: response['paymentInstructions'] != null 
              ? models.PaymentInstructions.fromJson(response['paymentInstructions'])
              : null,
        ));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to create mobile payment'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to create mobile payment: ${e.toString()}'));
    }
  }

  // Get Payment by ID
  Future<void> _onGetPaymentById(
    GetPaymentById event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.getPaymentById(
        token: token,
        paymentId: event.paymentId,
      );

      if (response['success'] == true) {
        emit(PaymentLoaded(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to get payment'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to get payment: ${e.toString()}'));
    }
  }

  // Get My Payments
  Future<void> _onGetMyPayments(
    GetMyPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentListLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentListError('User not authenticated'));
        return;
      }

      final response = await ApiService.getMyPayments(
        token: token,
        page: event.page,
        limit: event.limit,
        status: event.status?.name,
        paymentMethod: event.paymentMethod?.name,
      );

      // Check if response has success field (error case) or is direct data (success case)
      if (response.containsKey('success') && response['success'] == false) {
        emit(PaymentListError(response['error'] ?? 'Failed to get payments'));
      } else {
        // Handle successful response - API returns data in 'data' field
        try {
          print('🔍 [PAYMENT_BLOC] Parsing payments data...');
          print('🔍 [PAYMENT_BLOC] Data type: ${response['data'].runtimeType}');
          print('🔍 [PAYMENT_BLOC] Data length: ${(response['data'] as List).length}');
          
          final paymentsList = response['data'] as List;
          final payments = <models.Payment>[];
          
          for (var i = 0; i < paymentsList.length; i++) {
            try {
              print('🔍 [PAYMENT_BLOC] Parsing payment $i: ${paymentsList[i]}');
              final payment = models.Payment.fromJson(paymentsList[i]);
              payments.add(payment);
              print('✅ [PAYMENT_BLOC] Successfully parsed payment $i');
            } catch (e) {
              print('❌ [PAYMENT_BLOC] Error parsing payment $i: $e');
              print('❌ [PAYMENT_BLOC] Payment data: ${paymentsList[i]}');
              rethrow;
            }
          }
          
          final pagination = models.Pagination.fromJson(response['pagination']);
          
          emit(PaymentListLoaded(
            payments: payments,
            pagination: pagination,
          ));
        } catch (e, stackTrace) {
          print('❌ [PAYMENT_BLOC] Error parsing payments data: $e');
          print('❌ [PAYMENT_BLOC] Stack trace: $stackTrace');
          emit(PaymentListError('Failed to parse payments data: ${e.toString()}'));
        }
      }
    } catch (e) {
      emit(PaymentListError('Failed to get payments: ${e.toString()}'));
    }
  }

  // Refresh Payments
  Future<void> _onRefreshPayments(
    RefreshPayments event,
    Emitter<PaymentState> emit,
  ) async {
    add(const GetMyPayments());
  }

  // Update Payment Status
  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatus event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.updatePaymentStatus(
        token: token,
        paymentId: event.paymentId,
        status: event.status.name,
        externalPaymentId: event.externalPaymentId,
        paymentReference: event.paymentReference,
      );

      if (response['success'] == true) {
        emit(PaymentStatusUpdated(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to update payment status'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to update payment status: ${e.toString()}'));
    }
  }

  // Process Integrated Payment
  Future<void> _onProcessIntegratedPayment(
    ProcessIntegratedPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.processIntegratedPayment(
        token: token,
        paymentId: event.paymentId,
        externalPaymentId: event.externalPaymentId,
        paymentReference: event.paymentReference,
      );

      if (response['success'] == true) {
        emit(PaymentProcessed(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to process integrated payment'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to process payment: ${e.toString()}'));
    }
  }

  // Upload Payment Proof
  Future<void> _onUploadPaymentProof(
    UploadPaymentProof event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.uploadPaymentProof(
        token: token,
        paymentId: event.paymentId,
        imageId: event.imageId,
      );

      if (response['success'] == true) {
        emit(PaymentProofUploaded(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to upload payment proof'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to upload payment proof: ${e.toString()}'));
    }
  }

  // Upload Payment Proof File
  Future<void> _onUploadPaymentProofFile(
    UploadPaymentProofFile event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.uploadPaymentProofFile(
        token: token,
        paymentId: event.paymentId,
        filePath: event.filePath,
      );

      if (response['success'] == true) {
        emit(PaymentProofUploaded(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to upload payment proof file'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to upload payment proof file: ${e.toString()}'));
    }
  }

  // Proceed to Next Step
  Future<void> _onProceedToNextStep(
    ProceedToNextStep event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.proceedToNextStep(
        token: token,
        paymentId: event.paymentId,
        forceProceed: event.forceProceed,
      );

      if (response['success'] == true) {
        final nextStepData = models.NextStep.fromJson(response['data']['next_step']);
        emit(PaymentProceeded(
          payment: models.Payment.fromJson(response['data']['payment']),
          nextStep: NextStep(
            step: nextStepData.action,
            canProceed: nextStepData.completed,
            message: nextStepData.description,
            actions: [
              NextStepAction(
                action: nextStepData.action,
                label: nextStepData.description,
                description: nextStepData.description,
                primary: true,
                warning: false,
              ),
            ],
          ),
        ));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to proceed to next step'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to proceed to next step: ${e.toString()}'));
    }
  }

  // Generate QR Code
  Future<void> _onGenerateQRCode(
    GenerateQRCode event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.generateQRCode(
        token: token,
        paymentId: event.paymentId,
      );

      if (response['success'] == true) {
        final qrData = models.PaymentQRData.fromJson(response['data']);
        emit(QRCodeGenerated(
          qrData: qrData.qrCode,
          qrCode: qrData.qrCode,
        ));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to generate QR code'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to generate QR code: ${e.toString()}'));
    }
  }

  // Admin - Get Admin Payments
  Future<void> _onGetAdminPayments(
    GetAdminPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentListLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentListError('User not authenticated'));
        return;
      }

      final response = await ApiService.getAllPayments(
        token: token,
        status: event.status?.name,
        paymentMethod: event.paymentMethod?.name,
        paymentProvider: event.paymentProvider?.name,
        startDate: event.startDate?.toIso8601String(),
        endDate: event.endDate?.toIso8601String(),
        page: event.page,
        limit: event.limit,
      );

      if (response['success'] == true) {
        final payments = (response['data']['payments'] as List)
            .map((json) => models.Payment.fromJson(json))
            .toList();
        final pagination = models.Pagination.fromJson(response['data']['pagination']);
        
        emit(PaymentListLoaded(
          payments: payments,
          pagination: pagination,
        ));
      } else {
        emit(PaymentListError(response['error'] ?? 'Failed to get admin payments'));
      }
    } catch (e) {
      emit(PaymentListError('Failed to get admin payments: ${e.toString()}'));
    }
  }

  // Admin - Get Pending Payments
  Future<void> _onGetPendingPayments(
    GetPendingPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentListLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentListError('User not authenticated'));
        return;
      }

      final response = await ApiService.getPendingPayments(token: token);

      if (response['success'] == true) {
        final payments = (response['data']['payments'] as List)
            .map((json) => models.Payment.fromJson(json))
            .toList();
        final pagination = models.Pagination.fromJson(response['data']['pagination']);
        
        emit(PaymentListLoaded(
          payments: payments,
          pagination: pagination,
        ));
      } else {
        emit(PaymentListError(response['error'] ?? 'Failed to get pending payments'));
      }
    } catch (e) {
      emit(PaymentListError('Failed to get pending payments: ${e.toString()}'));
    }
  }

  // Admin - Verify Manual Payment
  Future<void> _onVerifyManualPayment(
    VerifyManualPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentError(message: 'User not authenticated'));
        return;
      }

      final response = await ApiService.verifyManualPayment(
        token: token,
        paymentId: event.paymentId,
        approved: event.approved,
        adminNotes: event.adminNotes,
      );

      if (response['success'] == true) {
        emit(PaymentVerified(models.Payment.fromJson(response['data'])));
      } else {
        emit(PaymentError(message: response['error'] ?? 'Failed to verify manual payment'));
      }
    } catch (e) {
      emit(PaymentError(message: 'Failed to verify payment: ${e.toString()}'));
    }
  }

  // Admin - Get Payment Statistics
  Future<void> _onGetPaymentStatistics(
    GetPaymentStatistics event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentStatisticsLoading());
    
    try {
      final token = await _getUserToken();
      if (token == null) {
        emit(const PaymentStatisticsError('User not authenticated'));
        return;
      }

      final response = await ApiService.getPaymentStatistics(token: token);

      if (response['success'] == true) {
        final statistics = models.PaymentStatistics.fromJson(response['data']);
        emit(PaymentStatisticsLoaded(statistics));
      } else {
        emit(PaymentStatisticsError(response['error'] ?? 'Failed to get payment statistics'));
      }
    } catch (e) {
      emit(PaymentStatisticsError('Failed to get payment statistics: ${e.toString()}'));
    }
  }


  // Clear Payment Error
  void _onClearPaymentError(
    ClearPaymentError event,
    Emitter<PaymentState> emit,
  ) {
    emit(const PaymentInitial());
  }

  // Reset Payment State
  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<PaymentState> emit,
  ) {
    emit(const PaymentInitial());
  }

  // Helper methods
  Future<String?> _getUserToken() async {
    try {
      // Get token from ApiService
      return await ApiService.getToken();
    } catch (e) {
      // Log error for debugging
      return null;
    }
  }

  Future<int?> _getUserId() async {
    try {
      // Get user data from ApiService
      final userData = await ApiService.getUserData();
      if (userData != null && userData['id'] != null) {
        return userData['id'] as int;
      }
      return null;
    } catch (e) {
      // Log error for debugging
      return null;
    }
  }
}
