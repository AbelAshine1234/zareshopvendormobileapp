import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  const LoadProducts();
}

class RefreshProducts extends ProductsEvent {
  const RefreshProducts();
}

class AddProduct extends ProductsEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ToggleProductStatus extends ProductsEvent {
  final String productId;

  const ToggleProductStatus(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AddDiscount extends ProductsEvent {
  final String productId;
  final double discountPrice;

  const AddDiscount(this.productId, this.discountPrice);

  @override
  List<Object?> get props => [productId, discountPrice];
}
