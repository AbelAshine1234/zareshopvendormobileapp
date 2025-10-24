import 'package:flutter/foundation.dart';
import '../../features/b2b/models/b2b_product_model.dart';

class CartItem {
  final B2BProduct product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

class Cart {
  final List<CartItem> items;

  const Cart({required this.items});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  Cart addItem(B2BProduct product, int quantity) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = CartItem(
        product: product,
        quantity: items[existingIndex].quantity + quantity,
      );
      return Cart(items: updatedItems);
    } else {
      return Cart(items: [...items, CartItem(product: product, quantity: quantity)]);
    }
  }

  Cart removeItem(String productId) {
    return Cart(items: items.where((item) => item.product.id != productId).toList());
  }

  Cart updateItemQuantity(String productId, int quantity) {
    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return CartItem(product: item.product, quantity: quantity);
      }
      return item;
    }).toList();
    return Cart(items: updatedItems);
  }

  Cart clear() {
    return const Cart(items: []);
  }

  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}

class CartService extends ChangeNotifier {
  Cart _cart = const Cart(items: []);

  Cart get cart => _cart;

  int get itemCount => _cart.itemCount;

  double get totalPrice => _cart.totalPrice;

  bool get isEmpty => _cart.isEmpty;

  bool get isNotEmpty => _cart.isNotEmpty;

  List<CartItem> get items => _cart.items;

  void addItem(B2BProduct product, int quantity) {
    _cart = _cart.addItem(product, quantity);
    notifyListeners();
  }

  void removeItem(String productId) {
    _cart = _cart.removeItem(productId);
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    _cart = _cart.updateItemQuantity(productId, quantity);
    notifyListeners();
  }

  void clearCart() {
    _cart = _cart.clear();
    notifyListeners();
  }

  CartItem? getItemByProductId(String productId) {
    return _cart.getItemByProductId(productId);
  }

  bool isProductInCart(String productId) {
    return getItemByProductId(productId) != null;
  }

  int getProductQuantity(String productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
  }
}
