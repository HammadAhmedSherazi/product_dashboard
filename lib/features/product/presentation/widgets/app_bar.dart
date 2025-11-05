import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_dashboard/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:product_dashboard/features/product/presentation/blocs/product_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String)? onChanged;

  const CustomAppBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final showSearch = isLargeScreen && (location == '/' || location == '/products');

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return Row(
            children: [
              Icon(
                Icons.inventory_2,
                color: Theme.of(context).colorScheme.primary,
                size: isSmallScreen ? 24 : 28,
              ),
              const SizedBox(width: 8),
              if(!isSmallScreen)
              Expanded(
                child: Text(
                    'Product Dashboard',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (showSearch)
          SizedBox(
            width: MediaQuery.of(context).size.width > 1200 ? 300 : MediaQuery.of(context).size.width * 0.25,
            child: TextField(
              onChanged: (value){
                Future.delayed(Duration(microseconds: 5000),(){
                  if(value.length > 3){
                  if(!context.mounted) return;
                  context.read<ProductCubit>().searchProducts(value);
                }
                else if(value == ""){
                  if(!context.mounted) return;
                  context.read<ProductCubit>().fetchProducts();
                }
                });
                
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha:0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        if (showSearch) const SizedBox(width: 8),
        // IconButton(
        //   icon: Icon(
        //     Icons.notifications_outlined,
        //     color: Theme.of(context).colorScheme.onSurfaceVariant,
        //   ),
        //   onPressed: () {
        //     // TODO: Implement notifications
        //   },
        //   tooltip: 'Notifications',
        // ),
        // const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthCubit>().logout().whenComplete((){
                if(!context.mounted) return;
                GoRouter.of(context).go('/login');
              });
              
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
