import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/forgot_password_otp_screen.dart';
import '../../features/onboarding/screens/onboarding_main_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/screens/admin_approval_screen.dart';
import 'main_navigation.dart';

class SimpleRouter {
  static final GoRouter router = _createRouter();

  static GoRouter _createRouter() {
    print('🛣️ [SIMPLE_ROUTER] Creating GoRouter with initial location: /splash');
    final router = GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) {
            print('🎯 [SIMPLE_ROUTER] /splash route accessed');
            print('🎯 [SIMPLE_ROUTER] Current location: ${state.uri}');
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            print('🔐 [SIMPLE_ROUTER] /login route accessed');
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) {
            print('🔑 [SIMPLE_ROUTER] /forgot-password route accessed');
            return const ForgotPasswordScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password-otp',
          name: 'forgot-password-otp',
          builder: (context, state) {
            print('🔑 [SIMPLE_ROUTER] /forgot-password-otp route accessed');
            final phoneNumber = state.extra as String? ?? '';
            return ForgotPasswordOtpScreen(phoneNumber: phoneNumber);
          },
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) {
            print('📝 [SIMPLE_ROUTER] /onboarding route accessed');
            final useMockData = state.uri.queryParameters['mock'] == 'true';
            return OnboardingMainScreen(useMockData: useMockData);
          },
        ),
        GoRoute(
          path: '/admin-approval',
          name: 'admin-approval',
          builder: (context, state) {
            print('⏳ [SIMPLE_ROUTER] Admin approval route accessed');
            final fromParam = state.uri.queryParameters['from'];
            final showBack = fromParam == 'login';
            return AdminApprovalScreen(showBack: showBack);
          },
        ),
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) {
            print('🏠 [SIMPLE_ROUTER] Dashboard route (/) accessed');
            return const MainNavigation(child: DashboardScreen());
          },
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) {
            print('📦 [SIMPLE_ROUTER] Orders route accessed');
            return const MainNavigation(child: OrdersScreen());
          },
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) {
            print('🛍️ [SIMPLE_ROUTER] Products route accessed');
            return const MainNavigation(child: ProductsScreen());
          },
        ),
        GoRoute(
          path: '/wallet',
          name: 'wallet',
          builder: (context, state) {
            print('💰 [SIMPLE_ROUTER] Wallet route accessed');
            return const MainNavigation(child: WalletScreen());
          },
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) {
            print('👤 [SIMPLE_ROUTER] Profile route accessed');
            return const MainNavigation(child: ProfileScreen());
          },
        ),
      ],
    );
    print('🛣️ [SIMPLE_ROUTER] GoRouter created successfully');
    return router;
  }
}
