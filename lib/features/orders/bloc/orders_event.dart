import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class RefreshOrders extends OrdersEvent {
  const RefreshOrders();
}

class AcceptOrder extends OrdersEvent {
  final String orderId;

  const AcceptOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class DeclineOrder extends OrdersEvent {
  final String orderId;

  const DeclineOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object?> get props => [orderId, newStatus];
}

class FilterOrdersByStatus extends OrdersEvent {
  final OrderStatus? status;

  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}
