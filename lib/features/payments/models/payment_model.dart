import 'package:equatable/equatable.dart';

enum PaymentMethod {
  manual,
  integrated,
}

enum PaymentProvider {
  bankTransfer,
  mobileMoney,
  stripe,
  chapa,
  paypal,
  cash,
  check,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
  verified,
}

class Payment extends Equatable {
  final int id;
  final int? vendorId;
  final int userId;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? paymentProvider;
  final String? externalPaymentId;
  final String? paymentReference;
  final int? manualPaymentProofId;
  final String? adminNotes;
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final User? user;
  final Vendor? vendor;
  final PaymentProof? manualPaymentProof;

  const Payment({
    required this.id,
    this.vendorId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.paymentProvider,
    this.externalPaymentId,
    this.paymentReference,
    this.manualPaymentProofId,
    this.adminNotes,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.user,
    this.vendor,
    this.manualPaymentProof,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int?,
      userId: json['user_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'ETB',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.manual,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentProvider: json['payment_provider'] as String?,
      externalPaymentId: json['external_payment_id'] as String?,
      paymentReference: json['payment_reference'] as String?,
      manualPaymentProofId: json['manual_payment_proof_id'] as int?,
      adminNotes: json['admin_notes'] as String?,
      verifiedBy: json['verified_by'] as int?,
      verifiedAt: json['verified_at'] != null 
          ? DateTime.parse(json['verified_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      vendor: json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null,
      manualPaymentProof: json['manual_payment_proof'] != null 
          ? PaymentProof.fromJson(json['manual_payment_proof']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'payment_provider': paymentProvider,
      'external_payment_id': externalPaymentId,
      'payment_reference': paymentReference,
      'manual_payment_proof_id': manualPaymentProofId,
      'admin_notes': adminNotes,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'user': user?.toJson(),
      'vendor': vendor?.toJson(),
      'manual_payment_proof': manualPaymentProof?.toJson(),
    };
  }

  Payment copyWith({
    int? id,
    int? vendorId,
    int? userId,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? paymentProvider,
    String? externalPaymentId,
    String? paymentReference,
    int? manualPaymentProofId,
    String? adminNotes,
    int? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    User? user,
    Vendor? vendor,
    PaymentProof? manualPaymentProof,
  }) {
    return Payment(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      externalPaymentId: externalPaymentId ?? this.externalPaymentId,
      paymentReference: paymentReference ?? this.paymentReference,
      manualPaymentProofId: manualPaymentProofId ?? this.manualPaymentProofId,
      adminNotes: adminNotes ?? this.adminNotes,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      user: user ?? this.user,
      vendor: vendor ?? this.vendor,
      manualPaymentProof: manualPaymentProof ?? this.manualPaymentProof,
    );
  }

  bool get isPending => status == PaymentStatus.pending;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isVerified => status == PaymentStatus.verified;
  bool get hasProof => manualPaymentProofId != null;
  bool get isManual => paymentMethod == PaymentMethod.manual;

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.verified:
        return 'Verified';
    }
  }

  String get methodText {
    switch (paymentMethod) {
      case PaymentMethod.manual:
        return 'Manual Payment';
      case PaymentMethod.integrated:
        return 'Integrated Payment';
    }
  }

  @override
  List<Object?> get props => [
        id,
        vendorId,
        userId,
        amount,
        currency,
        paymentMethod,
        status,
        paymentProvider,
        externalPaymentId,
        paymentReference,
        manualPaymentProofId,
        adminNotes,
        verifiedBy,
        verifiedAt,
        createdAt,
        updatedAt,
        completedAt,
        user,
        vendor,
        manualPaymentProof,
      ];
}

class User extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String phoneNumber;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}

class Vendor extends Equatable {
  final int id;
  final String businessName;
  final String? businessType;
  final String? status;

  const Vendor({
    required this.id,
    required this.businessName,
    this.businessType,
    this.status,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      businessName: (json['business_name'] ?? json['name']) as String? ?? 'Unknown',
      businessType: json['business_type'] as String?,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'business_type': businessType,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, businessName, businessType, status];
}

class PaymentProof extends Equatable {
  final int id;
  final String imageUrl;
  final String? filename;

