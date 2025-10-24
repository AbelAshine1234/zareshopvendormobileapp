import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/b2b_supplier_model.dart';
import '../models/b2b_product_model.dart';
import '../data/b2b_fake_data.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../suppliers/widgets/supplier_header.dart';
import '../../suppliers/widgets/supplier_home_tab.dart';
import '../../suppliers/widgets/supplier_products_tab.dart';
import '../../suppliers/widgets/supplier_profile_tab.dart';

class B2BSupplierDetailScreen extends StatefulWidget {
  final B2BSupplier supplier;

  const B2BSupplierDetailScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<B2BSupplierDetailScreen> createState() => _B2BSupplierDetailScreenState();
}

class _B2BSupplierDetailScreenState extends State<B2BSupplierDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<B2BProduct> _getSupplierProducts() {
    return B2BFakeData.fakeProducts
        .where((p) => p.category == widget.supplier.category)
        .take(50)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final products = _getSupplierProducts();
    
    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Company Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SupplierHeader(
                supplier: widget.supplier,
                theme: theme,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: theme.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.primary,
                  unselectedLabelColor: theme.textSecondary,
                  indicatorColor: theme.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'Products'),
                    Tab(text: 'Company Profile'),
                  ],
                ),
              ),
            ),
          ),
          
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                SupplierHomeTab(
                  supplier: widget.supplier,
                  theme: theme,
                ),
                SupplierProductsTab(
                  products: products,
                  theme: theme,
                ),
                SupplierProfileTab(
                  supplier: widget.supplier,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBottomBar(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to messages screen with supplier info
            context.go('/messages');
            
            // Show snackbar to indicate message screen opened for this supplier
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening chat with ${widget.supplier.name}'),
                duration: const Duration(seconds: 2),
                backgroundColor: theme.primary,
              ),
            );
          },
          icon: const Icon(Icons.message),
          label: const Text('Contact Supplier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
