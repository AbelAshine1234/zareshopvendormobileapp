import '../services/api_service.dart';
import '../../features/onboarding/widgets/category_selection_widget.dart';

/// Service for managing categories
class CategoriesService {
  static List<CategoryModel> _cachedCategories = [];
  static DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Get categories from API or cache
  static Future<List<CategoryModel>> getCategories() async {
    // Use cache if still fresh
    if (_isCacheFresh) return _cachedCategories;

    try {
      final result = await ApiService.fetchCategories();
      final success = result['success'] == true;
      final raw = result['categories'];

      if (success && raw is List) {
        _cachedCategories = raw
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .where((c) => c.status)
            .toList(growable: false);
      } else {
        _cachedCategories = const <CategoryModel>[];
      }
    } catch (_) {
      _cachedCategories = const <CategoryModel>[];
    } finally {
      _lastFetchTime = DateTime.now();
    }

    return _cachedCategories;
  }


  /// Clear cache (useful for testing or when categories are updated)
  static void clearCache() {
    _cachedCategories.clear();
    _lastFetchTime = null;
  }

  /// Get category by ID
  static CategoryModel? getCategoryById(int id) {
    for (final c in _cachedCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Get categories by IDs
  static List<CategoryModel> getCategoriesByIds(List<int> ids) {
    if (ids.isEmpty || _cachedCategories.isEmpty) return const <CategoryModel>[];
    final idSet = ids.toSet();
    return _cachedCategories.where((c) => idSet.contains(c.id)).toList(growable: false);
  }

  static bool get _isCacheFresh {
    if (_cachedCategories.isEmpty || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheExpiry;
  }
}
