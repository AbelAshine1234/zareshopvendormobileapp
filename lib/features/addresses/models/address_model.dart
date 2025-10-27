class AddressModel {
  final int id;
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? region;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? formattedAddress;
  final bool isPrimary;
  final bool isVerified;
  final DateTime createdAt;
  final int vendorId;
  final VendorInfo? vendor;

  AddressModel({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.region,
    this.subcity,
    this.woreda,
    this.kebele,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    this.placeId,
    this.formattedAddress,
    required this.isPrimary,
    required this.isVerified,
    required this.createdAt,
    required this.vendorId,
    this.vendor,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      region: json['region'] as String?,
      subcity: json['subcity'] as String?,
      woreda: json['woreda'] as String?,
      kebele: json['kebele'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeId: json['place_id'] as String?,
      formattedAddress: json['formatted_address'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      vendorId: json['vendor_id'] as int? ?? 0,
      vendor: json['vendor'] != null ? VendorInfo.fromJson(json['vendor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'region': region,
      'subcity': subcity,
      'woreda': woreda,
      'kebele': kebele,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'formatted_address': formattedAddress,
      'is_primary': isPrimary,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'vendor_id': vendorId,
      'vendor': vendor?.toJson(),
    };
  }

  AddressModel copyWith({
    int? id,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? region,
    String? subcity,
    String? woreda,
    String? kebele,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    String? placeId,
    String? formattedAddress,
    bool? isPrimary,
    bool? isVerified,
    DateTime? createdAt,
    int? vendorId,
    VendorInfo? vendor,
  }) {
    return AddressModel(
      id: id ?? this.id,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      region: region ?? this.region,
      subcity: subcity ?? this.subcity,
      woreda: woreda ?? this.woreda,
      kebele: kebele ?? this.kebele,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      isPrimary: isPrimary ?? this.isPrimary,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      vendorId: vendorId ?? this.vendorId,
      vendor: vendor ?? this.vendor,
    );
  }

  String get displayAddress {
    final parts = <String>[];
    
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2?.isNotEmpty == true) parts.add(addressLine2!);
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    if (country?.isNotEmpty == true) parts.add(country!);
    
    return parts.join(', ');
  }

  String get shortAddress {
    final parts = <String>[];
    
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (city?.isNotEmpty == true) parts.add(city!);
    
    return parts.join(', ');
  }
}

class VendorInfo {
  final int id;
  final String name;
  final int userId;

  VendorInfo({
    required this.id,
    required this.name,
    required this.userId,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
    };
  }
}
