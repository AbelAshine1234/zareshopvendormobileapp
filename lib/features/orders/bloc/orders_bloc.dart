import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<AcceptOrder>(_onAcceptOrder);
    on<DeclineOrder>(_onDeclineOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final orders = _getMockOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final orders = _getMockOrders();
      if (state is OrdersLoaded) {
        emit((state as OrdersLoaded).copyWith(orders: orders));
      } else {
        emit(OrdersLoaded(orders: orders));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrderUpdating(event.orderId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedOrders = currentState.orders.map((order) {
        if (order.id == event.orderId) {
          return order.copyWith(
            status: OrderStatus.processing,
            updatedAt: DateTime.now(),
          );
        }
        return order;
      }).toList();

      emit(currentState.copyWith(orders: updatedOrders));
    }
  }

  Future<void> _onDeclineOrder(
    DeclineOrder event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrderUpdating(event.orderId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedOrders = currentState.orders.map((order) {
        if (order.id == event.orderId) {
          return order.copyWith(
            status: OrderStatus.canceled,
            updatedAt: DateTime.now(),
          );
        }
        return order;
      }).toList();

      emit(currentState.copyWith(orders: updatedOrders));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrderUpdating(event.orderId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedOrders = currentState.orders.map((order) {
        if (order.id == event.orderId) {
          return order.copyWith(
            status: event.newStatus,
            updatedAt: DateTime.now(),
          );
        }
        return order;
      }).toList();

      emit(currentState.copyWith(orders: updatedOrders));
    }
  }

  void _onFilterOrdersByStatus(
    FilterOrdersByStatus event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(
        filterStatus: event.status,
        clearFilter: event.status == null,
      ));
    }
  }

  List<Order> _getMockOrders() {
    return [
      Order(
        id: 'ORD001',
        customerId: 'CUST001',
        customerName: 'Abebe Kebede',
        customerPhone: '+251911234567',
        deliveryAddress: 'Bole, Addis Ababa',
        items: const [
          OrderItem(
            productId: 'PROD001',
            productName: 'Traditional Coffee Set',
            productImage: 'https://via.placeholder.com/100',
            quantity: 2,
            price: 1500.00,
          ),
        ],
        totalAmount: 3000.00,
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD002',
        customerId: 'CUST002',
        customerName: 'Tigist Haile',
        customerPhone: '+251922345678',
        deliveryAddress: 'Piazza, Addis Ababa',
        items: const [
          OrderItem(
            productId: 'PROD002',
            productName: 'Ethiopian Spice Mix',
            productImage: 'https://via.placeholder.com/100',
            quantity: 5,
            price: 250.00,
          ),
        ],
        totalAmount: 1250.00,
        status: OrderStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Order(
        id: 'ORD003',
        customerId: 'CUST003',
        customerName: 'Dawit Tesfaye',
        customerPhone: '+251933456789',
        deliveryAddress: 'Merkato, Addis Ababa',
        items: const [
          OrderItem(
            productId: 'PROD003',
            productName: 'Handwoven Basket',
            productImage: 'https://via.placeholder.com/100',
            quantity: 1,
            price: 2500.00,
          ),
        ],
        totalAmount: 2500.00,
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
