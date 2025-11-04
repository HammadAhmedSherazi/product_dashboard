import '../data/product_repository.dart';
import '../models/product.dart';

class ProductUseCase {
  final ProductRepository repository;

  ProductUseCase(this.repository);

  Future<List<Product>> getProducts() => repository.fetchProducts();
  Future<Product> getProduct(int id) => repository.fetchProduct(id);
  Future<Product> createProduct(Product product) => repository.addProduct(product);
  Future<Product> updateProduct(int id, Product product) => repository.updateProduct(id, product);
  Future<void> deleteProduct(int id) => repository.deleteProduct(id);
}
