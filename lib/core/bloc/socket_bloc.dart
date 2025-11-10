import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/socket_service.dart';
import '../models/socket_event.dart';

// ============================================================================
// Events
// ============================================================================

abstract class SocketEvent extends Equatable {
  const SocketEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize and connect to WebSocket
class SocketConnect extends SocketEvent {
  const SocketConnect();
}

/// Disconnect from WebSocket
class SocketDisconnect extends SocketEvent {
  const SocketDisconnect();
}

/// Subscribe to vendor updates
class SocketSubscribeToVendor extends SocketEvent {
  final int vendorId;
  const SocketSubscribeToVendor(this.vendorId);
  
  @override
  List<Object?> get props => [vendorId];
}

/// Unsubscribe from vendor updates
class SocketUnsubscribeFromVendor extends SocketEvent {
  final int vendorId;
  const SocketUnsubscribeFromVendor(this.vendorId);
  
  @override
  List<Object?> get props => [vendorId];
}

/// Vendor approved event received
class SocketVendorApprovedReceived extends SocketEvent {
  final VendorApprovalEvent event;
  const SocketVendorApprovedReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Vendor rejected event received
class SocketVendorRejectedReceived extends SocketEvent {
  final VendorRejectionEvent event;
  const SocketVendorRejectedReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Vendor status changed event received
class SocketVendorStatusChangedReceived extends SocketEvent {
  final VendorStatusChangeEvent event;
  const SocketVendorStatusChangedReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Wallet funds added event received
class SocketWalletFundsAddedReceived extends SocketEvent {
  final WalletFundsAddedEvent event;
  const SocketWalletFundsAddedReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Wallet funds deducted event received
class SocketWalletFundsDeductedReceived extends SocketEvent {
  final WalletFundsDeductedEvent event;
  const SocketWalletFundsDeductedReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Cashout request event received
class SocketCashoutRequestReceived extends SocketEvent {
  final CashoutRequestEvent event;
  const SocketCashoutRequestReceived(this.event);
  
  @override
  List<Object?> get props => [event];
}

// ============================================================================
// States
// ============================================================================

abstract class SocketState extends Equatable {
  const SocketState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SocketInitial extends SocketState {
  const SocketInitial();
}

/// Connecting to WebSocket
class SocketConnecting extends SocketState {
  const SocketConnecting();
}

/// Connected to WebSocket
class SocketConnected extends SocketState {
  const SocketConnected();
}

/// Disconnected from WebSocket
class SocketDisconnected extends SocketState {
  final String? reason;
  const SocketDisconnected({this.reason});
  
