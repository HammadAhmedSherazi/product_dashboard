import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../widgets/add_edit_product_modal.dart';
import '../widgets/app_bar.dart';
import '../widgets/sidebar.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    context.read<ProductCubit>().fetchProduct(productId);

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const Sidebar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (constraints.maxWidth > 600) const Sidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<ProductCubit, ProductState>(
                          builder: (context, state) {
                            if (state.getProductDetailResponse?.status == ApiStatus.loading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state.getProductDetailResponse?.status == ApiStatus.success &&
                                       state.selectedProduct != null) {
                              final product = state.selectedProduct!;
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    Center(
                                      child: Image.network(
                                        product.thumbnail,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Product Info
                                    Text(
                                      product.title,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ID: ${product.id}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Category: ${product.category}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Price: \$${product.price}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Stock: ${product.isInStock ? 'In Stock' : 'Out of Stock'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: product.isInStock ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      product.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    // Images Gallery
                                    if (product.images.isNotEmpty) ...[
                                      const Text(
                                        'Images',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: product.images.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              width: 100,
                                              child: Image.network(
                                                product.images[index],
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    // Edit Button
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showEditModal(context, product),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit Product'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state.getProductDetailResponse?.status == ApiStatus.error) {
                              return Center(
                                child: Text('Error: ${state.getProductDetailResponse?.error ?? 'Unknown error'}'),
                              );
                            }
                            return const Center(child: Text('Product not found'));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditModal(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductModal(product: product),
    );
  }
}
