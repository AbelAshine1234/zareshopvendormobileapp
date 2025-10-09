import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double dailySales;
  final double weeklySales;
  final double monthlySales;
  final int pendingOrders;
  final int fulfilledOrders;
  final int canceledOrders;
  final int totalProducts;
  final int lowStockProducts;
  final List<SalesDataPoint> salesChart;

  const DashboardStats({
    required this.dailySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.pendingOrders,
    required this.fulfilledOrders,
    required this.canceledOrders,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.salesChart,
  });

  @override
  List<Object?> get props => [
        dailySales,
        weeklySales,
        monthlySales,
        pendingOrders,
        fulfilledOrders,
        canceledOrders,
        totalProducts,
        lowStockProducts,
        salesChart,
      ];
}

class SalesDataPoint extends Equatable {
  final String label;
  final double value;

  const SalesDataPoint({
    required this.label,
    required this.value,
  });

  @override
  List<Object?> get props => [label, value];
}
