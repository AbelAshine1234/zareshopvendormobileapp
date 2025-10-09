import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product_model.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc() : super(const ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<ToggleProductStatus>(_onToggleProductStatus);
    on<AddDiscount>(_onAddDiscount);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final products = _getMockProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final products = _getMockProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentProducts = (state as ProductsLoaded).products;
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedProducts = [...currentProducts, event.product];
      emit(ProductOperationSuccess(
        message: 'Product added successfully',
        products: updatedProducts,
      ));
      emit(ProductsLoaded(products: updatedProducts));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentProducts = (state as ProductsLoaded).products;
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedProducts = currentProducts.map((product) {
        return product.id == event.product.id ? event.product : product;
      }).toList();
      
      emit(ProductOperationSuccess(
        message: 'Product updated successfully',
        products: updatedProducts,
      ));
      emit(ProductsLoaded(products: updatedProducts));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentProducts = (state as ProductsLoaded).products;
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedProducts = currentProducts
          .where((product) => product.id != event.productId)
          .toList();
      
      emit(ProductOperationSuccess(
        message: 'Product deleted successfully',
        products: updatedProducts,
      ));
      emit(ProductsLoaded(products: updatedProducts));
    }
  }

  Future<void> _onToggleProductStatus(
    ToggleProductStatus event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentProducts = (state as ProductsLoaded).products;
      await Future.delayed(const Duration(milliseconds: 300));
      
      final updatedProducts = currentProducts.map((product) {
        if (product.id == event.productId) {
          return product.copyWith(isActive: !product.isActive);
        }
        return product;
      }).toList();
      
      emit(ProductsLoaded(products: updatedProducts));
    }
  }

  Future<void> _onAddDiscount(
    AddDiscount event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentProducts = (state as ProductsLoaded).products;
      await Future.delayed(const Duration(milliseconds: 300));
      
      final updatedProducts = currentProducts.map((product) {
        if (product.id == event.productId) {
          return product.copyWith(discountPrice: event.discountPrice);
        }
        return product;
      }).toList();
      
      emit(ProductOperationSuccess(
        message: 'Discount added successfully',
        products: updatedProducts,
      ));
      emit(ProductsLoaded(products: updatedProducts));
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: 'PROD001',
        name: 'Traditional Coffee Set',
        description: 'Authentic Ethiopian coffee set with jebena',
        price: 1500.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 25,
        category: 'Home & Kitchen',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Product(
        id: 'PROD002',
        name: 'Ethiopian Spice Mix',
        description: 'Berbere and Mitmita spice blend',
        price: 250.00,
        discountPrice: 200.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 100,
        category: 'Food & Beverages',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Product(
        id: 'PROD003',
        name: 'Handwoven Basket',
        description: 'Traditional Ethiopian mesob basket',
        price: 2500.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 15,
        category: 'Handicrafts',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Product(
        id: 'PROD004',
        name: 'Cotton Shawl',
        description: 'Traditional white cotton shawl (netela)',
        price: 800.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 40,
        category: 'Clothing',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Product(
        id: 'PROD005',
        name: 'Honey Jar',
        description: 'Pure Ethiopian forest honey - 500g',
        price: 450.00,
        discountPrice: 400.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 5,
        category: 'Food & Beverages',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Product(
        id: 'PROD006',
        name: 'Leather Bag',
        description: 'Handcrafted leather shoulder bag',
        price: 1800.00,
        imageUrl: 'https://via.placeholder.com/150',
        stock: 20,
        category: 'Accessories',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
