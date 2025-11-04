import 'package:go_router/go_router.dart';

import '../features/product/presentation/pages/dashboard_page.dart';
import '../features/product/presentation/pages/products_page.dart';
import '../features/product/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
