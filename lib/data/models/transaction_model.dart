import 'package:equatable/equatable.dart';

enum TransactionType {
  sale,
  withdrawal,
  refund,
}

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String? orderId;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.orderId,
  });

  String get typeText {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  bool get isPositive => type == TransactionType.sale;

  @override
  List<Object?> get props => [id, type, amount, description, createdAt, orderId];
}

class WalletData extends Equatable {
  final double balance;
  final double totalEarnings;
  final double totalWithdrawals;
  final List<Transaction> recentTransactions;

  const WalletData({
    required this.balance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [balance, totalEarnings, totalWithdrawals, recentTransactions];
}
