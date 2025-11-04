import 'package:bloc/bloc.dart';

import '../../domain/product_usecase.dart';
import '../../models/product.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductUseCase useCase;

  ProductCubit(this.useCase) : super(ProductInitial());

  void fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await useCase.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void fetchProduct(int id) async {
    emit(ProductLoading());
    try {
      final product = await useCase.getProduct(id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void addProduct(Product product) async {
    try {
      final newProduct = await useCase.createProduct(product);
      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        emit(ProductLoaded([...currentProducts, newProduct]));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void updateProduct(int id, Product product) async {
    try {
      final updatedProduct = await useCase.updateProduct(id, product);
      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        final updatedList = currentProducts.map((p) => p.id == id ? updatedProduct : p).toList();
        emit(ProductLoaded(updatedList));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void deleteProduct(int id) async {
    try {
      await useCase.deleteProduct(id);
      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        final updatedList = currentProducts.where((p) => p.id != id).toList();
        emit(ProductLoaded(updatedList));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