  @override
  List<Object?> get props => [reason];
}

/// WebSocket error
class SocketError extends SocketState {
  final String message;
  const SocketError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Vendor approved via WebSocket
class SocketVendorApproved extends SocketState {
  final VendorApprovalEvent event;
  const SocketVendorApproved(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Vendor rejected via WebSocket
class SocketVendorRejected extends SocketState {
  final VendorRejectionEvent event;
  const SocketVendorRejected(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Vendor status changed via WebSocket
class SocketVendorStatusChanged extends SocketState {
  final VendorStatusChangeEvent event;
  const SocketVendorStatusChanged(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Wallet funds added via WebSocket
class SocketWalletFundsAdded extends SocketState {
  final WalletFundsAddedEvent event;
  const SocketWalletFundsAdded(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Wallet funds deducted via WebSocket
class SocketWalletFundsDeducted extends SocketState {
  final WalletFundsDeductedEvent event;
  const SocketWalletFundsDeducted(this.event);
  
  @override
  List<Object?> get props => [event];
}

/// Cashout request event via WebSocket
class SocketCashoutRequest extends SocketState {
  final CashoutRequestEvent event;
  const SocketCashoutRequest(this.event);
  
  @override
  List<Object?> get props => [event];
}

// ============================================================================
// BLoC
// ============================================================================

/// Global WebSocket BLoC for managing real-time connections
/// This BLoC should be provided at the app level and used across all features
class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketService _socketService = SocketService();
  
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<VendorApprovalEvent>? _approvalSubscription;
  StreamSubscription<VendorRejectionEvent>? _rejectionSubscription;
  StreamSubscription<VendorStatusChangeEvent>? _statusChangeSubscription;
  StreamSubscription<WalletFundsAddedEvent>? _walletFundsAddedSubscription;
  StreamSubscription<WalletFundsDeductedEvent>? _walletFundsDeductedSubscription;
  StreamSubscription<CashoutRequestEvent>? _cashoutRequestSubscription;
  StreamSubscription<String>? _errorSubscription;

  SocketBloc() : super(const SocketInitial()) {
    on<SocketConnect>(_onConnect);
    on<SocketDisconnect>(_onDisconnect);
    on<SocketSubscribeToVendor>(_onSubscribeToVendor);
    on<SocketUnsubscribeFromVendor>(_onUnsubscribeFromVendor);
    on<SocketVendorApprovedReceived>(_onVendorApprovedReceived);
    on<SocketVendorRejectedReceived>(_onVendorRejectedReceived);
    on<SocketVendorStatusChangedReceived>(_onVendorStatusChangedReceived);
    on<SocketWalletFundsAddedReceived>(_onWalletFundsAddedReceived);
    on<SocketWalletFundsDeductedReceived>(_onWalletFundsDeductedReceived);
    on<SocketCashoutRequestReceived>(_onCashoutRequestReceived);
  }

  /// Connect to WebSocket server
  Future<void> _onConnect(
    SocketConnect event,
    Emitter<SocketState> emit,
  ) async {
    try {
      emit(const SocketConnecting());
      
      // Connect to WebSocket
      await _socketService.connect();
      
      // Listen to connection state changes
      _connectionSubscription = _socketService.connectionStateStream.listen(
        (isConnected) {
          if (isConnected) {
            add(const SocketConnect()); // Trigger connected state
          } else {
            emit(const SocketDisconnected());
          }
        },
      );
      
      // Listen to vendor approval events
      _approvalSubscription = _socketService.vendorApprovalStream.listen(
        (approvalEvent) {
          add(SocketVendorApprovedReceived(approvalEvent));
        },
      );
      
      // Listen to vendor rejection events
      _rejectionSubscription = _socketService.vendorRejectionStream.listen(
        (rejectionEvent) {
          add(SocketVendorRejectedReceived(rejectionEvent));
        },
      );
      
      // Listen to vendor status change events
      _statusChangeSubscription = _socketService.vendorStatusChangeStream.listen(
        (statusChangeEvent) {
          add(SocketVendorStatusChangedReceived(statusChangeEvent));
        },
      );
      
      // Listen to wallet funds added events
      _walletFundsAddedSubscription = _socketService.walletFundsAddedStream.listen(
        (walletEvent) {
          add(SocketWalletFundsAddedReceived(walletEvent));
        },
      );
      
      // Listen to wallet funds deducted events
      _walletFundsDeductedSubscription = _socketService.walletFundsDeductedStream.listen(
        (walletEvent) {
          add(SocketWalletFundsDeductedReceived(walletEvent));
        },
      );
      
      // Listen to cashout request events
      _cashoutRequestSubscription = _socketService.cashoutRequestStream.listen(
        (cashoutEvent) {
          debugPrint('═══════════════════════════════════════════════════════════');
          debugPrint('🎯 SOCKET BLOC: Cashout event received from stream');
          debugPrint('═══════════════════════════════════════════════════════════');
          debugPrint('Event details:');
          debugPrint('   - Request ID: ${cashoutEvent.requestId}');
          debugPrint('   - Vendor ID: ${cashoutEvent.vendorId}');
          debugPrint('   - Amount: ${cashoutEvent.amount}');
          debugPrint('   - Status: ${cashoutEvent.status}');
          debugPrint('   - Reason: ${cashoutEvent.reason}');
          debugPrint('🔄 Dispatching SocketCashoutRequestReceived event to BLoC...');
          add(SocketCashoutRequestReceived(cashoutEvent));
          debugPrint('✅ Event dispatched to BLoC');
          debugPrint('═══════════════════════════════════════════════════════════');
        },
        onError: (error) {
          debugPrint('❌ ERROR in cashout request stream subscription: $error');
        },
      );
      
      // Listen to error events
      _errorSubscription = _socketService.errorStream.listen(
        (error) {
          emit(SocketError(error));
        },
      );
      
      emit(const SocketConnected());
    } catch (e) {
      emit(SocketError('Failed to connect: $e'));
    }
  }

  /// Disconnect from WebSocket server
  Future<void> _onDisconnect(
    SocketDisconnect event,
    Emitter<SocketState> emit,
  ) async {
    _socketService.disconnect();
    emit(const SocketDisconnected(reason: 'User disconnected'));
  }

  /// Subscribe to vendor updates
  void _onSubscribeToVendor(
    SocketSubscribeToVendor event,
    Emitter<SocketState> emit,
  ) {
    _socketService.subscribeToVendor(event.vendorId);
  }

  /// Unsubscribe from vendor updates
  void _onUnsubscribeFromVendor(
    SocketUnsubscribeFromVendor event,
    Emitter<SocketState> emit,
  ) {
    _socketService.unsubscribeFromVendor(event.vendorId);
  }

  /// Handle vendor approved event
  void _onVendorApprovedReceived(
    SocketVendorApprovedReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(SocketVendorApproved(event.event));
  }

  /// Handle vendor rejected event
  void _onVendorRejectedReceived(
    SocketVendorRejectedReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(SocketVendorRejected(event.event));
  }

  /// Handle vendor status changed event
  void _onVendorStatusChangedReceived(
    SocketVendorStatusChangedReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(SocketVendorStatusChanged(event.event));
  }

  /// Handle wallet funds added event
  void _onWalletFundsAddedReceived(
    SocketWalletFundsAddedReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(SocketWalletFundsAdded(event.event));
  }

  /// Handle wallet funds deducted event
  void _onWalletFundsDeductedReceived(
    SocketWalletFundsDeductedReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(SocketWalletFundsDeducted(event.event));
  }

  /// Handle cashout request event
  void _onCashoutRequestReceived(
    SocketCashoutRequestReceived event,
    Emitter<SocketState> emit,
  ) {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🎯 SOCKET BLOC HANDLER: Processing cashout request event');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('Current state: ${state.runtimeType}');
    debugPrint('Event details:');
    debugPrint('   - Request ID: ${event.event.requestId}');
    debugPrint('   - Vendor ID: ${event.event.vendorId}');
    debugPrint('   - Amount: ${event.event.amount}');
    debugPrint('   - Status: ${event.event.status}');
    debugPrint('   - Reason: ${event.event.reason}');
    debugPrint('   - Timestamp: ${event.event.timestamp}');
    debugPrint('🔄 Emitting SocketCashoutRequest state...');
    emit(SocketCashoutRequest(event.event));
    debugPrint('✅ State emitted successfully');
    debugPrint('New state: ${state.runtimeType}');
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  @override
  Future<void> close() {
    // Cancel all subscriptions
    _connectionSubscription?.cancel();
    _approvalSubscription?.cancel();
    _rejectionSubscription?.cancel();
    _statusChangeSubscription?.cancel();
    _walletFundsAddedSubscription?.cancel();
    _walletFundsDeductedSubscription?.cancel();
    _cashoutRequestSubscription?.cancel();
    _errorSubscription?.cancel();
    
    // Disconnect WebSocket
    _socketService.disconnect();
    
    return super.close();
  }
}
