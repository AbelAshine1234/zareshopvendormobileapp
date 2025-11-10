import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../supplier_model.dart';
import '../../../shared/utils/theme/app_themes.dart';

class B2BTopSuppliersSection extends StatefulWidget {
  final String title;
  final List<B2BSupplier> suppliers;
  final AppThemeData theme;
  final Function(B2BSupplier) onSupplierTap;

  const B2BTopSuppliersSection({
    super.key,
    required this.title,
    required this.suppliers,
    required this.theme,
    required this.onSupplierTap,
  });

  @override
  State<B2BTopSuppliersSection> createState() => _B2BTopSuppliersSectionState();
}

class _B2BTopSuppliersSectionState extends State<B2BTopSuppliersSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: widget.theme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.offset + 142,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: widget.theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = widget.suppliers[index];
                  return _buildSupplierCard(supplier);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(B2BSupplier supplier) {
    return GestureDetector(
      onTap: () => widget.onSupplierTap(supplier),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: widget.theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.theme.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Section
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.theme.inputBackground,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: supplier.logo,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: widget.theme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.business,
                            size: 30,
                            color: widget.theme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Verified Badge
                if (supplier.isVerified)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Trending Badge
                if (supplier.isTrending)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            'HOT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        supplier.rating.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${supplier.totalProducts})',
                        style: TextStyle(
                          fontSize: 9,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supplier.category,
                    style: TextStyle(
                      fontSize: 9,
                      color: widget.theme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
