import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final String selectedPeriod;

  const DashboardLoaded({
    required this.stats,
    this.selectedPeriod = 'daily',
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    String? selectedPeriod,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [stats, selectedPeriod];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
