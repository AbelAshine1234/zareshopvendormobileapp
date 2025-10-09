import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dashboard_stats.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<ChangeSalesPeriod>(_onChangeSalesPeriod);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      final stats = _getMockDashboardStats();
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final stats = _getMockDashboardStats();
      if (state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(stats: stats));
      } else {
        emit(DashboardLoaded(stats: stats));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void _onChangeSalesPeriod(
    ChangeSalesPeriod event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(selectedPeriod: event.period));
    }
  }

  DashboardStats _getMockDashboardStats() {
    return const DashboardStats(
      dailySales: 12500.00,
      weeklySales: 78900.00,
      monthlySales: 325000.00,
      pendingOrders: 15,
      fulfilledOrders: 234,
      canceledOrders: 8,
      totalProducts: 87,
      lowStockProducts: 5,
      salesChart: [
        SalesDataPoint(label: 'Mon', value: 8500),
        SalesDataPoint(label: 'Tue', value: 12300),
        SalesDataPoint(label: 'Wed', value: 9800),
        SalesDataPoint(label: 'Thu', value: 15200),
        SalesDataPoint(label: 'Fri', value: 18900),
        SalesDataPoint(label: 'Sat', value: 22100),
        SalesDataPoint(label: 'Sun', value: 14200),
      ],
    );
  }
}
