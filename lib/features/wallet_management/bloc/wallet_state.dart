import 'package:equatable/equatable.dart';
import '../models/wallet_transaction.dart';
import '../models/payment_method.dart';
import '../models/cashout_request.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

// ============================================
// INITIAL & LOADING STATES
// ============================================

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {
  final String? message;

  const WalletLoading({this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================
// WALLET BALANCE STATES
// ============================================

class WalletBalanceLoaded extends WalletState {
  final WalletData walletData;

  const WalletBalanceLoaded(this.walletData);

  @override
  List<Object?> get props => [walletData];
}

class WalletBalanceLoadedWithCashouts extends WalletBalanceLoaded {
  final List<CashoutRequest> cashoutRequests;

  const WalletBalanceLoadedWithCashouts({
    required WalletData walletData,
    required this.cashoutRequests,
  }) : super(walletData);

  @override
  List<Object?> get props => [walletData, cashoutRequests];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class FundsAddedSuccess extends WalletState {
  final double amount;
  final double newBalance;
  final String message;

  const FundsAddedSuccess({
    required this.amount,
    required this.newBalance,
    required this.message,
  });

  @override
  List<Object?> get props => [amount, newBalance, message];
}

// ============================================
// PAYMENT METHOD STATES
// ============================================

class PaymentMethodsLoaded extends WalletState {
  final List<PaymentMethod> paymentMethods;
  final int count;

  const PaymentMethodsLoaded({
    required this.paymentMethods,
    required this.count,
  });

  @override
  List<Object?> get props => [paymentMethods, count];
}

class PaymentMethodCreated extends WalletState {
  final PaymentMethod paymentMethod;
  final String message;

  const PaymentMethodCreated({
    required this.paymentMethod,
    required this.message,
  });

  @override
  List<Object?> get props => [paymentMethod, message];
}

class PaymentMethodUpdated extends WalletState {
  final PaymentMethod paymentMethod;
  final String message;

  const PaymentMethodUpdated({
    required this.paymentMethod,
    required this.message,
  });

  @override
  List<Object?> get props => [paymentMethod, message];
}

class PaymentMethodDeleted extends WalletState {
  final String message;

  const PaymentMethodDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentMethodError extends WalletState {
  final String message;

  const PaymentMethodError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// CASHOUT REQUEST STATES
// ============================================

class CashoutRequestsLoaded extends WalletState {
  final List<CashoutRequest> requests;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const CashoutRequestsLoaded({
    required this.requests,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  @override
  List<Object?> get props => [requests, page, limit, total, pages];
}

class CashoutRequestCreated extends WalletState {
  final CashoutRequest request;
  final String message;

  const CashoutRequestCreated({
    required this.request,
    required this.message,
  });

  @override
  List<Object?> get props => [request, message];
}

class CashoutRequestDetailsLoaded extends WalletState {
  final CashoutRequest request;

  const CashoutRequestDetailsLoaded({required this.request});

  @override
  List<Object?> get props => [request];
}

class CashoutRequestError extends WalletState {
  final String message;

  const CashoutRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// TRANSACTION STATES
// ============================================

class TransactionHistoryLoaded extends WalletState {
  final List<WalletTransaction> transactions;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  @override
  List<Object?> get props => [transactions, page, limit, total, pages];
}

class TransactionsExported extends WalletState {
  final List<int> csvData;
  final String filename;
  final String message;

  const TransactionsExported({
    required this.csvData,
    required this.filename,
    required this.message,
  });

  @override
  List<Object?> get props => [csvData, filename, message];
}

class TransactionError extends WalletState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================
// WEBSOCKET STATES
// ============================================

class WalletFundsAddedReceived extends WalletState {
  final double amount;
  final double newBalance;
  final String reason;
  final String message;

  const WalletFundsAddedReceived({
    required this.amount,
    required this.newBalance,
    required this.reason,
    required this.message,
  });

  @override
  List<Object?> get props => [amount, newBalance, reason, message];
}

class WalletFundsDeductedReceived extends WalletState {
  final double amount;
  final double newBalance;
  final String reason;
  final String message;

  const WalletFundsDeductedReceived({
    required this.amount,
    required this.newBalance,
    required this.reason,
    required this.message,
  });

  @override
  List<Object?> get props => [amount, newBalance, reason, message];
}

class CashoutStatusUpdated extends WalletState {
  final int requestId;
  final String status;
  final double? newBalance;
  final String? reason;
  final String message;

  const CashoutStatusUpdated({
    required this.requestId,
    required this.status,
    this.newBalance,
    this.reason,
    required this.message,
  });

  @override
  List<Object?> get props => [requestId, status, newBalance, reason, message];
}
