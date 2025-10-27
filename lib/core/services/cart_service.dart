import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/b2b_product_model.dart';

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
