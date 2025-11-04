part of 'product_cubit.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded(this.products);
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  ProductDetailLoaded(this.product);
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
