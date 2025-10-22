import 'package:equatable/equatable.dart';
import '../../features/onboarding/widgets/category_selection_widget.dart';

/// States for global app data management
abstract class AppDataState extends Equatable {
  const AppDataState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AppDataInitial extends AppDataState {
  const AppDataInitial();
}

/// Loading state
class AppDataLoading extends AppDataState {
  const AppDataLoading();
}

/// Categories loaded successfully
class CategoriesLoaded extends AppDataState {
  final List<CategoryModel> categories;
  final bool isFromCache;

  const CategoriesLoaded({
    required this.categories,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [categories, isFromCache];
}

/// Subscriptions loaded successfully
class SubscriptionsLoaded extends AppDataState {
  final List<Map<String, dynamic>> subscriptions;
  final bool isFromCache;

  const SubscriptionsLoaded({
    required this.subscriptions,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [subscriptions, isFromCache];
}

/// All app data loaded successfully
class AllAppDataLoaded extends AppDataState {
  final List<CategoryModel> categories;
  final List<Map<String, dynamic>> subscriptions;
  final bool isFromCache;

  const AllAppDataLoaded({
    required this.categories,
    required this.subscriptions,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [categories, subscriptions, isFromCache];
}

/// General error state
class AppDataError extends AppDataState {
  final String message;
  final String? errorType;

  const AppDataError({
    required this.message,
    this.errorType,
  });

  @override
  List<Object?> get props => [message, errorType];
}

/// Categories error
class CategoriesError extends AppDataState {
  final String message;
  final List<CategoryModel> fallbackCategories;

  const CategoriesError({
    required this.message,
    required this.fallbackCategories,
  });

  @override
  List<Object?> get props => [message, fallbackCategories];
}

/// Subscriptions error
class SubscriptionsError extends AppDataState {
  final String message;
  final List<Map<String, dynamic>> fallbackSubscriptions;

  const SubscriptionsError({
    required this.message,
    required this.fallbackSubscriptions,
  });

  @override
  List<Object?> get props => [message, fallbackSubscriptions];
}
