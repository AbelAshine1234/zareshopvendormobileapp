import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../data/models/b2b_product_model.dart';
import '../../../data/fake_data/b2b_fake_data.dart';
import 'b2b_product_detail_screen.dart';

class B2BMarketScreen extends StatefulWidget {
  const B2BMarketScreen({super.key});

  @override
  State<B2BMarketScreen> createState() => _B2BMarketScreenState();
}

class _B2BMarketScreenState extends State<B2BMarketScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Consumer<LocalizationService>(
              builder: (context, localization, child) {
                return Text(
                  localization.translate('navigation.b2bMarket'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () => _showSearchDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black87),
                onPressed: () => _showFilterDialog(),
              ),
              Consumer<CartService>(
                builder: (context, cartService, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.black87),
                        onPressed: () => _showCart(),
                      ),
                      if (cartService.itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartService.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildCategoryFilter(),
                const SizedBox(height: 20),
                _buildStatsCards(),
                const SizedBox(height: 20),
                _buildFeaturedProducts(),
                const SizedBox(height: 20),
                _buildProductGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localization.translate('b2b.searchHint'),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final categories = B2BFakeData.categories;
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          // Translate category names
          String displayCategory = category;
          switch (category) {
            case 'All':
              displayCategory = localization.translate('b2b.categories.all');
              break;
            case 'Electronics':
              displayCategory = localization.translate('b2b.categories.electronics');
              break;
            case 'Food & Beverages':
              displayCategory = localization.translate('b2b.categories.foodBeverages');
              break;
            case 'Clothing & Textiles':
              displayCategory = localization.translate('b2b.categories.clothingTextiles');
              break;
          }
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: Text(
                displayCategory,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            localization.translate('b2b.stats.totalProducts'),
            '${B2BFakeData.fakeProducts.length}',
            Icons.inventory_2,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            localization.translate('b2b.stats.activeVendors'),
            '${B2BFakeData.fakeVendors.length}',
            Icons.store,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            localization.translate('b2b.stats.categories'),
            '${B2BFakeData.categories.length - 1}',
            Icons.category,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final featuredProducts = B2BFakeData.fakeProducts.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localization.translate('b2b.sections.featuredProducts'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                localization.translate('b2b.sections.viewAll'),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return _buildFeaturedProductCard(product);
            },
          ),
        ),
      ],
    );
  }
Widget _buildFeaturedProductCard(B2BProduct product) {
  return GestureDetector(
    onTap: () => _navigateToProductDetail(product),
    child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'ETB ${product.finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        'ETB ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviewCount})',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'B2B',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.vendorName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
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


  Widget _buildProductGrid() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    final filteredProducts = _getFilteredProducts();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localization.translate('b2b.sections.allProducts').replaceAll('{count}', '${filteredProducts.length}'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: Colors.grey),
              onSelected: (value) {
                // Handle sorting
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'name', child: Text(localization.translate('b2b.sort.byName'))),
                PopupMenuItem(value: 'price', child: Text(localization.translate('b2b.sort.byPrice'))),
                PopupMenuItem(value: 'rating', child: Text(localization.translate('b2b.sort.byRating'))),
                PopupMenuItem(value: 'newest', child: Text(localization.translate('b2b.sort.byNewest'))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(B2BProduct product) {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'ETB ${product.finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.isInStock 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.isInStock 
                              ? localization.translate('b2b.product.inStock')
                              : localization.translate('b2b.product.outOfStock'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: product.isInStock ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.vendorName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
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

  List<B2BProduct> _getFilteredProducts() {
    var products = B2BFakeData.fakeProducts;
    
    // Filter by category
    if (selectedCategory != 'All') {
      products = products.where((p) => p.category == selectedCategory).toList();
    }
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      products = products.where((p) => 
        p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.vendorName.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    return products;
  }

  void _showSearchDialog() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('b2b.search.title')),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: localization.translate('b2b.search.hint'),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(localization.translate('common.search')),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('b2b.filter.title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localization.translate('b2b.filter.category')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: B2BFakeData.categories.map((category) {
                String displayCategory = category;
                switch (category) {
                  case 'All':
                    displayCategory = localization.translate('b2b.categories.all');
                    break;
                  case 'Electronics':
                    displayCategory = localization.translate('b2b.categories.electronics');
                    break;
                  case 'Food & Beverages':
                    displayCategory = localization.translate('b2b.categories.foodBeverages');
                    break;
                  case 'Clothing & Textiles':
                    displayCategory = localization.translate('b2b.categories.clothingTextiles');
                    break;
                }
                return DropdownMenuItem(
                  value: category,
                  child: Text(displayCategory),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(localization.translate('b2b.filter.apply')),
          ),
        ],
      ),
    );
  }

  void _navigateToProductDetail(B2BProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => B2BProductDetailScreen(product: product),
      ),
    );
  }

  void _showCart() {
    final cartService = Provider.of<CartService>(context, listen: false);
    final localization = Provider.of<LocalizationService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Shopping Cart',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${cartService.itemCount} items',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cartService.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: cartService.items.length,
                        itemBuilder: (context, index) {
                          final item = cartService.items[index];
                          return ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: item.product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'ETB ${item.product.finalPrice.toStringAsFixed(0)} × ${item.quantity}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    cartService.updateItemQuantity(
                                      item.product.id,
                                      item.quantity - 1,
                                    );
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cartService.updateItemQuantity(
                                      item.product.id,
                                      item.quantity + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (cartService.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ETB ${cartService.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Navigate to checkout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}