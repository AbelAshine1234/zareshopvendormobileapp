class PaymentMethod {
  final int id;
  final String name;
  final String accountNumber;
  final String accountHolder;
  final String type;
  final Map<String, dynamic>? details;
  final DateTime createdAt;
  final int vendorId;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountHolder,
    required this.type,
    this.details,
    required this.createdAt,
    required this.vendorId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountHolder: json['account_holder']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      details: json['details'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      vendorId: json['vendor_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'account_number': accountNumber,
      'account_holder': accountHolder,
      'type': type,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'vendor_id': vendorId,
    };
  }

  PaymentMethod copyWith({
    int? id,
    String? name,
    String? accountNumber,
    String? accountHolder,
    String? type,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    int? vendorId,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      type: type ?? this.type,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      vendorId: vendorId ?? this.vendorId,
    );
  }
}
