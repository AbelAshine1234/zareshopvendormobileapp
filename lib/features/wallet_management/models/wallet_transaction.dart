import 'payment_method.dart';

class WalletTransaction {
  final int id;
  final String transactionId;
  final String type; // credit, debit
  final String category; // cash_out_request, order, refund, etc.
  final double amount;
  final String reason;
  final String status; // completed, pending, failed
  final Map<String, dynamic>? metadata;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int walletId;
  final int? orderId;
  final int? cashOutRequestId;
  final int? refundId;

  WalletTransaction({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.category,
    required this.amount,
    required this.reason,
    required this.status,
    this.metadata,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
    required this.updatedAt,
    required this.walletId,
    this.orderId,
    this.cashOutRequestId,
    this.refundId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      walletId: json['wallet_id'] ?? 0,
      orderId: json['order_id'],
      cashOutRequestId: json['cash_out_request_id'],
      refundId: json['refund_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'type': type,
      'category': category,
      'amount': amount,
      'reason': reason,
      'status': status,
      'metadata': metadata,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'wallet_id': walletId,
      'order_id': orderId,
      'cash_out_request_id': cashOutRequestId,
      'refund_id': refundId,
    };
  }

  bool get isCredit => type.toLowerCase() == 'credit';
  bool get isDebit => type.toLowerCase() == 'debit';
}

class WalletData {
  final int id;
  final double balance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final int? vendorId; // Vendor ID (different from user ID)
  final String userName;
  final String? userEmail;
  final String userType;
  final List<WalletTransaction> transactions;
  final List<PaymentMethod> paymentMethods;
  final int paymentMethodsCount;

  WalletData({
    required this.id,
    required this.balance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.vendorId,
    required this.userName,
    this.userEmail,
    required this.userType,
    required this.transactions,
    required this.paymentMethods,
    required this.paymentMethodsCount,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    final walletJson = json['wallet'] ?? json;
    final userJson = walletJson['user'] ?? {};
    
    // Try to get vendor ID from multiple possible locations
    int? vendorId;
    if (walletJson['vendor_id'] != null) {
      vendorId = walletJson['vendor_id'];
    } else if (userJson['vendor_id'] != null) {
      vendorId = userJson['vendor_id'];
    } else if (userJson['vendorId'] != null) {
      vendorId = userJson['vendorId'];
    }
    
    return WalletData(
      id: walletJson['id'] ?? 0,
      balance: (walletJson['balance'] ?? 0).toDouble(),
      status: walletJson['status']?.toString() ?? 'active',
      createdAt: walletJson['created_at'] != null
          ? DateTime.parse(walletJson['created_at'])
          : DateTime.now(),
      updatedAt: walletJson['updated_at'] != null
          ? DateTime.parse(walletJson['updated_at'])
          : DateTime.now(),
      userId: userJson['id'] ?? 0,
      vendorId: vendorId,
      userName: userJson['name']?.toString() ?? '',
      userEmail: userJson['email']?.toString(),
      userType: userJson['type']?.toString() ?? '',
      transactions: (walletJson['transactions'] as List<dynamic>?)
              ?.map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      paymentMethods: (walletJson['payment_methods'] as List<dynamic>?)
              ?.map((p) => PaymentMethod.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      paymentMethodsCount: walletJson['payment_methods_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'vendor_id': vendorId,
      'user_name': userName,
      'user_email': userEmail,
      'user_type': userType,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'payment_methods': paymentMethods.map((p) => p.toJson()).toList(),
      'payment_methods_count': paymentMethodsCount,
    };
  }
}
