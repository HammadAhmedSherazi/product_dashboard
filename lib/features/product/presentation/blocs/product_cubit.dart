import 'package:bloc/bloc.dart';

import '../../domain/product_usecase.dart';
import '../../models/product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductUseCase useCase;
  List<Product> _allProducts = [];

  ProductCubit(this.useCase) : super(const ProductState());

  void fetchProducts({int limit = 30, int skip = 0}) async {
    final newState = state.copyWith(
      getProductResponse: skip == 0
          ? ApiResponse(status: ApiStatus.loading)
          : ApiResponse(status: ApiStatus.loadMore),
    );
    emit(newState);
    try {
      final products = await useCase.getProducts(limit: limit, skip: skip);
      _allProducts = skip == 0 ? products : [..._allProducts, ...products];
      final updatedState = state.copyWith(
        products: skip == 0 ? products : [...state.products, ...products],
        getProductResponse: ApiResponse(status: ApiStatus.success, data: products),
        skip: products.length >= limit ? skip + limit : 0,
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        getProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }

  void fetchProduct(int id) async {
    final newState = state.copyWith(
      getProductDetailResponse: ApiResponse(status: ApiStatus.loading),
    );
    emit(newState);
    try {
      final product = await useCase.getProduct(id);
      final updatedState = state.copyWith(
        selectedProduct: product,
        getProductDetailResponse: ApiResponse(status: ApiStatus.success, data: product),
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        getProductDetailResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }

  void addProduct(Product product) async {
    final newState = state.copyWith(
      addProductResponse: ApiResponse(status: ApiStatus.loading),
    );
    emit(newState);
    try {
      final newProduct = await useCase.createProduct(product);
      _allProducts = [..._allProducts, newProduct];
      final updatedState = state.copyWith(
        products: [...state.products, newProduct],
        addProductResponse: ApiResponse(status: ApiStatus.success, data: newProduct),
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        addProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }

  void updateProduct(int id, Product product) async {
    final newState = state.copyWith(
      updateProductResponse: ApiResponse(status: ApiStatus.loading),
    );
    emit(newState);
    try {
      final updatedProduct = await useCase.updateProduct(id, product);
      _allProducts = _allProducts.map((p) => p.id == id ? updatedProduct : p).toList();
      final updatedList = state.products.map((p) => p.id == id ? updatedProduct : p).toList();
      final updatedState = state.copyWith(
        products: updatedList,
        selectedProduct: updatedProduct,
        updateProductResponse: ApiResponse(status: ApiStatus.success, data: updatedProduct),
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        updateProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }

  void deleteProduct(int id) async {
    final newState = state.copyWith(
      deleteProductResponse: ApiResponse(status: ApiStatus.loading),
    );
    emit(newState);
    try {
      await useCase.deleteProduct(id);
      _allProducts = _allProducts.where((p) => p.id != id).toList();
      final updatedList = state.products.where((p) => p.id != id).toList();
      final updatedState = state.copyWith(
        products: updatedList,
        deleteProductResponse: ApiResponse(status: ApiStatus.success),
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        deleteProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }

  void searchProducts(String query) async {
    if (query.isEmpty) {
      final updatedState = state.copyWith(
        products: _allProducts,
        getProductResponse: ApiResponse(status: ApiStatus.success, data: _allProducts),
      );
      emit(updatedState);
    } else {
      final newState = state.copyWith(
        getProductResponse: ApiResponse(status: ApiStatus.loading),
      );
      emit(newState);
      try {
        final products = await useCase.searchProducts(query);
        final updatedState = state.copyWith(
          products: products,
          getProductResponse: ApiResponse(status: ApiStatus.success, data: products),
        );
        emit(updatedState);
      } catch (e) {
        final errorState = state.copyWith(
          getProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
        );
        emit(errorState);
      }
    }
  }

  void filterByCategory(String category) async {
    if (category.isEmpty) {
      final updatedState = state.copyWith(
        products: _allProducts,
        getProductResponse: ApiResponse(status: ApiStatus.success, data: _allProducts),
      );
      emit(updatedState);
    } else {
      final newState = state.copyWith(
        getProductResponse: ApiResponse(status: ApiStatus.loading),
      );
      emit(newState);
      try {
        final products = await useCase.getProductsByCategory(category);
        final updatedState = state.copyWith(
          products: products,
          getProductResponse: ApiResponse(status: ApiStatus.success, data: products),
        );
        emit(updatedState);
      } catch (e) {
        final errorState = state.copyWith(
          getProductResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
        );
        emit(errorState);
      }
    }
  }

  void filterByAvailability(bool inStock) {
    final filtered = _allProducts.where((p) => p.isInStock == inStock).toList();
    final updatedState = state.copyWith(
      products: filtered,
      getProductResponse: ApiResponse(status: ApiStatus.success, data: filtered),
    );
    emit(updatedState);
  }

  void fetchCategories() async {
    final newState = state.copyWith(
      getCategoriesResponse: ApiResponse(status: ApiStatus.loading),
    );
    emit(newState);
    try {
      final categories = await useCase.getCategories();
      final updatedState = state.copyWith(
        getCategoriesResponse: ApiResponse(status: ApiStatus.success, data: categories),
      );
      emit(updatedState);
    } catch (e) {
      final errorState = state.copyWith(
        getCategoriesResponse: ApiResponse(status: ApiStatus.error, error: e.toString()),
      );
      emit(errorState);
    }
  }
}
