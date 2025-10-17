import 'package:go_router/go_router.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/sales/screens/sales_report_screen.dart';
import '../../features/onboarding/screens/onboarding_main_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import 'main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductsScreen(),
            ),
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WalletScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      // Routes outside the shell (full screen)
      GoRoute(
        path: '/order/:id',
        name: 'orderDetail',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          final customerName = state.uri.queryParameters['customerName'] ?? 'Unknown';
          final status = state.uri.queryParameters['status'] ?? 'pending';
          return OrderDetailScreen(
            orderId: orderId,
            customerName: customerName,
            status: status,
          );
        },
      ),
      GoRoute(
        path: '/sales-report',
        name: 'salesReport',
        builder: (context, state) => const SalesReportScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          final useMockData = state.uri.queryParameters['mock'] == 'true';
          return OnboardingMainScreen(useMockData: useMockData);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
}
