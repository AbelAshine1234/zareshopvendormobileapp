import '../models/b2b_supplier_model.dart';

class B2BSupplierFakeData {
  static final List<B2BSupplier> fakeSuppliers = _generateSuppliers();

  static List<B2BSupplier> _generateSuppliers() {
    final List<B2BSupplier> suppliers = [];
    
    // Generate 100+ Electronics suppliers
    final electronicsCompanies = [
      'Global Electronics', 'TechHub', 'Digital World', 'Smart Devices', 'ElectroMart',
      'Circuit Masters', 'PowerTech', 'Voltage Solutions', 'Electron Supply', 'Tech Wholesale',
      'Component Hub', 'Electronics Plus', 'Digital Supply', 'Tech Traders', 'ElectroSource',
      'Circuit City', 'Power Electronics', 'Tech Distributors', 'Digital Mart', 'Electronics World',
      'Component Supply', 'Tech Solutions', 'Digital Hub', 'ElectroTrade', 'Circuit Supply',
      'Power Devices', 'Tech Wholesale Co', 'Digital Traders', 'Electronics Hub', 'Component World',
      'Tech Mart', 'Digital Solutions', 'ElectroHub', 'Circuit Traders', 'Power Supply Co',
      'Tech World', 'Digital Wholesale', 'Electronics Traders', 'Component Hub Ltd', 'Tech Supply',
      'Digital Devices', 'ElectroMart Ltd', 'Circuit Hub', 'Power Traders', 'Tech Distributors Ltd',
      'Digital Supply Co', 'Electronics Solutions', 'Component Traders', 'Tech Hub Ltd', 'Digital World Ltd',
    ];
    
    // High-quality image URLs for suppliers
    final supplierImages = [
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=200',
      'https://images.unsplash.com/photo-1573164713988-8665fc963095?w=200',
      'https://images.unsplash.com/photo-1633409361618-c73427e4e206?w=200',
      'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=200',
      'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=200',
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=200',
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200',
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=200',
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=200',
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=200',
    ];
    
    // Electronics product sample images
    final electronicsProductImages = [
      'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=100', // Laptop
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100', // Phone
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100', // Headphones
      'https://images.unsplash.com/photo-1585790050230-5dd28404f32d?w=100', // Smart watch
      'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=100', // Tablet
      'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=100', // Monitor
      'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=100', // Keyboard
      'https://images.unsplash.com/photo-1527814050087-3793815479db?w=100', // Camera
      'https://images.unsplash.com/photo-1572635196184-84e35138cf62?w=100', // Mouse
      'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=100', // Speaker
    ];
    
    for (int i = 0; i < 100; i++) {
      // Get 3 random product images for each supplier
      final sampleImages = [
        electronicsProductImages[(i * 3) % electronicsProductImages.length],
        electronicsProductImages[(i * 3 + 1) % electronicsProductImages.length],
        electronicsProductImages[(i * 3 + 2) % electronicsProductImages.length],
      ];
      
      suppliers.add(B2BSupplier(
        id: 'elec_$i',
        name: '${electronicsCompanies[i % electronicsCompanies.length]} ${i > 49 ? "Ethiopia" : "Ltd"}',
        logo: supplierImages[i % supplierImages.length],
        category: 'Electronics',
        rating: 4.0 + (i % 10) * 0.1,
        totalProducts: 500 + (i * 50),
        totalReviews: 100 + (i * 5),
        location: i % 3 == 0 ? 'Addis Ababa, Ethiopia' : i % 3 == 1 ? 'Dire Dawa, Ethiopia' : 'Hawassa, Ethiopia',
        isVerified: true, // All verified
        isTrending: i % 5 == 0,
        yearsInBusiness: 5 + (i % 20),
        sampleProductImages: sampleImages,
      ));
    }
    
    // Other category suppliers
    suppliers.addAll([
      B2BSupplier(
        id: 'textile_1',
        name: 'Textile Masters Co',
        logo: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=200',
        category: 'Textiles & Fabrics',
        rating: 4.9,
        totalProducts: 3200,
        totalReviews: 450,
        location: 'Hawassa, Ethiopia',
        isVerified: true,
        isTrending: true,
        yearsInBusiness: 20,
      ),
      B2BSupplier(
        id: 'fashion_1',
        name: 'Fashion Hub Wholesale',
        logo: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200',
        category: 'Clothing & Apparel',
        rating: 4.7,
        totalProducts: 4500,
        totalReviews: 520,
        location: 'Addis Ababa, Ethiopia',
        isVerified: true,
        isTrending: true,
        yearsInBusiness: 12,
      ),
      B2BSupplier(
        id: 'building_1',
        name: 'BuildPro Materials',
        logo: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200',
        category: 'Building Materials',
        rating: 4.6,
        totalProducts: 1800,
        totalReviews: 280,
        location: 'Dire Dawa, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 18,
      ),
      B2BSupplier(
        id: 'agri_1',
        name: 'AgriSupply Ethiopia',
        logo: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=200',
        category: 'Agricultural Products',
        rating: 4.8,
        totalProducts: 2100,
        totalReviews: 310,
        location: 'Bahir Dar, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 10,
      ),
      B2BSupplier(
        id: 'machinery_1',
        name: 'Industrial Machinery Inc',
        logo: 'https://images.unsplash.com/photo-1565043666747-69f6646db940?w=200',
        category: 'Machinery',
        rating: 4.5,
        totalProducts: 950,
        totalReviews: 180,
        location: 'Addis Ababa, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 25,
      ),
      B2BSupplier(
        id: 'food_1',
        name: 'Food & Beverage Distributors',
        logo: 'https://images.unsplash.com/photo-1556740758-90de374c12ad?w=200',
        category: 'Food & Beverages',
        rating: 4.9,
        totalProducts: 5600,
        totalReviews: 680,
        location: 'Mekelle, Ethiopia',
        isVerified: true,
        isTrending: true,
        yearsInBusiness: 8,
      ),
      B2BSupplier(
        id: 'office_1',
        name: 'Office Solutions Pro',
        logo: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=200',
        category: 'Office Supplies',
        rating: 4.7,
        totalProducts: 3400,
        totalReviews: 420,
        location: 'Addis Ababa, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 14,
      ),
      B2BSupplier(
        id: 'apparel_1',
        name: 'Ethio Garments Export',
        logo: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=200',
        category: 'Clothing & Apparel',
        rating: 4.8,
        totalProducts: 5200,
        totalReviews: 590,
        location: 'Hawassa, Ethiopia',
        isVerified: true,
        isTrending: true,
        yearsInBusiness: 15,
      ),
      B2BSupplier(
        id: 'apparel_2',
        name: 'Fashion Forward Ltd',
        logo: 'https://images.unsplash.com/photo-1558769132-cb1aea3c8565?w=200',
        category: 'Clothing & Apparel',
        rating: 4.7,
        totalProducts: 4100,
        totalReviews: 480,
        location: 'Addis Ababa, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 10,
      ),
      B2BSupplier(
        id: 'textile_2',
        name: 'Ethiopian Textile Mills',
        logo: 'https://images.unsplash.com/photo-1604147706283-d7119b5b822c?w=200',
        category: 'Textiles & Fabrics',
        rating: 4.9,
        totalProducts: 2800,
        totalReviews: 390,
        location: 'Bahir Dar, Ethiopia',
        isVerified: true,
        isTrending: true,
        yearsInBusiness: 22,
      ),
      B2BSupplier(
        id: 'textile_3',
        name: 'Fabric Wholesale Hub',
        logo: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=200',
        category: 'Textiles & Fabrics',
        rating: 4.6,
        totalProducts: 1900,
        totalReviews: 250,
        location: 'Mekelle, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 9,
      ),
      B2BSupplier(
        id: 'footwear_1',
        name: 'Shoe Factory Ethiopia',
        logo: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=200',
        category: 'Footwear',
        rating: 4.7,
        totalProducts: 3500,
        totalReviews: 410,
        location: 'Addis Ababa, Ethiopia',
        isVerified: true,
        isTrending: false,
        yearsInBusiness: 11,
      ),
    ]);
    
    return suppliers;
  }
}
