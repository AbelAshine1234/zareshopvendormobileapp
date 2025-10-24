import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../models/wallet_transaction.dart';
import '../models/payment_method.dart';
import '../models/cashout_request.dart';
import '../../../core/services/api_service.dart';
import '../../../core/bloc/socket_bloc.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final SocketBloc? socketBloc;
  StreamSubscription? _socketSubscription;

  WalletBloc({this.socketBloc}) : super(WalletInitial()) {
    // Wallet Balance Events
    on<FetchWalletBalance>(_onFetchWalletBalance);
    on<RefreshWalletBalance>(_onRefreshWalletBalance);
    on<AddFundsToWallet>(_onAddFundsToWallet);
    
    // Payment Method Events
    on<FetchPaymentMethods>(_onFetchPaymentMethods);
    on<CreatePaymentMethod>(_onCreatePaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    
    // Cashout Request Events
    on<CreateCashoutRequest>(_onCreateCashoutRequest);
    on<FetchCashoutRequests>(_onFetchCashoutRequests);
    on<FetchCashoutRequestDetails>(_onFetchCashoutRequestDetails);
    
    // Transaction Events
    on<FetchTransactionHistory>(_onFetchTransactionHistory);
    on<ExportTransactions>(_onExportTransactions);
    
    // WebSocket Events
    on<OnWalletFundsAdded>(_onWalletFundsAdded);
    on<OnWalletFundsDeducted>(_onWalletFundsDeducted);
    on<OnCashoutRequestStatusChanged>(_onCashoutRequestStatusChanged);

    // Listen to WebSocket events
    _listenToSocketEvents();
  }

  void _listenToSocketEvents() {
    if (socketBloc != null) {
      print('✅ [WalletBloc._listenToSocketEvents] Socket listener initialized - SocketBloc is available');
      _socketSubscription = socketBloc!.stream.listen((socketState) {
        print('');
        print('╔═══════════════════════════════════════════════════════════╗');
        print('║  🔔 [WalletBloc] SOCKET EVENT RECEIVED                    ║');
        print('╚═══════════════════════════════════════════════════════════╝');
        print('   State Type: ${socketState.runtimeType}');
        print('   Timestamp: ${DateTime.now()}');
        
        if (socketState is SocketWalletFundsAdded) {
          print('   Event: 💰 WALLET FUNDS ADDED');
          print('   Amount: ${socketState.event.amount}');
          print('   New Balance: ${socketState.event.newBalance}');
          print('   → Dispatching OnWalletFundsAdded event...');
          add(OnWalletFundsAdded(
            walletId: socketState.event.walletId,
            vendorId: socketState.event.vendorId,
            amount: socketState.event.amount,
            newBalance: socketState.event.newBalance,
            reason: socketState.event.reason,
          ));
          print('   ✅ Event dispatched');
        } else if (socketState is SocketWalletFundsDeducted) {
          print('   Event: 💸 WALLET FUNDS DEDUCTED');
          print('   Amount: ${socketState.event.amount}');
          print('   New Balance: ${socketState.event.newBalance}');
          print('   → Dispatching OnWalletFundsDeducted event...');
          add(OnWalletFundsDeducted(
            walletId: socketState.event.walletId,
            vendorId: socketState.event.vendorId,
            amount: socketState.event.amount,
            newBalance: socketState.event.newBalance,
            reason: socketState.event.reason,
          ));
          print('   ✅ Event dispatched');
        } else if (socketState is SocketCashoutRequest) {
          print('   Event: 💳 CASHOUT REQUEST');
          print('   Request ID: ${socketState.event.requestId}');
          print('   Status: ${socketState.event.status}');
          print('   Amount: ${socketState.event.amount}');
          print('   Vendor ID: ${socketState.event.vendorId}');
          
          // Refresh wallet to show new/updated cashout request
          print('   → Step 1: Dispatching RefreshWalletBalance...');
          add(const RefreshWalletBalance());
          print('   ✅ RefreshWalletBalance dispatched');
          
          // Also dispatch status changed event for any listeners
          print('   → Step 2: Dispatching OnCashoutRequestStatusChanged...');
          add(OnCashoutRequestStatusChanged(
            requestId: socketState.event.requestId,
            vendorId: socketState.event.vendorId,
            status: socketState.event.status,
            reason: socketState.event.reason,
          ));
          print('   ✅ OnCashoutRequestStatusChanged dispatched');
        } else {
          print('   ⚠️ Unknown socket state: ${socketState.runtimeType}');
        }
        print('╚═══════════════════════════════════════════════════════════╝');
        print('');
      });
    } else {
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║  ⚠️ [WalletBloc] SOCKET NOT AVAILABLE                     ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('   SocketBloc is null - WebSocket events will NOT be received!');
      print('   Real-time updates are DISABLED');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('');
    }
  }

  // ============================================
  // WALLET BALANCE HANDLERS
  // ============================================

  Future<void> _onFetchWalletBalance(
    FetchWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Loading wallet...'));
    await _fetchBalance(emit);
  }

  Future<void> _onRefreshWalletBalance(
    RefreshWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    // Don't show loading state on refresh
    await _fetchBalance(emit);
  }

  Future<void> _fetchBalance(
    Emitter<WalletState> emit,
  ) async {
    try {
      print('📊 [WalletBloc._fetchBalance] Starting to fetch wallet data...');
      
      // Get vendor ID from user data (user.vendor.id) via API call
      final userResult = await ApiService.getCurrentUser();
      String vendorId = '1'; // Fallback
      
      if (userResult['success'] == true && userResult['data'] != null) {
        final user = userResult['data'];
        if (user['vendor'] != null && user['vendor']['id'] != null) {
          vendorId = user['vendor']['id'].toString();
          print('✅ [WalletBloc._fetchBalance] Got vendor ID: $vendorId');
        }
      }

      // Fetch wallet data and cashout requests in parallel
      print('🔄 [WalletBloc._fetchBalance] Fetching wallet + cashout requests for vendor: $vendorId');
      final results = await Future.wait([
        ApiService.getWalletData(vendorId: vendorId),
        ApiService.getCashoutRequests(vendorId: vendorId, limit: 100),
      ]);

      final walletResult = results[0];
      final cashoutResult = results[1];

      print('📦 [WalletBloc._fetchBalance] Wallet result success: ${walletResult['success']}');
      print('📦 [WalletBloc._fetchBalance] Cashout result success: ${cashoutResult['success']}');

      if (walletResult['success'] == true) {
        final walletData = WalletData.fromJson(walletResult['data']);
        print('💰 [WalletBloc._fetchBalance] Wallet balance: ${walletData.balance}');
        print('📝 [WalletBloc._fetchBalance] Transactions count: ${walletData.transactions.length}');
        
        // Parse cashout requests if available
        List<CashoutRequest> cashoutRequests = [];
        if (cashoutResult['success'] == true) {
          final cashoutData = cashoutResult['data'];
          if (cashoutData['cashOutRequests'] != null) {
            cashoutRequests = (cashoutData['cashOutRequests'] as List<dynamic>)
                .map((r) => CashoutRequest.fromJson(r as Map<String, dynamic>))
                .toList();
            print('💳 [WalletBloc._fetchBalance] Cashout requests count: ${cashoutRequests.length}');
            for (var req in cashoutRequests) {
              print('   - ID: ${req.id}, Amount: ${req.amount}, Status: ${req.status}');
            }
          }
        }
        
        print('✅ [WalletBloc._fetchBalance] Emitting WalletBalanceLoadedWithCashouts');
        emit(WalletBalanceLoadedWithCashouts(
          walletData: walletData,
          cashoutRequests: cashoutRequests,
        ));
      } else {
        final errorMessage = walletResult['error'] ?? 'Failed to load wallet data';
        print('❌ [WalletBloc._fetchBalance] Error: $errorMessage');
        emit(WalletError(errorMessage));
      }
    } catch (e, stackTrace) {
      print('❌ [WalletBloc._fetchBalance] Exception: $e');
      print('   Stack: $stackTrace');
      emit(WalletError('Failed to load wallet data: ${e.toString()}'));
    }
  }

  Future<void> _onAddFundsToWallet(
    AddFundsToWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Adding funds...'));
    
    try {
      // Get vendor ID from event or user data
      String vendorId = event.vendorId ?? '1';
      
      if (event.vendorId == null) {
        // Get vendor ID from user data (user.vendor.id) via API call
        final userResult = await ApiService.getCurrentUser();
        
        if (userResult['success'] == true && userResult['data'] != null) {
          final user = userResult['data'];
          if (user['vendor'] != null && user['vendor']['id'] != null) {
            vendorId = user['vendor']['id'].toString();
          }
        }
      }
      
      final result = await ApiService.addFundsToWallet(
        vendorId: vendorId,
        amount: event.amount,
        reason: event.reason,
      );

      if (result['success'] == true) {
        final data = result['data'];
        
        // Parse new balance from response
        double newBalance = 0.0;
        try {
          if (data['wallet'] != null && data['wallet']['balance'] != null) {
            final balanceValue = data['wallet']['balance'];
            newBalance = (balanceValue is int) ? balanceValue.toDouble() : (balanceValue as num).toDouble();
          } else if (data['newBalance'] != null) {
            final balanceValue = data['newBalance'];
            newBalance = (balanceValue is int) ? balanceValue.toDouble() : (balanceValue as num).toDouble();
          } else if (data['new_balance'] != null) {
            final balanceValue = data['new_balance'];
            newBalance = (balanceValue is int) ? balanceValue.toDouble() : (balanceValue as num).toDouble();
          } else {
            newBalance = event.amount;
          }
        } catch (e) {
          newBalance = event.amount;
        }
        
        emit(FundsAddedSuccess(
          amount: event.amount,
          newBalance: newBalance,
          message: data['message'] ?? 'Funds added successfully',
        ));
        
        // Refresh wallet balance (no vendorId needed, will be fetched in bloc)
        add(const RefreshWalletBalance());
      } else {
        emit(WalletError(result['error'] ?? 'Failed to add funds'));
      }
    } catch (e) {
      emit(WalletError('Failed to add funds: ${e.toString()}'));
    }
  }

  // ============================================
  // PAYMENT METHOD HANDLERS
  // ============================================

  Future<void> _onFetchPaymentMethods(
    FetchPaymentMethods event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Loading payment methods...'));
    
    try {
      final result = await ApiService.getPaymentMethods(vendorId: event.vendorId);

      if (result['success'] == true) {
        final data = result['data'];
        final paymentMethods = (data['paymentMethods'] as List<dynamic>)
            .map((p) => PaymentMethod.fromJson(p as Map<String, dynamic>))
            .toList();
        
        emit(PaymentMethodsLoaded(
          paymentMethods: paymentMethods,
          count: data['count'] ?? paymentMethods.length,
        ));
      } else {
        emit(PaymentMethodError(result['error'] ?? 'Failed to load payment methods'));
      }
    } catch (e) {
      emit(PaymentMethodError('Failed to load payment methods: ${e.toString()}'));
    }
  }

  Future<void> _onCreatePaymentMethod(
    CreatePaymentMethod event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Creating payment method...'));
    
    try {
      final result = await ApiService.createPaymentMethod(
        vendorId: event.vendorId,
        name: event.name,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
        type: event.type,
        details: event.details,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final paymentMethod = PaymentMethod.fromJson(data['paymentMethod']);
        
        emit(PaymentMethodCreated(
          paymentMethod: paymentMethod,
          message: data['message'] ?? 'Payment method created successfully',
        ));
        
        // Refresh full wallet balance (includes payment methods, transactions, etc.)
        add(const RefreshWalletBalance());
      } else {
        emit(PaymentMethodError(result['error'] ?? 'Failed to create payment method'));
      }
    } catch (e) {
      emit(PaymentMethodError('Failed to create payment method: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Updating payment method...'));
    
    try {
      final result = await ApiService.updatePaymentMethod(
        paymentMethodId: event.paymentMethodId,
        name: event.name,
        accountNumber: event.accountNumber,
        accountHolder: event.accountHolder,
        type: event.type,
        details: event.details,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final paymentMethod = PaymentMethod.fromJson(data['paymentMethod']);
        
        emit(PaymentMethodUpdated(
          paymentMethod: paymentMethod,
          message: data['message'] ?? 'Payment method updated successfully',
        ));
      } else {
        emit(PaymentMethodError(result['error'] ?? 'Failed to update payment method'));
      }
    } catch (e) {
      emit(PaymentMethodError('Failed to update payment method: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Deleting payment method...'));
    
    try {
      final result = await ApiService.deletePaymentMethod(
        paymentMethodId: event.paymentMethodId,
      );

      if (result['success'] == true) {
        final data = result['data'];
        emit(PaymentMethodDeleted(
          message: data['message'] ?? 'Payment method deleted successfully',
        ));
        
        // Refresh full wallet balance (includes payment methods, transactions, etc.)
        add(const RefreshWalletBalance());
      } else {
        emit(PaymentMethodError(result['error'] ?? 'Failed to delete payment method'));
      }
    } catch (e) {
      emit(PaymentMethodError('Failed to delete payment method: ${e.toString()}'));
    }
  }

  // ============================================
  // CASHOUT REQUEST HANDLERS
  // ============================================

  Future<void> _onCreateCashoutRequest(
    CreateCashoutRequest event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Creating cashout request...'));
    
    try {
      // Get vendor ID from event or user data
      String vendorId = event.vendorId ?? '1';
      
      if (event.vendorId == null) {
        // Get vendor ID from user data (user.vendor.id) via API call
        final userResult = await ApiService.getCurrentUser();
        
        if (userResult['success'] == true && userResult['data'] != null) {
          final user = userResult['data'];
          if (user['vendor'] != null && user['vendor']['id'] != null) {
            vendorId = user['vendor']['id'].toString();
          }
        }
      }
      
      final result = await ApiService.createCashoutRequest(
        vendorId: vendorId,
        amount: event.amount,
        reason: event.reason,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final request = CashoutRequest.fromJson(data['cashOutRequest']);
        
        emit(CashoutRequestCreated(
          request: request,
          message: data['message'] ?? 'Cashout request created successfully',
        ));
        
        // Refresh wallet balance (no vendorId needed, will be fetched in bloc)
        add(const RefreshWalletBalance());
      } else {
        emit(CashoutRequestError(result['error'] ?? 'Failed to create cashout request'));
      }
    } catch (e) {
      emit(CashoutRequestError('Failed to create cashout request: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCashoutRequests(
    FetchCashoutRequests event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Loading cashout requests...'));
    
    try {
      final result = await ApiService.getCashoutRequests(
        vendorId: event.vendorId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final requests = (data['cashOutRequests'] as List<dynamic>)
            .map((r) => CashoutRequest.fromJson(r as Map<String, dynamic>))
            .toList();
        
        final pagination = data['pagination'] ?? {};
        
        emit(CashoutRequestsLoaded(
          requests: requests,
          page: pagination['page'] ?? event.page,
          limit: pagination['limit'] ?? event.limit,
          total: pagination['total'] ?? requests.length,
          pages: pagination['pages'] ?? 1,
        ));
      } else {
        emit(CashoutRequestError(result['error'] ?? 'Failed to load cashout requests'));
      }
    } catch (e) {
      emit(CashoutRequestError('Failed to load cashout requests: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCashoutRequestDetails(
    FetchCashoutRequestDetails event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Loading request details...'));
    
    try {
      final result = await ApiService.getCashoutRequestDetails(
        requestId: event.requestId,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final request = CashoutRequest.fromJson(data['cashOutRequest']);
        
        emit(CashoutRequestDetailsLoaded(request: request));
      } else {
        emit(CashoutRequestError(result['error'] ?? 'Failed to load request details'));
      }
    } catch (e) {
      emit(CashoutRequestError('Failed to load request details: ${e.toString()}'));
    }
  }

  // ============================================
  // TRANSACTION HANDLERS
  // ============================================

  Future<void> _onFetchTransactionHistory(
    FetchTransactionHistory event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Loading transactions...'));
    
    try {
      final result = await ApiService.getTransactionHistory(
        vendorId: event.vendorId,
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final transactions = (data['transactions'] as List<dynamic>)
            .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
            .toList();
        
        final pagination = data['pagination'] ?? {};
        
        emit(TransactionHistoryLoaded(
          transactions: transactions,
          page: pagination['page'] ?? event.page,
          limit: pagination['limit'] ?? event.limit,
          total: pagination['total'] ?? transactions.length,
          pages: pagination['pages'] ?? 1,
        ));
      } else {
        emit(TransactionError(result['error'] ?? 'Failed to load transactions'));
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onExportTransactions(
    ExportTransactions event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading(message: 'Exporting transactions...'));
    
    try {
      final result = await ApiService.exportTransactions(
        vendorId: event.vendorId,
      );

      if (result['success'] == true) {
        emit(TransactionsExported(
          csvData: result['data'] as List<int>,
          filename: result['filename'] ?? 'transactions.csv',
          message: 'Transactions exported successfully',
        ));
      } else {
        emit(TransactionError(result['error'] ?? 'Failed to export transactions'));
      }
    } catch (e) {
      emit(TransactionError('Failed to export transactions: ${e.toString()}'));
    }
  }

  // ============================================
  // WEBSOCKET EVENT HANDLERS
  // ============================================

  Future<void> _onWalletFundsAdded(
    OnWalletFundsAdded event,
    Emitter<WalletState> emit,
  ) async {
    print('💰 [WalletBloc._onWalletFundsAdded] Funds added - Amount: ${event.amount}, New Balance: ${event.newBalance}');
    
    emit(WalletFundsAddedReceived(
      amount: event.amount,
      newBalance: event.newBalance,
      reason: event.reason ?? 'Funds added to wallet',
      message: '${event.amount} Br has been added to your wallet',
    ));
    
    // Refresh wallet balance to show updated balance
    print('🔄 [WalletBloc._onWalletFundsAdded] Refreshing wallet balance...');
    await _fetchBalance(emit);
  }

  Future<void> _onWalletFundsDeducted(
    OnWalletFundsDeducted event,
    Emitter<WalletState> emit,
  ) async {
    print('💸 [WalletBloc._onWalletFundsDeducted] Funds deducted - Amount: ${event.amount}, New Balance: ${event.newBalance}');
    
    emit(WalletFundsDeductedReceived(
      amount: event.amount,
      newBalance: event.newBalance,
      reason: event.reason ?? 'Funds deducted from wallet',
      message: '${event.amount} Br has been deducted from your wallet',
    ));
    
    // Refresh wallet balance to show updated balance
    print('🔄 [WalletBloc._onWalletFundsDeducted] Refreshing wallet balance...');
    await _fetchBalance(emit);
  }

  Future<void> _onCashoutRequestStatusChanged(
    OnCashoutRequestStatusChanged event,
    Emitter<WalletState> emit,
  ) async {
    print('═══════════════════════════════════════════════════════════');
    print('💳 [WalletBloc._onCashoutRequestStatusChanged] HANDLER CALLED');
    print('   Request ID: ${event.requestId}');
    print('   Status: ${event.status}');
    print('   New Balance: ${event.newBalance}');
    print('   Reason: ${event.reason}');
    print('═══════════════════════════════════════════════════════════');
    
    String message;
    if (event.status.toLowerCase() == 'approved') {
      message = 'Your cashout request has been approved';
      print('✅ [WalletBloc._onCashoutRequestStatusChanged] Cashout approved, will refresh balance');
    } else if (event.status.toLowerCase() == 'rejected') {
      message = 'Your cashout request has been rejected${event.reason != null ? ": ${event.reason}" : ""}';
      print('❌ [WalletBloc._onCashoutRequestStatusChanged] Cashout rejected');
    } else {
      message = 'Cashout request status updated to ${event.status}';
      print('🔄 [WalletBloc._onCashoutRequestStatusChanged] Status: ${event.status}');
    }
    
    print('🔄 [WalletBloc._onCashoutRequestStatusChanged] Step 1: Emitting CashoutStatusUpdated state...');
    emit(CashoutStatusUpdated(
      requestId: event.requestId,
      status: event.status,
      newBalance: event.newBalance,
      reason: event.reason,
      message: message,
    ));
    print('✅ [WalletBloc._onCashoutRequestStatusChanged] Step 1 complete: State emitted');
    
    // Refresh wallet balance to show updated balance and cashout status
    print('🔄 [WalletBloc._onCashoutRequestStatusChanged] Step 2: Refreshing wallet balance...');
    await _fetchBalance(emit);
    print('✅ [WalletBloc._onCashoutRequestStatusChanged] Step 2 complete: Balance refreshed');
    print('═══════════════════════════════════════════════════════════');
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
