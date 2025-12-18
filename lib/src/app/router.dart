import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_stock_screen.dart';
import '../features/admin/presentation/admin_transactions_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/checkout/presentation/payment_webview_screen.dart';
import '../features/checkout/presentation/transaction_status_screen.dart';
import '../features/checkout/domain/payment_flow.dart';
import '../features/expert_system/presentation/expert_system_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/products/presentation/product_detail_screen.dart';
import '../features/products/presentation/product_list_screen.dart';
import '../features/transactions/presentation/transaction_history_screen.dart';
import '../features/session/application/session_controller.dart';
import '../features/splash/presentation/splash_screen.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<SessionState>(
      sessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;

  bool get isAdmin =>
      ref.read(sessionControllerProvider).role == UserRole.admin;

  bool get isAuthenticated =>
      ref.read(sessionControllerProvider).isAuthenticated;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAdmin = notifier.isAdmin;
      final isAuth = notifier.isAuthenticated;
      final loc = state.matchedLocation;

      final isAuthRoute = loc.startsWith('/auth');
      final isAppRoute = loc.startsWith('/app');

      if (!isAuth && isAppRoute) {
        return '/auth/login';
      }

      if (isAuth && isAuthRoute) {
        return isAdmin ? '/app/admin' : '/app/home';
      }

      if (loc.startsWith('/app/admin') && !isAdmin) {
        return '/app/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
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
                path: '/app/products',
                builder: (context, state) => const ProductListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/expert',
                builder: (context, state) => const ExpertSystemScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/app/map',
        builder: (context, state) {
          final navigateTo = state.uri.queryParameters['navigateTo'];
          return MapScreen(navigateTo: navigateTo);
        },
      ),
      GoRoute(
        path: '/app/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/app/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'stock',
            builder: (context, state) => const AdminStockScreen(),
          ),
          GoRoute(
            path: 'transactions',
            builder: (context, state) => const AdminTransactionsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/app/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/app/history',
        builder: (context, state) => const TransactionHistoryScreen(),
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
        path: '/app/payment/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra;
          String? snapUrl;
          List<PaymentStep> remaining = const [];
          if (extra is String) {
            snapUrl = extra;
          } else if (extra is PaymentFlowArgs) {
            snapUrl = extra.snapUrl;
            remaining = extra.remaining;
          }

          if (snapUrl == null || snapUrl.trim().isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pembayaran')),
              body: const Center(child: Text('URL pembayaran tidak tersedia.')),
            );
          }
          return PaymentWebViewScreen(
            orderId: orderId,
            snapUrl: snapUrl,
            remaining: remaining,
          );
        },
      ),
      GoRoute(
        path: '/app/tx/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final remaining = extra is List<PaymentStep>
              ? extra
              : const <PaymentStep>[];
          return TransactionStatusScreen(
            transactionId: id,
            remainingPayments: remaining,
          );
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
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.local_drink_outlined),
        label: 'Products',
      ),
      const NavigationDestination(
        icon: Icon(Icons.psychology_outlined),
        label: 'AI',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}