  const PaymentProof({
    required this.id,
    required this.imageUrl,
    this.filename,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    return PaymentProof(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      filename: json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'filename': filename,
    };
  }

  @override
  List<Object?> get props => [id, imageUrl, filename];
}

class PaymentInstructions extends Equatable {
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? reference;
  final double amount;
  final String? instructions;
  final String? provider;
  final String? phoneNumber;

  const PaymentInstructions({
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.reference,
    required this.amount,
    this.instructions,
    this.provider,
    this.phoneNumber,
  });

  factory PaymentInstructions.fromJson(Map<String, dynamic> json) {
    return PaymentInstructions(
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      reference: json['reference'] as String?,
      amount: (json['amount'] as num).toDouble(),
      instructions: json['instructions'] as String?,
      provider: json['provider'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'reference': reference,
      'amount': amount,
      'instructions': instructions,
      'provider': provider,
      'phone_number': phoneNumber,
    };
  }

  @override
  List<Object?> get props => [
        bankName,
        accountNumber,
        accountName,
        reference,
        amount,
        instructions,
        provider,
        phoneNumber,
      ];
}

class PaymentResponse extends Equatable {
  final bool success;
  final String message;
  final Payment? payment;
  final PaymentInstructions? paymentInstructions;
  final List<Payment>? payments;
  final Pagination? pagination;

  const PaymentResponse({
    required this.success,
    required this.message,
    this.payment,
    this.paymentInstructions,
    this.payments,
    this.pagination,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      payment: json['payment'] != null 
          ? Payment.fromJson(json['payment']) 
          : null,
      paymentInstructions: json['paymentInstructions'] != null 
          ? PaymentInstructions.fromJson(json['paymentInstructions']) 
          : null,
      payments: json['payments'] != null 
          ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
          : null,
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        payment,
        paymentInstructions,
        payments,
        pagination,
      ];
}

class PaymentListResponse extends Equatable {
  final List<Payment> payments;
  final Pagination pagination;
  final bool success;
  final String message;

  const PaymentListResponse({
    required this.payments,
    required this.pagination,
    required this.success,
    required this.message,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentListResponse(
      payments: (json['data']['payments'] as List)
          .map((paymentJson) => Payment.fromJson(paymentJson))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination']),
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [payments, pagination, success, message];
}

class NextStep extends Equatable {
  final String action;
  final String description;
  final Map<String, dynamic>? data;
  final bool completed;

  const NextStep({
    required this.action,
    required this.description,
    this.data,
    required this.completed,
  });

  factory NextStep.fromJson(Map<String, dynamic> json) {
    return NextStep(
      action: json['action'] as String,
      description: json['description'] as String,
      data: json['data'] as Map<String, dynamic>?,
      completed: json['completed'] as bool,
    );
  }

  @override
  List<Object?> get props => [action, description, data, completed];
}

class PaymentQRData extends Equatable {
  final String qrCode;
  final String paymentUrl;
  final String qrImageUrl;

  const PaymentQRData({
    required this.qrCode,
    required this.paymentUrl,
    required this.qrImageUrl,
  });

  factory PaymentQRData.fromJson(Map<String, dynamic> json) {
    return PaymentQRData(
      qrCode: json['qr_code'] as String,
      paymentUrl: json['payment_url'] as String,
      qrImageUrl: json['qr_image_url'] as String,
    );
  }

  @override
  List<Object?> get props => [qrCode, paymentUrl, qrImageUrl];
}

class PaymentPagination extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaymentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaymentPagination.fromJson(Map<String, dynamic> json) {
    return PaymentPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }

  @override
  List<Object?> get props => [page, limit, total, pages];
}

class Pagination extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'pages': pages,
    };
  }

  @override
  List<Object?> get props => [page, limit, total, pages];
}

class PaymentStatistics extends Equatable {
  final int totalPayments;
  final int completedPayments;
  final int pendingPayments;
  final int failedPayments;
  final double totalRevenue;
  final double monthlyRevenue;
  final double completionRate;

  const PaymentStatistics({
    required this.totalPayments,
    required this.completedPayments,
    required this.pendingPayments,
    required this.failedPayments,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.completionRate,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) {
    return PaymentStatistics(
      totalPayments: json['totalPayments'] as int,
      completedPayments: json['completedPayments'] as int,
      pendingPayments: json['pendingPayments'] as int,
      failedPayments: json['failedPayments'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        totalPayments,
        completedPayments,
        pendingPayments,
        failedPayments,
        totalRevenue,
        monthlyRevenue,
        completionRate,
      ];
}
