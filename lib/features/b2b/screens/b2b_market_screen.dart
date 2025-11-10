import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/b2b_supplier_model.dart';
import '../data/b2b_supplier_fake_data.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../../shared/utils/theme/app_themes.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/b2b_widgets.dart';
import '../data/b2b_categories_data.dart';
import 'b2b_category_screen.dart';

class B2BMarketScreen extends StatefulWidget {
  const B2BMarketScreen({super.key});

  @override
  State<B2BMarketScreen> createState() => _B2BMarketScreenState();
}

class _B2BMarketScreenState extends State<B2BMarketScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Preload supplier and category data
      final suppliers = B2BSupplierFakeData.fakeSuppliers;
      final categories = B2BCategoriesData.categories;
      
      // Precache top supplier images (first 5 suppliers)
      final topSuppliers = suppliers.take(5).toList();
      final imagePreloadFutures = <Future>[];
      
      for (var supplier in topSuppliers) {
        if (supplier.logo.isNotEmpty) {
          imagePreloadFutures.add(
            precacheImage(
              NetworkImage(supplier.logo),
              context,
            ).catchError((_) => null), // Ignore errors for individual images
          );
        }
      }
      
      // Precache category images
      for (var category in categories) {
        if (category['image'] != null && category['image'].isNotEmpty) {
          imagePreloadFutures.add(
            precacheImage(
              NetworkImage(category['image']),
              context,
            ).catchError((_) => null), // Ignore errors for individual images
          );
        }
      }
      
      // Wait for all images to load (with timeout)
      await Future.wait(imagePreloadFutures).timeout(
        const Duration(seconds: 3),
        onTimeout: () => [], // Continue after 3 seconds even if images aren't loaded
      );
      
      // Minimum display time
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      // If any error occurs, just continue
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSupplierTap(B2BSupplier supplier) {
    // Navigate to supplier detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${supplier.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleCategoryTap(Map<String, dynamic> category) {
    // Navigate to category screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => B2BCategoryScreen(
          categoryName: category['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    // Show loading widget while data is loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.background,
        body: ZareshopLoadingWidget(
          key: const ValueKey('b2b_loading'),
          theme: theme,
          size: 200,
          showBackground: true,
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Header
            B2BSearchHeader(
              theme: theme,
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => searchQuery = value),
            ),
            
            // 2. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // 3. Top Ranking Suppliers
                    B2BTopSuppliersSection(
                      title: 'Top Ranking Suppliers',
                      suppliers: B2BSupplierFakeData.fakeSuppliers,
                      theme: theme,
                      onSupplierTap: _handleSupplierTap,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 4. Categories Grid
                    B2BCategoriesGrid(
                      categories: B2BCategoriesData.categories,
                      theme: theme,
                      onCategoryTap: _handleCategoryTap,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
