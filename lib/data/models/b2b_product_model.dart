import 'package:equatable/equatable.dart';

class B2BProduct extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int stock;
  final String category;
  final String vendorId;
  final String vendorName;
  final String vendorImageUrl;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final int minOrderQuantity;
  final String unit;
  final bool isWholesale;
  final double? wholesalePrice;
  final int? wholesaleMinQuantity;

  const B2BProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.vendorId,
    required this.vendorName,
    required this.vendorImageUrl,
    required this.rating,
    required this.reviewCount,
    this.isActive = true,
    required this.createdAt,
    required this.imageUrls,
    required this.specifications,
    required this.minOrderQuantity,
    required this.unit,
    this.isWholesale = false,
    this.wholesalePrice,
    this.wholesaleMinQuantity,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get finalPrice => discountPrice ?? price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  bool get isInStock => stock > 0;

  String get stockStatus {
    if (stock == 0) return 'Out of Stock';
    if (stock < 10) return 'Low Stock';
    return 'In Stock';
  }

  B2BProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    int? stock,
    String? category,
    String? vendorId,
    String? vendorName,
    String? vendorImageUrl,
    double? rating,
    int? reviewCount,
    bool? isActive,
    DateTime? createdAt,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
    int? minOrderQuantity,
    String? unit,
    bool? isWholesale,
    double? wholesalePrice,
    int? wholesaleMinQuantity,
  }) {
    return B2BProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorImageUrl: vendorImageUrl ?? this.vendorImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      specifications: specifications ?? this.specifications,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      unit: unit ?? this.unit,
      isWholesale: isWholesale ?? this.isWholesale,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      wholesaleMinQuantity: wholesaleMinQuantity ?? this.wholesaleMinQuantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        imageUrl,
        stock,
        category,
        vendorId,
        vendorName,
        vendorImageUrl,
        rating,
        reviewCount,
        isActive,
        createdAt,
        imageUrls,
        specifications,
        minOrderQuantity,
        unit,
        isWholesale,
        wholesalePrice,
        wholesaleMinQuantity,
      ];
}

class B2BVendor extends Equatable {
  final String id;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String address;
  final String city;
  final String country;
  final double rating;
  final int reviewCount;
  final int productCount;
  final String subscriptionPlan;
  final DateTime joinedDate;
  final bool isVerified;
  final List<String> categories;
  final String businessType;
  final int yearsInBusiness;

  const B2BVendor({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.address,
    required this.city,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.productCount,
    required this.subscriptionPlan,
    required this.joinedDate,
    this.isVerified = false,
    required this.categories,
    required this.businessType,
    required this.yearsInBusiness,
  });

  String get fullAddress => '$address, $city, $country';

  String get businessInfo => '$businessType • $yearsInBusiness years in business';

  B2BVendor copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? address,
    String? city,
    String? country,
    double? rating,
    int? reviewCount,
    int? productCount,
    String? subscriptionPlan,
    DateTime? joinedDate,
    bool? isVerified,
    List<String>? categories,
    String? businessType,
    int? yearsInBusiness,
  }) {
    return B2BVendor(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      productCount: productCount ?? this.productCount,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
      categories: categories ?? this.categories,
      businessType: businessType ?? this.businessType,
      yearsInBusiness: yearsInBusiness ?? this.yearsInBusiness,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopName,
        ownerName,
        email,
        phone,
        profileImageUrl,
        bannerImageUrl,
        address,
        city,
        country,
        rating,
        reviewCount,
        productCount,
        subscriptionPlan,
        joinedDate,
        isVerified,
        categories,
        businessType,
        yearsInBusiness,
      ];
}

class B2BOrder extends Equatable {
  final String id;
  final String productId;
  final String vendorId;
  final String buyerId;
  final String productName;
  final String vendorName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? notes;
  final String? trackingNumber;

  const B2BOrder({
    required this.id,
    required this.productId,
    required this.vendorId,
    required this.buyerId,
    required this.productName,
    required this.vendorName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.notes,
    this.trackingNumber,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  B2BOrder copyWith({
    String? id,
    String? productId,
    String? vendorId,
    String? buyerId,
    String? productName,
    String? vendorName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? status,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? notes,
    String? trackingNumber,
  }) {
    return B2BOrder(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      vendorId: vendorId ?? this.vendorId,
      buyerId: buyerId ?? this.buyerId,
      productName: productName ?? this.productName,
      vendorName: vendorName ?? this.vendorName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        vendorId,
        buyerId,
        productName,
        vendorName,
        quantity,
        unitPrice,
        totalPrice,
        status,
        orderDate,
        deliveryDate,
        notes,
        trackingNumber,
      ];
}
