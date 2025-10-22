import 'package:equatable/equatable.dart';

/// Events for global app data management
abstract class AppDataEvent extends Equatable {
  const AppDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch categories
class FetchCategories extends AppDataEvent {
  const FetchCategories();
}

/// Event to fetch subscriptions
class FetchSubscriptions extends AppDataEvent {
  const FetchSubscriptions();
}

/// Event to fetch both categories and subscriptions
class FetchAllAppData extends AppDataEvent {
  const FetchAllAppData();
}

/// Event to refresh categories
class RefreshCategories extends AppDataEvent {
  const RefreshCategories();
}

/// Event to refresh subscriptions
class RefreshSubscriptions extends AppDataEvent {
  const RefreshSubscriptions();
}

/// Event to clear cache
class ClearAppDataCache extends AppDataEvent {
  const ClearAppDataCache();
}
