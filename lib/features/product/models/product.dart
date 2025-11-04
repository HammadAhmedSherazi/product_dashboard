class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String thumbnail;
  final List<String> images;
  final bool isInStock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.thumbnail,
    required this.images,
    required this.isInStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
      isInStock: json['stock'] > 0, // Simulate stock status
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
      'stock': isInStock ? 10 : 0, // Simulate stock for API
    };
  }
}
