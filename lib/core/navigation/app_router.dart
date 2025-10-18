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
import '../../features/splash/splash_screen.dart';
import '../widgets/auth_guard.dart';
import 'main_navigation.dart';

class AppRouter {
  static final GoRouter router = _createRouter();

  static GoRouter _createRouter() {
    print('🛣️ [ROUTER] Creating GoRouter with initial location: /splash');
    final router = GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true, // Enable GoRouter debug logging
      routes: [
      // Splash route - should be first to avoid conflicts
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          print('🎯 [ROUTER] /splash route accessed');
          print('🎯 [ROUTER] Current location: ${state.uri}');
          return const SplashScreen();
        },
      ),
      // Simple test route
      GoRoute(
        path: '/test',
        name: 'test',
        builder: (context, state) {
          print('🧪 [ROUTER] /test route accessed');
          return const Scaffold(
            body: Center(
              child: Text('Test Route Working!'),
            ),
          );
        },
      ),
    ],
  );
    print('🛣️ [ROUTER] GoRouter created successfully');
    return router;
  }
}
