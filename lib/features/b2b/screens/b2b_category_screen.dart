import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/b2b_supplier_model.dart';
import '../models/b2b_product_model.dart';
import '../data/b2b_supplier_fake_data.dart';
import '../data/b2b_fake_data.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/b2b_widgets.dart';
import 'b2b_product_detail_screen.dart';
import 'b2b_supplier_detail_screen.dart';

class B2BCategoryScreen extends StatefulWidget {
  final String categoryName;

  const B2BCategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<B2BCategoryScreen> createState() => _B2BCategoryScreenState();
}

class _B2BCategoryScreenState extends State<B2BCategoryScreen> with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String filterQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool _isLoadingSuppliers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_isLoadingSuppliers) {
      // Switching to suppliers tab
      _preloadSupplierImages();
    }
  }

  Future<void> _preloadSupplierImages() async {
    setState(() {
      _isLoadingSuppliers = true;
    });

    try {
      final suppliers = _getFilteredSuppliers().take(10).toList();
      final imagePreloadFutures = <Future>[];

      for (var supplier in suppliers) {
        if (supplier.logo.isNotEmpty) {
          imagePreloadFutures.add(
            precacheImage(
              NetworkImage(supplier.logo),
              context,
            ).catchError((_) => null),
          );
        }
      }

      await Future.wait(imagePreloadFutures).timeout(
        const Duration(seconds: 2),
        onTimeout: () => [],
      );

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isLoadingSuppliers = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _filterController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<B2BSupplier> _getFilteredSuppliers() {
    var suppliers = B2BSupplierFakeData.fakeSuppliers
        .where((s) => s.category == widget.categoryName)
        .toList();
    
    // Use filterQuery for suppliers tab, searchQuery for products tab
    final query = _tabController.index == 1 ? filterQuery : searchQuery;
    
    if (query.isNotEmpty) {
      suppliers = suppliers.where((s) => 
        s.name.toLowerCase().contains(query.toLowerCase()) ||
        s.location.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    return suppliers;
  }

  List<B2BProduct> _getFilteredProducts() {
    var products = B2BFakeData.fakeProducts
        .where((p) => p.category == widget.categoryName)
        .toList();
    
    if (searchQuery.isNotEmpty) {
      products = products.where((p) => 
        p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.vendorName.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    return products;
  }

  void _handleSupplierTap(B2BSupplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => B2BSupplierDetailScreen(supplier: supplier),
      ),
    );
  }

  void _handleProductTap(B2BProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => B2BProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.surface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: theme.surface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Header
            B2BSearchHeader(
              theme: theme,
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => searchQuery = value),
            ),
            
            // 2. Tabs
            _buildTabBar(theme),
            
            // 3. Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Products Tab
                  _buildProductsTab(theme),
                  // Suppliers Tab
                  _buildSuppliersTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AppThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.divider, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.primary,
        indicatorWeight: 3,
        labelColor: theme.primary,
        unselectedLabelColor: theme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'Suppliers'),
        ],
      ),
    );
  }

  Widget _buildProductsTab(AppThemeData theme) {
    final products = _getFilteredProducts();
    final suppliers = _getFilteredSuppliers();
    
    return CustomScrollView(
      slivers: [
        // Top Ranking Suppliers
        if (suppliers.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                B2BTopSuppliersSection(
                  title: 'Top Suppliers',
                  suppliers: suppliers.take(6).toList(),
                  theme: theme,
                  onSupplierTap: _handleSupplierTap,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        
        // Products Grid
        if (products.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyState(theme, 'No products found'),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return _buildProductCard(product, theme);
                },
                childCount: products.length,
              ),
            ),
          ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildSuppliersTab(AppThemeData theme) {
    // Show loading while images are being preloaded
    if (_isLoadingSuppliers) {
      return ZareshopLoadingWidget(
        key: const ValueKey('suppliers_loading'),
        theme: theme,
        size: 150,
        showBackground: false,
      );
    }

    final suppliers = _getFilteredSuppliers();
    final displaySuppliers = suppliers.take(50).toList(); // Limit for performance
    
    return CustomScrollView(
      slivers: [
        // Top Ranking Suppliers
        if (suppliers.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                B2BTopSuppliersSection(
                  title: 'Top Suppliers',
                  suppliers: suppliers.take(6).toList(),
                  theme: theme,
                  onSupplierTap: _handleSupplierTap,
                ),
                const SizedBox(height: 12),
                // Filter Chips Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Filter by text
                      Expanded(
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: filterQuery.isNotEmpty 
                                  ? theme.primary 
                                  : theme.divider,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 16,
                                color: filterQuery.isNotEmpty 
                                    ? theme.primary 
                                    : theme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _filterController,
                                  onChanged: (value) => setState(() => filterQuery = value),
                                  decoration: InputDecoration(
                                    hintText: 'Filter suppliers...',
                                    hintStyle: TextStyle(
                                      color: theme.textHint,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (filterQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _filterController.clear();
                                    setState(() => filterQuery = '');
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: theme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort button
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sort,
                              size: 16,
                              color: theme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        
        // Suppliers List
        if (suppliers.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyState(theme, 'No suppliers found'),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final supplier = displaySuppliers[index];
                  return _buildSupplierListItem(supplier, theme);
                },
                childCount: displaySuppliers.length,
              ),
            ),
          ),
        
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }


  Widget _buildProductCard(B2BProduct product, AppThemeData theme) {
    return GestureDetector(
      onTap: () => _handleProductTap(product),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (55% of card)
            Expanded(
              flex: 55,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.inputBackground,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.inputBackground,
                    child: Icon(
                      Icons.image,
                      size: 25,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ETB ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.minOrderQuantity} ${product.unit} (Bulk)',
                    style: TextStyle(
                      fontSize: 8,
                      color: theme.textSecondary,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSupplierListItem(B2BSupplier supplier, AppThemeData theme) {
    return GestureDetector(
      onTap: () => _handleSupplierTap(supplier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.divider, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.divider, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: supplier.logo,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.business,
                    size: 30,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Supplier Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supplier.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (supplier.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, size: 10, color: Colors.white),
                              SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${supplier.rating}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.inventory_2, size: 12, color: theme.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        '${supplier.totalProducts} products',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: theme.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        supplier.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${supplier.yearsInBusiness} yrs',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Sample Product Images Row
                  Row(
                    children: [
                      ...List.generate(
                        3,
                        (index) {
                          // Use actual sample images if available, otherwise show placeholder
                          final hasImages = supplier.sampleProductImages.isNotEmpty;
                          final imageUrl = hasImages && index < supplier.sampleProductImages.length
                              ? supplier.sampleProductImages[index]
                              : '';
                          
                          return Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.divider, width: 0.5),
                              color: theme.inputBackground,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: theme.inputBackground,
                                        child: Icon(
                                          Icons.image,
                                          size: 20,
                                          color: theme.textSecondary.withOpacity(0.3),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: theme.inputBackground,
                                        child: Icon(
                                          Icons.image,
                                          size: 20,
                                          color: theme.textSecondary.withOpacity(0.5),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: 20,
                                      color: theme.textSecondary.withOpacity(0.3),
                                    ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Message Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.message, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Message',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
