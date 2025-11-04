import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts({int limit = 30, int skip = 0});
  Future<List<String>> fetchCategories();
  Future<List<Product>> fetchProductsByCategory(String category);
  Future<List<Product>> searchProducts(String query);
  Future<Product> fetchProduct(int id);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(int id, Product product);
  Future<void> deleteProduct(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  final String baseUrl = 'https://dummyjson.com';

  @override
  Future<List<Product>> fetchProducts({int limit = 30, int skip = 0}) async {
    final response = await http.get(Uri.parse('$baseUrl/products?limit=$limit&skip=$skip'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List).map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products/category-list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List).map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/products/search?q=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['products'] as List).map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }

  @override
  Future<Product> fetchProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add product');
    }
  }

  @override
  Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
