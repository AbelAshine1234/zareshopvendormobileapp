class CashoutRequest {
  final int id;
  final double amount;
  final String reason;
  final String status; // pending, approved, rejected
  final int userId;
  final int vendorId;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final VendorInfo? vendor;

  CashoutRequest({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    required this.userId,
    required this.vendorId,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.vendor,
  });

  factory CashoutRequest.fromJson(Map<String, dynamic> json) {
    // Safe amount parsing
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return CashoutRequest(
      id: json['id'] ?? 0,
      amount: parseAmount(json['amount']),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      userId: json['user_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      vendor: json['vendor'] != null
          ? VendorInfo.fromJson(json['vendor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'reason': reason,
      'status': status,
      'user_id': userId,
      'vendor_id': vendorId,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'vendor': vendor?.toJson(),
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
}

class VendorInfo {
  final int id;
  final String name;
  final String type;

  VendorInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
