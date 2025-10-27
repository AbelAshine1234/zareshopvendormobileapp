import 'package:equatable/equatable.dart';
import 'b2b_product_model.dart';

class CartItem extends Equatable {
  final String id;
  final B2BProduct product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.finalPrice * quantity;

  CartItem copyWith({
    String? id,
    B2BProduct? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, addedAt];
}

class Cart extends Equatable {
  final List<CartItem> items;
  final DateTime? lastUpdated;

  const Cart({
    required this.items,
    this.lastUpdated,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Cart addItem(B2BProduct product, int quantity) {
    final existingItem = getItemByProductId(product.id);
    
    if (existingItem != null) {
      return updateItemQuantity(product.id, existingItem.quantity + quantity);
    } else {
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      
      return Cart(
        items: [...items, newItem],
        lastUpdated: DateTime.now(),
      );
    }
  }

  Cart removeItem(String productId) {
    return Cart(
      items: items.where((item) => item.product.id != productId).toList(),
      lastUpdated: DateTime.now(),
    );
  }

  Cart updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(
      items: updatedItems,
      lastUpdated: DateTime.now(),
    );
  }

  Cart clear() {
    return const Cart(
      items: [],
    );
  }

  Cart copyWith({
    List<CartItem>? items,
    DateTime? lastUpdated,
  }) {
    return Cart(
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [items, lastUpdated];
}
