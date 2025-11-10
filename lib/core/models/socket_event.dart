/// WebSocket event models for real-time communication
class SocketEvent {
  final String event;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SocketEvent({
    required this.event,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    return SocketEvent(
      event: json['event'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Vendor-specific WebSocket events
class VendorSocketEvents {
  // Events emitted by backend
  static const String connectionSuccess = 'connection:success';
  static const String vendorApproved = 'vendor:approved';
  static const String vendorRejected = 'vendor:rejected';
  static const String vendorStatusChanged = 'vendor:status:changed';
  static const String vendorUpdated = 'vendor:updated';
  
  // Wallet events emitted by backend
  static const String walletFundsAdded = 'wallet:funds:added';
  static const String walletFundsDeducted = 'wallet:funds:deducted';
  
  // Cashout events emitted by backend
  static const String cashoutRequestCreated = 'cashout:request:created';
  static const String cashoutRequestApproved = 'cashout:request:approved';
  static const String cashoutRequestRejected = 'cashout:request:rejected';
  static const String cashoutRequestStatusChanged = 'cashout:request:status:changed';

  // Events listened by backend
  static const String vendorSubscribe = 'vendor:subscribe';
  static const String vendorUnsubscribe = 'vendor:unsubscribe';
  static const String vendorStatusRequest = 'vendor:status:request';
  static const String vendorPing = 'vendor:ping';
}

/// Vendor approval event data
class VendorApprovalEvent {
  final int vendorId;
  final String businessName;
  final String status;
  final String? message;
  final DateTime? approvedAt;

  VendorApprovalEvent({
    required this.vendorId,
    required this.businessName,
    required this.status,
    this.message,
    this.approvedAt,
  });

  factory VendorApprovalEvent.fromJson(Map<String, dynamic> json) {
    return VendorApprovalEvent(
      // Handle both camelCase (vendorId) and snake_case (vendor_id)
      vendorId: (json['vendorId'] ?? json['vendor_id']) as int,
      // Handle both vendorName and business_name
      businessName: (json['vendorName'] ?? json['business_name']) as String,
      // Status might be boolean or string
      status: json['status']?.toString() ?? 'approved',
      message: json['message'] as String?,
      // Handle both timestamp formats
      approvedAt: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : (json['approved_at'] != null
              ? DateTime.parse(json['approved_at'] as String)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'business_name': businessName,
      'status': status,
      'message': message,
      'approved_at': approvedAt?.toIso8601String(),
    };
  }
}

/// Vendor rejection event data
class VendorRejectionEvent {
  final int vendorId;
  final String businessName;
  final String status;
  final String? reason;
  final DateTime? rejectedAt;

  VendorRejectionEvent({
    required this.vendorId,
    required this.businessName,
    required this.status,
    this.reason,
    this.rejectedAt,
  });

  factory VendorRejectionEvent.fromJson(Map<String, dynamic> json) {
    return VendorRejectionEvent(
      // Handle both camelCase (vendorId) and snake_case (vendor_id)
      vendorId: (json['vendorId'] ?? json['vendor_id']) as int,
      // Handle both vendorName and business_name
      businessName: (json['vendorName'] ?? json['business_name']) as String,
      // Status might be boolean or string
      status: json['status']?.toString() ?? 'rejected',
      reason: json['reason'] as String?,
      // Handle both timestamp formats
      rejectedAt: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : (json['rejected_at'] != null
              ? DateTime.parse(json['rejected_at'] as String)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'business_name': businessName,
      'status': status,
      'reason': reason,
      'rejected_at': rejectedAt?.toIso8601String(),
    };
  }
}

/// Vendor status change event data
class VendorStatusChangeEvent {
  final int vendorId;
  final String businessName;
  final String oldStatus;
  final String newStatus;
  final String? reason;
  final DateTime? changedAt;

  VendorStatusChangeEvent({
    required this.vendorId,
    required this.businessName,
    required this.oldStatus,
    required this.newStatus,
    this.reason,
    this.changedAt,
  });

  factory VendorStatusChangeEvent.fromJson(Map<String, dynamic> json) {
    return VendorStatusChangeEvent(
      // Handle both camelCase (vendorId) and snake_case (vendor_id)
      vendorId: (json['vendorId'] ?? json['vendor_id']) as int,
      // Handle both vendorName and business_name
      businessName: (json['vendorName'] ?? json['business_name']) as String,
      // Handle both oldStatus and old_status
      oldStatus: (json['oldStatus'] ?? json['old_status']) as String,
      // Handle both newStatus and new_status
      newStatus: (json['newStatus'] ?? json['new_status']) as String,
      reason: json['reason'] as String?,
      // Handle both timestamp formats
      changedAt: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : (json['changed_at'] != null
              ? DateTime.parse(json['changed_at'] as String)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'business_name': businessName,
      'old_status': oldStatus,
      'new_status': newStatus,
      'reason': reason,
      'changed_at': changedAt?.toIso8601String(),
    };
  }
}

/// Wallet funds added event data
class WalletFundsAddedEvent {
  final int walletId;
  final int vendorId;
  final double amount;
  final double newBalance;
  final String? reason;
  final DateTime? timestamp;

  WalletFundsAddedEvent({
    required this.walletId,
    required this.vendorId,
    required this.amount,
    required this.newBalance,
    this.reason,
    this.timestamp,
  });

  factory WalletFundsAddedEvent.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case
    final walletId = json['walletId'] ?? json['wallet_id'];
    final vendorId = json['vendorId'] ?? json['vendor_id'];
    final amount = json['amount'];
    final newBalance = json['newBalance'] ?? json['new_balance'];
    final reason = json['reason'];
    final timestamp = json['timestamp'];
    
    return WalletFundsAddedEvent(
      walletId: walletId is int ? walletId : int.parse(walletId.toString()),
      vendorId: vendorId is int ? vendorId : int.parse(vendorId.toString()),
      amount: amount is double ? amount : (amount is int ? amount.toDouble() : double.parse(amount.toString())),
      newBalance: newBalance is double ? newBalance : (newBalance is int ? newBalance.toDouble() : double.parse(newBalance.toString())),
      reason: reason?.toString(),
      timestamp: timestamp != null
          ? (timestamp is DateTime ? timestamp : DateTime.parse(timestamp.toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'vendor_id': vendorId,
      'amount': amount,
      'new_balance': newBalance,
      'reason': reason,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

/// Wallet funds deducted event data
class WalletFundsDeductedEvent {
  final int walletId;
  final int vendorId;
  final double amount;
  final double newBalance;
  final String? reason;
  final DateTime? timestamp;

  WalletFundsDeductedEvent({
    required this.walletId,
    required this.vendorId,
    required this.amount,
    required this.newBalance,
    this.reason,
    this.timestamp,
  });

  factory WalletFundsDeductedEvent.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case
    final walletId = json['walletId'] ?? json['wallet_id'];
    final vendorId = json['vendorId'] ?? json['vendor_id'];
    final amount = json['amount'];
    final newBalance = json['newBalance'] ?? json['new_balance'];
    final reason = json['reason'];
    final timestamp = json['timestamp'];
    
    return WalletFundsDeductedEvent(
      walletId: walletId is int ? walletId : int.parse(walletId.toString()),
      vendorId: vendorId is int ? vendorId : int.parse(vendorId.toString()),
      amount: amount is double ? amount : (amount is int ? amount.toDouble() : double.parse(amount.toString())),
      newBalance: newBalance is double ? newBalance : (newBalance is int ? newBalance.toDouble() : double.parse(newBalance.toString())),
      reason: reason?.toString(),
      timestamp: timestamp != null
          ? (timestamp is DateTime ? timestamp : DateTime.parse(timestamp.toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'vendor_id': vendorId,
      'amount': amount,
      'new_balance': newBalance,
      'reason': reason,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

/// Cashout request event data
class CashoutRequestEvent {
  final int requestId;
  final int vendorId;
  final double amount;
  final String status;
  final String? reason;
  final DateTime? timestamp;

  CashoutRequestEvent({
    required this.requestId,
    required this.vendorId,
    required this.amount,
    required this.status,
    this.reason,
    this.timestamp,
  });

  factory CashoutRequestEvent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }
    
    try {
      // Handle both camelCase and snake_case with safe extraction
      final requestId = json['requestId'] ?? json['request_id'] ?? 0;
      final vendorId = json['vendorId'] ?? json['vendor_id'] ?? 0;
      final amount = json['amount'] ?? 0;
      final status = json['status'];
      final reason = json['reason'];
      final timestamp = json['timestamp'];
      
      return CashoutRequestEvent(
        requestId: requestId is int ? requestId : int.tryParse(requestId.toString()) ?? 0,
        vendorId: vendorId is int ? vendorId : int.tryParse(vendorId.toString()) ?? 0,
        amount: amount is double 
            ? amount 
            : (amount is int 
                ? amount.toDouble() 
                : double.tryParse(amount.toString()) ?? 0.0),
        status: status?.toString() ?? 'pending',
        reason: reason?.toString(),
        timestamp: timestamp != null
            ? (timestamp is DateTime 
                ? timestamp 
                : DateTime.tryParse(timestamp.toString()))
            : DateTime.now(),
      );
    } catch (e) {
      print('ERROR parsing CashoutRequestEvent: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'vendor_id': vendorId,
      'amount': amount,
      'status': status,
      'reason': reason,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
