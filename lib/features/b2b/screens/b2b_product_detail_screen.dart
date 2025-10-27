import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../data/models/b2b_product_model.dart';

class B2BProductDetailScreen extends StatefulWidget {
  final B2BProduct product;

  const B2BProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<B2BProductDetailScreen> createState() => _B2BProductDetailScreenState();
}

class _B2BProductDetailScreenState extends State<B2BProductDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        return Scaffold(
          backgroundColor: theme.background,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildProductImages(),
                _buildProductInfo(),
                _buildVendorInfo(),
                _buildDescription(),
                _buildSpecifications(),
                _buildWholesaleInfo(),
                _buildActionButtons(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black87,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: _shareProduct,
          ),
        ),
      ],
    );
  }

  Widget _buildProductImages() {
    return SliverToBoxAdapter(
      child: Container(
        height: 350,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: widget.product.imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.product.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.imageUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.product.hasDiscount)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-${widget.product.discountPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.product.isInStock ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product.isInStock
                      ? Provider.of<LocalizationService>(context, listen: false)
                          .translate('b2b.product.inStock')
                      : Provider.of<LocalizationService>(context, listen: false)
                          .translate('b2b.product.outOfStock'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.product.rating} (${widget.product.reviewCount} ${localization.translate('b2b.product.reviews')})',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'ETB ${widget.product.finalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (widget.product.hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    'ETB ${widget.product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${localization.translate('b2b.product.stock')}: ${widget.product.stock} ${widget.product.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${localization.translate('b2b.product.minOrder')}: ${widget.product.minOrderQuantity} ${widget.product.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(widget.product.vendorImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.product.vendorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localization.translate('b2b.product.verifiedVendor'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _contactVendor,
              child: Text(localization.translate('b2b.product.contactVendor')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('b2b.product.description'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecifications() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('b2b.product.specifications'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.product.specifications.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWholesaleInfo() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    if (!widget.product.isWholesale) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  localization.translate('b2b.product.wholesaleAvailable'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('b2b.product.wholesalePrice'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETB ${widget.product.wholesalePrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('b2b.product.wholesaleMin'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.product.wholesaleMinQuantity} ${widget.product.unit}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
    );
  }

  Widget _buildActionButtons() {
    final localization = Provider.of<LocalizationService>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Quantity Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    localization.translate('b2b.product.selectQuantity'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? _decreaseQuantity : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: _quantity > 1 ? Colors.blue : Colors.grey[300],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _quantity < widget.product.stock ? _increaseQuantity : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: _quantity < widget.product.stock ? Colors.blue : Colors.grey[300],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${localization.translate('b2b.product.totalPrice')}: ETB ${(_quantity * widget.product.finalPrice).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _contactVendor,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localization.translate('b2b.product.contactForQuote'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: widget.product.isInStock ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.product.isInStock ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            localization.translate('b2b.product.addToCart'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Show snackbar
    final localization = Provider.of<LocalizationService>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
              ? localization.translate('b2b.product.favorite')
              : localization.translate('b2b.product.removeFavorite'),
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct() {
    // Simple share implementation without external dependency
    Clipboard.setData(ClipboardData(
      text: 'Check out this product: ${widget.product.name}\nPrice: ETB ${widget.product.finalPrice}\nVendor: ${widget.product.vendorName}',
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product details copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _contactVendor() {
    // TODO: Implement contact vendor functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact vendor functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _increaseQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() {
        _quantity++;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _addToCart() async {
    if (!widget.product.isInStock) return;
    
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Add to cart using CartService
    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.addItem(widget.product, _quantity);

    setState(() {
      _isLoading = false;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show success message
    final localization = Provider.of<LocalizationService>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${localization.translate('b2b.product.cartAdded')} ($_quantity ${widget.product.unit})',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navigate to cart
          },
        ),
      ),
    );
  }
}
