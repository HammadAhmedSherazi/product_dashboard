import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';

class AddEditProductModal extends StatefulWidget {
  final Product? product;

  const AddEditProductModal({super.key, this.product});

  @override
  State<AddEditProductModal> createState() => _AddEditProductModalState();
}

class _AddEditProductModalState extends State<AddEditProductModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedCategory;
  late TextEditingController _thumbnailController;
  late TextEditingController _imagesController;
  late TextEditingController _stockController;
  bool _isInStock = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _selectedCategory = widget.product?.category ?? '';
    _thumbnailController = TextEditingController(
      text: widget.product?.thumbnail ?? '',
    );
    _imagesController = TextEditingController(
      text: widget.product?.images.join(', ') ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '10',
    );
    _isInStock = widget.product?.isInStock ?? true;
    context.read<ProductCubit>().fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _thumbnailController.dispose();
    _imagesController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory ?? '',
        thumbnail: _thumbnailController.text,
        images: _imagesController.text.split(',').map((e) => e.trim()).toList(),
        stock: int.parse(_stockController.text),
        isInStock: _isInStock,
      );

      if (widget.product == null) {
        context.read<ProductCubit>().addProduct(product);
      } else {
        context.read<ProductCubit>().updateProduct(widget.product!.id, product);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  final categories = state.getCategoriesResponse?.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory?.isEmpty ?? true ? null : _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a category' : null,
                  );
                },
              ),
              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a thumbnail URL' : null,
              ),
              TextFormField(
                controller: _imagesController,
                decoration: const InputDecoration(
                  labelText: 'Images (comma separated URLs)',
                ),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter stock';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('In Stock'),
                value: _isInStock,
                onChanged: (value) => setState(() => _isInStock = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        BlocListener<ProductCubit, ProductState>(
          listener: (context, state) {
            if (state.addProductResponse?.status == ApiStatus.success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );
            } else if (state.addProductResponse?.status == ApiStatus.error) {
              context.read<ProductCubit>().setResponse();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding product: ${state.addProductResponse?.error}')),
              );
            } else if (state.updateProductResponse?.status == ApiStatus.success) {
              context.read<ProductCubit>().setResponse();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated successfully')),
              );
            } else if (state.updateProductResponse?.status == ApiStatus.error) {
              context.read<ProductCubit>().setResponse();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating product: ${state.updateProductResponse?.error}')),
              );
            }
          },
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              final isLoading = state.addProductResponse?.status == ApiStatus.loading ||
                                state.updateProductResponse?.status == ApiStatus.loading;
              return ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.product == null ? 'Add' : 'Update'),
              );
            },
          ),
        ),
      ],
    );
  }
}
