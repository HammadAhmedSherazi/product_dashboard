import 'package:equatable/equatable.dart';
import 'package:product_dashboard/features/product/models/product.dart';

enum ApiStatus {
  initial,
  loading,
  success,
  error,
  loadMore,
}

class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? error;

  const ApiResponse({
    required this.status,
    this.data,
    this.error,
  });

  ApiResponse<T> copyWith({
    ApiStatus? status,
    T? data,
    String? error,
  }) {
    return ApiResponse<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class ProductState extends Equatable {
  final List<Product> products;
  final Product? selectedProduct;
  final ApiResponse<List<Product>>? getProductResponse;
  final ApiResponse<Product>? addProductResponse;
  final ApiResponse<Product>? getProductDetailResponse;
  final ApiResponse<Product>? updateProductResponse;
  final ApiResponse<void>? deleteProductResponse;
  final ApiResponse<List<String>>? getCategoriesResponse;
  final int skip;
  final String? sortField;
  final bool sortAscending;

  const ProductState({
    this.products = const [],
    this.selectedProduct,
    this.getProductResponse,
    this.addProductResponse,
    this.getProductDetailResponse,
    this.updateProductResponse,
    this.deleteProductResponse,
    this.getCategoriesResponse,
    this.skip = 0,
    this.sortField,
    this.sortAscending = true,
  });

  ProductState copyWith({
    List<Product>? products,
    Product? selectedProduct,
    ApiResponse<List<Product>>? getProductResponse,
    ApiResponse<Product>? addProductResponse,
    ApiResponse<Product>? getProductDetailResponse,
    ApiResponse<Product>? updateProductResponse,
    ApiResponse<void>? deleteProductResponse,
    ApiResponse<List<String>>? getCategoriesResponse,
    int? skip,
    String? sortField,
    bool? sortAscending,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      getProductResponse: getProductResponse ?? this.getProductResponse,
      addProductResponse: addProductResponse ?? this.addProductResponse,
      getProductDetailResponse: getProductDetailResponse ?? this.getProductDetailResponse,
      updateProductResponse: updateProductResponse ?? this.updateProductResponse,
      deleteProductResponse: deleteProductResponse ?? this.deleteProductResponse,
      getCategoriesResponse: getCategoriesResponse ?? this.getCategoriesResponse,
      skip: skip ?? this.skip,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
    products,
    selectedProduct,
    getProductResponse,
    addProductResponse,
    getProductDetailResponse,
    updateProductResponse,
    deleteProductResponse,
    getCategoriesResponse,
    skip,
    sortField,
    sortAscending,
  ];
}
