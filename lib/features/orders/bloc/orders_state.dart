import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final OrderStatus? filterStatus;

  const OrdersLoaded({
    required this.orders,
    this.filterStatus,
  });

  List<Order> get filteredOrders {
    if (filterStatus == null) return orders;
    return orders.where((order) => order.status == filterStatus).toList();
  }

  OrdersLoaded copyWith({
    List<Order>? orders,
    OrderStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }

  @override
  List<Object?> get props => [orders, filterStatus];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderUpdating extends OrdersState {
  final String orderId;

  const OrderUpdating(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
