import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String dashboard = '/';
  static const String orders = '/orders';
  static const String products = '/products';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String orderDetail = '/order/:id';
  static const String salesReport = '/sales-report';
}

/// Extension methods for easier navigation
extension NavigationExtensions on BuildContext {
  /// Navigate to order detail screen
  void goToOrderDetail({
    required String orderId,
    required String customerName,
    required String status,
  }) {
    go('/order/$orderId?customerName=$customerName&status=$status');
  }

  /// Navigate to sales report screen
  void goToSalesReport() {
    go('/sales-report');
  }

  /// Navigate to a main tab
  void goToTab(String route) {
    go(route);
  }
}
