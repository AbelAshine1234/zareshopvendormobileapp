import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/categories_service.dart';
import '../services/api_service.dart';
import '../../features/onboarding/widgets/category_selection_widget.dart';
import 'app_data_event.dart';
import 'app_data_state.dart';

/// Global app data bloc for managing shared data across features
class AppDataBloc extends Bloc<AppDataEvent, AppDataState> {
  AppDataBloc() : super(const AppDataInitial()) {
    on<FetchCategories>(_onFetchCategories);
    on<FetchSubscriptions>(_onFetchSubscriptions);
    on<FetchAllAppData>(_onFetchAllAppData);
    on<RefreshCategories>(_onRefreshCategories);
    on<RefreshSubscriptions>(_onRefreshSubscriptions);
    on<ClearAppDataCache>(_onClearAppDataCache);
  }

  /// Fetch categories
  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      emit(const AppDataLoading());
      
      final categories = await CategoriesService.getCategories();
      
      emit(CategoriesLoaded(
        categories: categories,
        isFromCache: false,
      ));
    } catch (e) {
      _logError('Failed to fetch categories: $e');
      
      emit(CategoriesError(
        message: 'Failed to load categories. Please try again.',
        fallbackCategories: [],
      ));
    }
  }

  /// Fetch subscriptions
  Future<void> _onFetchSubscriptions(
    FetchSubscriptions event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      emit(const AppDataLoading());
      
      final result = await ApiService.fetchSubscriptions();
      
      if (result['success'] == true) {
        final subscriptionsData = result['subscriptions'] as List<dynamic>;
        final subscriptions = subscriptionsData.map((sub) {
          return {
            'id': sub['id'],
            'name': sub['name'],
            'price': sub['price'],
            'duration': sub['duration'],
            'features': sub['features'] ?? [],
          };
        }).toList();
        
        emit(SubscriptionsLoaded(
          subscriptions: subscriptions,
          isFromCache: false,
        ));
      } else {
        throw Exception('Failed to fetch subscriptions: ${result['error']}');
      }
    } catch (e) {
      _logError('Failed to fetch subscriptions: $e');
      
      emit(SubscriptionsError(
        message: 'Failed to load subscriptions. Using default plan.',
        fallbackSubscriptions: _getFallbackSubscriptions(),
      ));
    }
  }

  /// Fetch both categories and subscriptions
  Future<void> _onFetchAllAppData(
    FetchAllAppData event,
    Emitter<AppDataState> emit,
  ) async {
    try {
      emit(const AppDataLoading());
      
      // Fetch both in parallel
      final futures = await Future.wait([
        CategoriesService.getCategories(),
        _fetchSubscriptionsData(),
      ]);
      
      final categories = futures[0] as List<CategoryModel>;
      final subscriptions = futures[1] as List<Map<String, dynamic>>;
      
      emit(AllAppDataLoaded(
        categories: categories,
        subscriptions: subscriptions,
        isFromCache: false,
      ));
    } catch (e) {
      _logError('Failed to fetch all app data: $e');
      
      emit(AppDataError(
        message: 'Failed to load app data. Please try again.',
        errorType: 'network_error',
      ));
    }
  }

  /// Refresh categories
  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<AppDataState> emit,
  ) async {
    CategoriesService.clearCache();
    add(const FetchCategories());
  }

  /// Refresh subscriptions
  Future<void> _onRefreshSubscriptions(
    RefreshSubscriptions event,
    Emitter<AppDataState> emit,
  ) async {
    add(const FetchSubscriptions());
  }

  /// Clear cache
  void _onClearAppDataCache(
    ClearAppDataCache event,
    Emitter<AppDataState> emit,
  ) {
    CategoriesService.clearCache();
    emit(const AppDataInitial());
  }

  /// Helper method to fetch subscriptions data
  Future<List<Map<String, dynamic>>> _fetchSubscriptionsData() async {
    final result = await ApiService.fetchSubscriptions();
    
    if (result['success'] == true) {
      final subscriptionsData = result['subscriptions'] as List<dynamic>;
      return subscriptionsData.map((sub) {
        return {
          'id': sub['id'],
          'name': sub['name'],
          'price': sub['price'],
          'duration': sub['duration'],
          'features': sub['features'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch subscriptions: ${result['error']}');
    }
  }


  /// Get fallback subscriptions
  List<Map<String, dynamic>> _getFallbackSubscriptions() {
    return [
      {
        'id': 1,
        'name': 'Basic Plan',
        'price': 99.99,
        'duration': 'monthly',
        'features': ['Up to 100 products', 'Basic analytics', 'Email support'],
      },
    ];
  }

  /// Log error
  void _logError(String message) {
    print('❌ AppDataBloc Error: $message');
  }
}
