import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/checkout/presentation/transaction_status_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/products/presentation/product_detail_screen.dart';
import '../features/products/presentation/product_list_screen.dart';
import '../features/session/application/session_controller.dart';
import '../features/splash/presentation/splash_screen.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<SessionState>(sessionControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;

  bool get isAdmin => ref.read(sessionControllerProvider).role == UserRole.admin;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAdmin = notifier.isAdmin;
      final loc = state.matchedLocation;

      if (loc.startsWith('/app/admin') && !isAdmin) {
        return '/app/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/admin',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/app/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/app/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/app/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/app/tx/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionStatusScreen(transactionId: id);
        },
      ),
    ],
  );
});

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final isAdmin = session.role == UserRole.admin;

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
      const NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
      if (isAdmin) const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
    ];

    final currentIndex = () {
      final idx = navigationShell.currentIndex;
      if (!isAdmin && idx >= 3) return 0;
      return idx;
    }();

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          final targetIndex = (!isAdmin && index >= 3) ? 0 : index;
          navigationShell.goBranch(targetIndex);
        },
      ),
    );
  }
}
