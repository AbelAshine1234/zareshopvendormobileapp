class B2BSupplier {
  final String id;
  final String name;
  final String logo;
  final String category;
  final double rating;
  final int totalProducts;
  final int totalReviews;
  final String location;
  final bool isVerified;
  final bool isTrending;
  final int yearsInBusiness;
  final List<String> sampleProductImages;

  B2BSupplier({
    required this.id,
    required this.name,
    required this.logo,
    required this.category,
    required this.rating,
    required this.totalProducts,
    required this.totalReviews,
    required this.location,
    required this.isVerified,
    required this.isTrending,
    required this.yearsInBusiness,
    this.sampleProductImages = const [],
  });

  factory B2BSupplier.fromJson(Map<String, dynamic> json) {
    return B2BSupplier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      location: json['location'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isTrending: json['is_trending'] ?? false,
      yearsInBusiness: json['years_in_business'] ?? 0,
      sampleProductImages: json['sample_product_images'] != null 
          ? List<String>.from(json['sample_product_images'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'category': category,
      'rating': rating,
      'total_products': totalProducts,
      'total_reviews': totalReviews,
      'location': location,
      'is_verified': isVerified,
      'is_trending': isTrending,
      'years_in_business': yearsInBusiness,
      'sample_product_images': sampleProductImages,
    };
  }
}
