import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/socket_event.dart';
import 'storage_service.dart';

/// Singleton service for managing WebSocket connections
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Socket.IO client instance
  IO.Socket? _socket;
  
  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;
  
  // Event stream controllers
  final _connectionStateController = StreamController<bool>.broadcast();
  final _vendorApprovalController = StreamController<VendorApprovalEvent>.broadcast();
  final _vendorRejectionController = StreamController<VendorRejectionEvent>.broadcast();
  final _vendorStatusChangeController = StreamController<VendorStatusChangeEvent>.broadcast();
  final _vendorUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _walletFundsAddedController = StreamController<WalletFundsAddedEvent>.broadcast();
  final _walletFundsDeductedController = StreamController<WalletFundsDeductedEvent>.broadcast();
  final _cashoutRequestController = StreamController<CashoutRequestEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<bool> get connectionStateStream => _connectionStateController.stream;
  Stream<VendorApprovalEvent> get vendorApprovalStream => _vendorApprovalController.stream;
  Stream<VendorRejectionEvent> get vendorRejectionStream => _vendorRejectionController.stream;
  Stream<VendorStatusChangeEvent> get vendorStatusChangeStream => _vendorStatusChangeController.stream;
  Stream<Map<String, dynamic>> get vendorUpdateStream => _vendorUpdateController.stream;
  Stream<WalletFundsAddedEvent> get walletFundsAddedStream => _walletFundsAddedController.stream;
  Stream<WalletFundsDeductedEvent> get walletFundsDeductedStream => _walletFundsDeductedController.stream;
  Stream<CashoutRequestEvent> get cashoutRequestStream => _cashoutRequestController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Connection state getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // Backend WebSocket URL
  // Note: For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, localhost works fine
  // For real device on same network, use your computer's IP address
  static const String _socketUrl = 'http://localhost:4000';

  /// Initialize and connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      debugPrint('🔌 Socket already connected or connecting');
      return;
    }

    try {
      _isConnecting = true;
      debugPrint('🔌 Connecting to WebSocket server at $_socketUrl');

      // Get JWT token from StorageService
      final storageService = StorageService();
      final token = await storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Configure Socket.IO client
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport
            .enableAutoConnect() // Auto-connect on initialization
            .enableReconnection() // Enable auto-reconnection
            .setReconnectionAttempts(5) // Max reconnection attempts
            .setReconnectionDelay(1000) // Initial reconnection delay (1s)
            .setReconnectionDelayMax(5000) // Max reconnection delay (5s)
            .setAuth({
              'token': token, // JWT token for authentication
            })
            .build(),
      );

      // Set up event listeners
      _setupEventListeners();

      // Connect to server
      _socket!.connect();

    } catch (e) {
      _isConnecting = false;
      debugPrint('❌ Socket connection error: $e');
      _errorController.add('Failed to connect: $e');
      rethrow;
    }
  }

  /// Set up all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionStateController.add(true);
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ SOCKET CONNECTED SUCCESSFULLY');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Socket ID: ${_socket!.id}');
      debugPrint('Connection state: CONNECTED');
      debugPrint('Stream controllers status:');
      debugPrint('   - Connection: ${_connectionStateController.hasListener} listeners');
      debugPrint('   - Vendor approval: ${_vendorApprovalController.hasListener} listeners');
      debugPrint('   - Vendor rejection: ${_vendorRejectionController.hasListener} listeners');
      debugPrint('   - Vendor status: ${_vendorStatusChangeController.hasListener} listeners');
      debugPrint('   - Wallet added: ${_walletFundsAddedController.hasListener} listeners');
      debugPrint('   - Wallet deducted: ${_walletFundsDeductedController.hasListener} listeners');
      debugPrint('   - Cashout: ${_cashoutRequestController.hasListener} listeners');
      debugPrint('═══════════════════════════════════════════════════════════');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionStateController.add(false);
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔌 SOCKET DISCONNECTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Connection state: DISCONNECTED');
      debugPrint('═══════════════════════════════════════════════════════════');
    });

    _socket!.onConnectError((error) {
      _isConnecting = false;
      debugPrint('❌ Socket connection error: $error');
      _errorController.add('Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('❌ Socket error: $error');
      _errorController.add('Socket error: $error');
    });

    // Connection success event
    _socket!.on(VendorSocketEvents.connectionSuccess, (data) {
      debugPrint('✅ Connection success: $data');
    });

    // Vendor approval event
    _socket!.on(VendorSocketEvents.vendorApproved, (data) {
      debugPrint('🎉 Vendor approved: $data');
      try {
        final event = VendorApprovalEvent.fromJson(data as Map<String, dynamic>);
        _vendorApprovalController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing vendor approval event: $e');
      }
    });

    // Vendor rejection event
    _socket!.on(VendorSocketEvents.vendorRejected, (data) {
      debugPrint('❌ Vendor rejected: $data');
      try {
        final event = VendorRejectionEvent.fromJson(data as Map<String, dynamic>);
        _vendorRejectionController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing vendor rejection event: $e');
      }
    });

    // Vendor status change event
    _socket!.on(VendorSocketEvents.vendorStatusChanged, (data) {
      debugPrint('🔄 Vendor status changed: $data');
      try {
        final event = VendorStatusChangeEvent.fromJson(data as Map<String, dynamic>);
        _vendorStatusChangeController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing vendor status change event: $e');
      }
    });

    // Vendor updated event
    _socket!.on(VendorSocketEvents.vendorUpdated, (data) {
      debugPrint('🔄 Vendor updated: $data');
      try {
        _vendorUpdateController.add(data as Map<String, dynamic>);
      } catch (e) {
        debugPrint('❌ Error parsing vendor update event: $e');
      }
    });

    // Wallet funds added event
    _socket!.on(VendorSocketEvents.walletFundsAdded, (data) {
      debugPrint('💰 Wallet funds added: $data');
      try {
        final event = WalletFundsAddedEvent.fromJson(data as Map<String, dynamic>);
        _walletFundsAddedController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing wallet funds added event: $e');
      }
    });

    // Wallet funds deducted event
    _socket!.on(VendorSocketEvents.walletFundsDeducted, (data) {
      debugPrint('💸 Wallet funds deducted: $data');
      try {
        final event = WalletFundsDeductedEvent.fromJson(data as Map<String, dynamic>);
        _walletFundsDeductedController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing wallet funds deducted event: $e');
      }
    });

    // Cashout request created event
    _socket!.on(VendorSocketEvents.cashoutRequestCreated, (data) {
      debugPrint('💰 [CASHOUT CREATED] Received: $data');
      try {
        final event = CashoutRequestEvent.fromJson(data as Map<String, dynamic>);
        debugPrint('✅ [CASHOUT CREATED] Parsed successfully - ID: ${event.requestId}, Status: ${event.status}');
        _cashoutRequestController.add(event);
        debugPrint('✅ [CASHOUT CREATED] Added to stream');
      } catch (e, stackTrace) {
        debugPrint('❌ [CASHOUT CREATED] Parse error: $e');
        debugPrint('   Stack: $stackTrace');
      }
    });

    // Cashout request approved event
    _socket!.on(VendorSocketEvents.cashoutRequestApproved, (data) {
      debugPrint('✅ [CASHOUT APPROVED] Received: $data');
      try {
        // Parse data manually to avoid issues with extra fields
        final jsonData = data as Map<String, dynamic>;
        debugPrint('   Fields: ${jsonData.keys.toList()}');
        
        final event = CashoutRequestEvent.fromJson(jsonData);
        debugPrint('✅ [CASHOUT APPROVED] Parsed - ID: ${event.requestId}, Status: ${event.status}');
        _cashoutRequestController.add(event);
        debugPrint('✅ [CASHOUT APPROVED] Added to stream');
      } catch (e, stackTrace) {
        debugPrint('❌ [CASHOUT APPROVED] Parse error: $e');
        debugPrint('   Stack: $stackTrace');
        debugPrint('   Raw data: $data');
      }
    });

    // Cashout request rejected event
    _socket!.on(VendorSocketEvents.cashoutRequestRejected, (data) {
      try {
        final event = CashoutRequestEvent.fromJson(data as Map<String, dynamic>);
        _cashoutRequestController.add(event);
      } catch (e) {
        // Silently handle parsing errors
      }
    });

    // Cashout request status changed event
    _socket!.on(VendorSocketEvents.cashoutRequestStatusChanged, (data) {
      try {
        final event = CashoutRequestEvent.fromJson(data as Map<String, dynamic>);
        _cashoutRequestController.add(event);
      } catch (e) {
        // Silently handle parsing errors
      }
    });

    // Reconnection events
    _socket!.onReconnect((_) {
      debugPrint('🔄 Socket reconnected');
      _isConnected = true;
      _connectionStateController.add(true);
    });

    _socket!.onReconnectAttempt((attempt) {
      debugPrint('🔄 Socket reconnection attempt: $attempt');
    });

    _socket!.onReconnectError((error) {
      debugPrint('❌ Socket reconnection error: $error');
    });

    _socket!.onReconnectFailed((_) {
      debugPrint('❌ Socket reconnection failed');
      _errorController.add('Reconnection failed after multiple attempts');
    });
  }

  /// Subscribe to vendor updates
  void subscribeToVendor(int vendorId) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Cannot subscribe: Socket not connected');
      return;
    }

    debugPrint('📡 Subscribing to vendor updates: $vendorId');
    _socket!.emit(VendorSocketEvents.vendorSubscribe, {
      'vendor_id': vendorId,
    });
  }

  /// Unsubscribe from vendor updates
  void unsubscribeFromVendor(int vendorId) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Cannot unsubscribe: Socket not connected');
      return;
    }

    debugPrint('📡 Unsubscribing from vendor updates: $vendorId');
    _socket!.emit(VendorSocketEvents.vendorUnsubscribe, {
      'vendor_id': vendorId,
    });
  }

  /// Request current vendor status
  void requestVendorStatus(int vendorId) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Cannot request status: Socket not connected');
      return;
    }

    debugPrint('📡 Requesting vendor status: $vendorId');
    _socket!.emit(VendorSocketEvents.vendorStatusRequest, {
      'vendor_id': vendorId,
    });
  }

  /// Send ping to server
  void ping() {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Cannot ping: Socket not connected');
      return;
    }

    _socket!.emit(VendorSocketEvents.vendorPing);
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting from WebSocket server');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      _connectionStateController.add(false);
    }
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _vendorApprovalController.close();
    _vendorRejectionController.close();
    _vendorStatusChangeController.close();
    _vendorUpdateController.close();
    _walletFundsAddedController.close();
    _walletFundsDeductedController.close();
    _cashoutRequestController.close();
    _errorController.close();
  }
}
