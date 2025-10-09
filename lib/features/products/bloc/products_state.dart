import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<Product> products;

  const ProductsLoaded({required this.products});

  ProductsLoaded copyWith({List<Product>? products}) {
    return ProductsLoaded(products: products ?? this.products);
  }

  @override
  List<Object?> get props => [products];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductsState {
  final String message;
  final List<Product> products;

  const ProductOperationSuccess({
    required this.message,
    required this.products,
  });

  @override
  List<Object?> get props => [message, products];
}
