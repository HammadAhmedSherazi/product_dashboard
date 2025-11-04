import '../data/product_repository.dart';
import '../models/product.dart';

class ProductUseCase {
  final ProductRepository repository;

  ProductUseCase(this.repository);

  Future<List<Product>> getProducts({int limit = 30, int skip = 0}) => repository.fetchProducts(limit: limit, skip: skip);
  Future<List<String>> getCategories() => repository.fetchCategories();
  Future<List<Product>> getProductsByCategory(String category) => repository.fetchProductsByCategory(category);
  Future<List<Product>> searchProducts(String query) => repository.searchProducts(query);
  Future<Product> getProduct(int id) => repository.fetchProduct(id);
  Future<Product> createProduct(Product product) => repository.addProduct(product);
  Future<Product> updateProduct(int id, Product product) => repository.updateProduct(id, product);
  Future<void> deleteProduct(int id) => repository.deleteProduct(id);
}
