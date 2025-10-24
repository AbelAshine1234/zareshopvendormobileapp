import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/utils/theme/theme_provider.dart';
import '../../shared/utils/theme/app_themes.dart';
import '../../core/services/localization_service.dart';
import 'supplier_model.dart';
import '../b2b/data/b2b_supplier_fake_data.dart';
import '../b2b/screens/b2b_supplier_detail_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedFilter = 'All'; // All, Top Rated, Most Products

  final List<String> _categories = [
    'All',
    'Electronics',
    'Textiles & Fabrics',
    'Clothing & Apparel',
    'Building Materials',
    'Agricultural Products',
    'Machinery',
    'Food & Beverages',
    'Office Supplies',
    'Footwear',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredSuppliers {
    var suppliers = B2BSupplierFakeData.fakeSuppliers;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      suppliers = suppliers.where((supplier) {
        final name = supplier.name.toLowerCase();
        final category = supplier.category.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }
    
    // Filter by category
    if (_selectedCategory != 'All') {
      suppliers = suppliers.where((supplier) {
        return supplier.category == _selectedCategory;
      }).toList();
    }
    
    
    // Apply sorting based on filter
    if (_selectedFilter == 'Top Rated') {
      suppliers.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == 'Most Products') {
      suppliers.sort((a, b) => b.totalProducts.compareTo(a.totalProducts));
    }
    
    return suppliers;
  }

  List<dynamic> get _topRankedSuppliers {
    var suppliers = List.from(B2BSupplierFakeData.fakeSuppliers);
    suppliers.sort((a, b) => b.rating.compareTo(a.rating));
    return suppliers.take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'Suppliers',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildLanguageSelector(theme),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                hintStyle: TextStyle(color: theme.textHint),
                prefixIcon: Icon(Icons.search, color: theme.textSecondary),
                filled: true,
                fillColor: theme.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.inputBorder, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.inputBorder, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            color: theme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: theme.inputBackground,
                    selectedColor: theme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primary : theme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? theme.primary : theme.divider,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Sort:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Top Rated', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Most Products', theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Ranked Sellers Section
          if (_selectedCategory == 'All' && _searchQuery.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Top Ranked Sellers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topRankedSuppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = _topRankedSuppliers[index];
                        return _buildTopRankedCard(supplier, theme, index + 1);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          // Suppliers Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredSuppliers.length} suppliers found',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Suppliers List
          Expanded(
            child: _filteredSuppliers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No suppliers found',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _filteredSuppliers[index];
                      return _buildSupplierCard(supplier, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(dynamic supplier, AppThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => B2BSupplierDetailScreen(supplier: supplier),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            // Supplier Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  supplier.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Supplier Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${supplier.rating} (${supplier.totalReviews} reviews)',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${supplier.totalProducts} products',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AppThemeData theme) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : theme.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTopRankedCard(dynamic supplier, AppThemeData theme, int rank) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => B2BSupplierDetailScreen(supplier: supplier),
          ),
        );
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Image with Rank Badge
            Stack(
              children: [
                // Circular Image
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primary.withOpacity(0.1),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: supplier.logo,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primary,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          supplier.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Rank Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey[400] : rank == 3 ? Colors.brown[300] : theme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.surface, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Supplier Name
            Text(
              supplier.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 9, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '${supplier.rating}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppThemeData theme) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.language_outlined, color: theme.textPrimary, size: 22),
              onPressed: () {
                final RenderBox button = context.findRenderObject() as RenderBox;
                _showLanguageMenu(context, themeProvider, button);
              },
            );
          },
        );
      },
    );
  }

  void _showLanguageMenu(BuildContext context, ThemeProvider themeProvider, RenderBox button) {
    final currentLanguage = LocalizationService.instance.currentLanguage;
    final buttonPosition = button.localToGlobal(Offset.zero);
    final buttonSize = button.size;
    
    // Map language codes to display text in native script
    String getLanguageDisplay(String code) {
      switch (code) {
        case 'en':
          return 'English';
        case 'am':
          return 'አማርኛ';  // Amharic in Amharic script
        case 'or':
          return 'Afaan Oromoo';  // Oromo in Latin script
        default:
          return code.toUpperCase();
      }
    }
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height,
        buttonPosition.dx + 200,
        buttonPosition.dy,
      ),
      items: LocalizationService.instance.supportedLanguages.map((lang) {
        final isSelected = lang['code'] == currentLanguage;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(
            children: [
              Text(
                getLanguageDisplay(lang['code']!),
                style: TextStyle(
                  color: isSelected ? themeProvider.currentTheme.primary : themeProvider.currentTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: themeProvider.currentTheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedCode) {
      if (selectedCode != null) {
        LocalizationService.instance.loadLanguage(selectedCode);
      }
    });
  }
}
