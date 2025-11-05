import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_dashboard/core/extensions.dart';

import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import 'add_edit_product_modal.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  bool? _filterInStock;
  Timer? _debounceTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<ProductCubit>().fetchProducts(limit: 20, skip: 0);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductCubit>().state;
      if (state.getProductResponse?.status != ApiStatus.loadMore && state.skip > 0) {
        context.read<ProductCubit>().fetchProducts(limit: 10, skip: state.skip);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if(value.length > 3){
        context.read<ProductCubit>().searchProducts(value);
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductCubit>().state;
    final categories = state.getCategoriesResponse!.data == null || state.getCategoriesResponse!.data!.isEmpty? state.products.map((p) => p.category).toSet().toList(): state.getCategoriesResponse!.data ?? [];
    return Column(
      children: [
        // Search and Filter Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: context.colorScheme.outline.withValues(alpha:0.2),
                width: 1,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 800;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSmallScreen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search field
                        Container(
                          height: 48,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search products...',
                              prefixIcon: Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.colorScheme.outline.withValues(alpha:0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: context.colorScheme.surface,
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        // Filters row
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: DropdownMenu<String>(
                                  initialSelection: _selectedCategory.isEmpty ? null : _selectedCategory,
                                  hintText: 'Category',
                                  dropdownMenuEntries: [
                                    const DropdownMenuEntry(value: '', label: 'All'),
                                    ...categories.map((cat) => DropdownMenuEntry(value: cat, label: cat)),
                                  ],
                                  onSelected: (value) {
                                    setState(() => _selectedCategory = value ?? '');
                                    if (value == null || value.isEmpty) {
                                      context.read<ProductCubit>().fetchProducts(limit: 10, skip: 0);
                                    } else {
                                      context.read<ProductCubit>().filterByCategory(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: DropdownMenu<bool?>(
                                  initialSelection: _filterInStock,
                                  hintText: 'Stock',
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(value: null, label: 'All'),
                                    DropdownMenuEntry(value: true, label: 'In Stock'),
                                    DropdownMenuEntry(value: false, label: 'Out of Stock'),
                                  ],
                                  onSelected: (value) {
                                    setState(() => _filterInStock = value);
                                    if (value != null) {
                                      context.read<ProductCubit>().filterByAvailability(value);
                                    } else {
                                      context.read<ProductCubit>().fetchProducts(limit: 10, skip: 0);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Add button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddEditModal(context, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search products...',
                                prefixIcon: Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: context.colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: context.colorScheme.outline.withValues(alpha:0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: context.colorScheme.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: context.colorScheme.surface,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 160,
                          height: 48,
                          child: DropdownMenu<String>(
                            initialSelection: _selectedCategory.isEmpty ? null : _selectedCategory,
                            hintText: 'Category',
                            dropdownMenuEntries: [
                              const DropdownMenuEntry(value: '', label: 'All Categories'),
                              ...categories.map((cat) => DropdownMenuEntry(value: cat, label: cat)),
                            ],
                            onSelected: (value) {
                              setState(() => _selectedCategory = value ?? '');
                              if (value == null || value.isEmpty) {
                                context.read<ProductCubit>().fetchProducts(limit: 10, skip: 0);
                              } else {
                                context.read<ProductCubit>().filterByCategory(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 140,
                          height: 48,
                          child: DropdownMenu<bool?>(
                            initialSelection: _filterInStock,
                            hintText: 'Stock',
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: null, label: 'All'),
                              DropdownMenuEntry(value: true, label: 'In Stock'),
                              DropdownMenuEntry(value: false, label: 'Out of Stock'),
                            ],
                            onSelected: (value) {
                              setState(() => _filterInStock = value);
                              if (value != null) {
                                context.read<ProductCubit>().filterByAvailability(value);
                              } else {
                                context.read<ProductCubit>().fetchProducts(limit: 10, skip: 0);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddEditModal(context, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
        // DataTable or Empty State
        Expanded(
          child: BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state.getProductResponse?.status == ApiStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.products.isNotEmpty) {
                return Container(
                    width: context.screenWidth,
                    // color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: context.screenWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen = constraints.maxWidth < 600;
                                return isSmallScreen
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: 800, // Minimum width for DataTable
                                          child: DataTable(
                                            headingRowColor: WidgetStateProperty.all(
                                              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                            ),
                                            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                              (Set<WidgetState> states) {
                                                if (states.contains(WidgetState.selected)) {
                                                  return Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
                                                }
                                                return null;
                                              },
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                                                onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('id'),
                                              ),
                                              DataColumn(
                                                label: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                                onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('title'),
                                              ),
                                              DataColumn(
                                                label: const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                                                onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('category'),
                                              ),
                                              DataColumn(
                                                label: const Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                                                onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('price'),
                                              ),
                                              DataColumn(
                                                label: const Text('Stock Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                                // onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('stock'),
                                              ),
                                              const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                            ],
                                            rows: state.products.map((product) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(product.id.toString())),
                                                  DataCell(
                                                    InkWell(
                                                      onTap: () => GoRouter.of(context).go('/product/${product.id}'),
                                                      child: Text(
                                                        product.title,
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.primary,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        product.category,
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: product.isInStock ? Colors.green : Colors.red,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        isSmallScreen ? (product.isInStock ? 'In' : 'Out') : (product.isInStock ? 'In Stock' : 'Out of Stock'),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                                          onPressed: () => _showAddEditModal(context, product),
                                                          tooltip: 'Edit Product',
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                                          onPressed: () => context.read<ProductCubit>().deleteProduct(product.id),
                                                          tooltip: 'Delete Product',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        child: DataTable(
                                          headingRowColor: WidgetStateProperty.all(
                                            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                          ),
                                          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                                            (Set<WidgetState> states) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
                                              }
                                              return null;
                                            },
                                          ),
                                          columns: [
                                            DataColumn(
                                              label: Expanded(child: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                              onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('id'),
                                            ),
                                            DataColumn(
                                              label: Expanded(child: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                              onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('title'),
                                            ),
                                            DataColumn(
                                              label: Expanded(child: const Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                              onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('category'),
                                            ),
                                            DataColumn(
                                              label: const Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                                              onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('price'),
                                            ),
                                            DataColumn(
                                              label: Expanded(child: const Text('Stock Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                              // onSort: (columnIndex, ascending) => context.read<ProductCubit>().sortProducts('stock'),
                                            ),
                                            const DataColumn(label: Expanded(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
                                          ],
                                          rows: state.products.map((product) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(product.id.toString())),
                                                DataCell(
                                                  InkWell(
                                                    onTap: () => GoRouter.of(context).go('/product/${product.id}'),
                                                    child: Text(
                                                      product.title,
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      product.category,
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                                DataCell(
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: product.isInStock ? Colors.green : Colors.red,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      product.isInStock ? 'In Stock' : 'Out of Stock',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                                        onPressed: () => _showAddEditModal(context, product),
                                                        tooltip: 'Edit Product',
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                                        onPressed: () => context.read<ProductCubit>().deleteProduct(product.id),
                                                        tooltip: 'Delete Product',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                              },
                            ),
                            if (state.getProductResponse?.status == ApiStatus.loadMore)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
            } else if (state.getProductResponse?.status == ApiStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.getProductResponse?.error ?? 'Unknown error'}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ProductCubit>().fetchProducts(limit: 10, skip: 0),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('No products available'));
            },
          ),
        ),

      ],
    );
  }

  void _showAddEditModal(BuildContext context, Product? product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductModal(product: product),
    );
  }
}

