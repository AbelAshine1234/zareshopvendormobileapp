import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

// ============================================
// WALLET BALANCE EVENTS
// ============================================

class FetchWalletBalance extends WalletEvent {
  final String? vendorId; // Optional - bloc will get from user data if null
  final bool isVendor;

  const FetchWalletBalance({
    this.vendorId,
    this.isVendor = true,
  });

  @override
  List<Object?> get props => [vendorId, isVendor];
}

class RefreshWalletBalance extends WalletEvent {
  final String? vendorId; // Optional - bloc will get from user data if null
  final bool isVendor;

  const RefreshWalletBalance({
    this.vendorId,
    this.isVendor = true,
  });

  @override
  List<Object?> get props => [vendorId, isVendor];
}

class AddFundsToWallet extends WalletEvent {
  final String? vendorId; // Optional - bloc will get from user data if null
  final double amount;
  final String? reason;

  const AddFundsToWallet({
    this.vendorId,
    required this.amount,
    this.reason,
  });

  @override
  List<Object?> get props => [vendorId, amount, reason];
}

// ============================================
// PAYMENT METHOD EVENTS
// ============================================

class FetchPaymentMethods extends WalletEvent {
  final String vendorId;

  const FetchPaymentMethods({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

class CreatePaymentMethod extends WalletEvent {
  final String vendorId;
  final String name;
  final String accountNumber;
  final String accountHolder;
  final String? type;
  final Map<String, dynamic>? details;

  const CreatePaymentMethod({
    required this.vendorId,
    required this.name,
    required this.accountNumber,
    required this.accountHolder,
    this.type,
    this.details,
  });

  @override
  List<Object?> get props => [vendorId, name, accountNumber, accountHolder, type, details];
}

class UpdatePaymentMethod extends WalletEvent {
  final int paymentMethodId;
  final String? name;
  final String? accountNumber;
  final String? accountHolder;
  final String? type;
  final Map<String, dynamic>? details;

  const UpdatePaymentMethod({
    required this.paymentMethodId,
    this.name,
    this.accountNumber,
    this.accountHolder,
    this.type,
    this.details,
  });

  @override
  List<Object?> get props => [paymentMethodId, name, accountNumber, accountHolder, type, details];
}

class DeletePaymentMethod extends WalletEvent {
  final int paymentMethodId;
  final String vendorId;

  const DeletePaymentMethod({
    required this.paymentMethodId,
    required this.vendorId,
  });

  @override
  List<Object?> get props => [paymentMethodId, vendorId];
}

// ============================================
// CASHOUT REQUEST EVENTS
// ============================================

class CreateCashoutRequest extends WalletEvent {
  final String? vendorId; // Optional - bloc will get from user data if null
  final double amount;
  final String? reason;

  const CreateCashoutRequest({
    this.vendorId,
    required this.amount,
    this.reason,
  });

  @override
  List<Object?> get props => [vendorId, amount, reason];
}

class FetchCashoutRequests extends WalletEvent {
  final String vendorId;
  final int page;
  final int limit;
  final String? status;

  const FetchCashoutRequests({
    required this.vendorId,
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [vendorId, page, limit, status];
}

class FetchCashoutRequestDetails extends WalletEvent {
  final int requestId;

  const FetchCashoutRequestDetails({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

// ============================================
// TRANSACTION EVENTS
// ============================================

class FetchTransactionHistory extends WalletEvent {
  final String vendorId;
  final int page;
  final int limit;
  final String? status;

  const FetchTransactionHistory({
    required this.vendorId,
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [vendorId, page, limit, status];
}

class ExportTransactions extends WalletEvent {
  final String vendorId;

  const ExportTransactions({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

// ============================================
// WEBSOCKET EVENTS (from SocketBloc)
// ============================================

class OnWalletFundsAdded extends WalletEvent {
  final int walletId;
  final int vendorId;
  final double amount;
  final double newBalance;
  final String? reason;

  const OnWalletFundsAdded({
    required this.walletId,
    required this.vendorId,
    required this.amount,
    required this.newBalance,
    this.reason,
  });

  @override
  List<Object?> get props => [walletId, vendorId, amount, newBalance, reason];
}

class OnWalletFundsDeducted extends WalletEvent {
  final int walletId;
  final int vendorId;
  final double amount;
  final double newBalance;
  final String? reason;

  const OnWalletFundsDeducted({
    required this.walletId,
    required this.vendorId,
    required this.amount,
    required this.newBalance,
    this.reason,
  });

  @override
  List<Object?> get props => [walletId, vendorId, amount, newBalance, reason];
}

class OnCashoutRequestStatusChanged extends WalletEvent {
  final int requestId;
  final int vendorId;
  final String status;
  final double? newBalance;
  final String? reason;

  const OnCashoutRequestStatusChanged({
    required this.requestId,
    required this.vendorId,
    required this.status,
    this.newBalance,
    this.reason,
  });

  @override
  List<Object?> get props => [requestId, vendorId, status, newBalance, reason];
}
