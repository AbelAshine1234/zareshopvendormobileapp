class AppConstants {
  // App Info
  static const String appName = 'Zareshop Vendor';
  static const String appVersion = '1.0.0';

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'am', 'name': 'አማርኛ (Amharic)'},
    {'code': 'om', 'name': 'Afaan Oromoo'},
    {'code': 'ti', 'name': 'ትግርኛ (Tigrigna)'},
  ];

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusProcessing = 'processing';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCanceled = 'canceled';

  // Time Periods
  static const String periodDaily = 'daily';
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';

  // Placeholder Images
  static const String placeholderProduct = 'https://via.placeholder.com/150';
  static const String placeholderProfile = 'https://via.placeholder.com/100';
  static const String placeholderBanner = 'https://via.placeholder.com/400x150';
}
