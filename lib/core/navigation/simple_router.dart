import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/forgot_password_otp_screen.dart';
import '../../features/onboarding/screens/onboarding_main_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/b2b/screens/b2b_market_screen.dart';
import '../../features/suppliers/suppliers_screen.dart';
import '../../features/wallet_management/screens/wallet_management_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../shared/screens/admin_approval_screen.dart';
import 'main_navigation.dart';

class SimpleRouter {
  static final GoRouter router = _createRouter();

  static GoRouter _createRouter() {
    final router = GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) {
            return const ForgotPasswordScreen();
          },
        ),
        GoRoute(
          path: '/forgot-password-otp',
          name: 'forgot-password-otp',
          builder: (context, state) {
            final phoneNumber = state.extra as String? ?? '';
            return ForgotPasswordOtpScreen(phoneNumber: phoneNumber);
          },
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
          path: '/admin-approval',
          name: 'admin-approval',
          builder: (context, state) {
            final fromParam = state.uri.queryParameters['from'];
            final showBack = fromParam == 'login';
            return AdminApprovalScreen(showBack: showBack);
          },
        ),
        GoRoute(
          path: '/',
          name: 'b2b-market-home',
          builder: (context, state) {
            return const MainNavigation(child: B2BMarketScreen());
          },
        ),
        GoRoute(
          path: '/wallet',
          name: 'wallet',
          builder: (context, state) {
            return const MainNavigation(
              child: WalletManagementScreen(isVendor: true),
            );
          },
        ),
        GoRoute(
          path: '/b2b-market',
          name: 'b2b-market',
          builder: (context, state) {
            return const MainNavigation(child: B2BMarketScreen());
          },
        ),
        GoRoute(
          path: '/suppliers',
          name: 'suppliers',
          builder: (context, state) {
            return const MainNavigation(child: SuppliersScreen());
          },
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) {
            return const MainNavigation(child: ProductsScreen());
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) {
            return const MainNavigation(child: CartScreen());
          },
        ),
        GoRoute(
          path: '/my-zare',
          name: 'my-zare',
          builder: (context, state) {
            return const MainNavigation(child: SettingsScreen());
          },
        ),
        GoRoute(
          path: '/messages',
          name: 'messages',
          builder: (context, state) {
            final tabParam = state.uri.queryParameters['tab'];
            final initialTab = tabParam != null ? int.tryParse(tabParam) : null;
            return MainNavigation(
              child: MessagesScreen(initialTab: initialTab),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) {
            return const MainNavigation(child: SettingsScreen());
          },
        ),
      ],
    );
    return router;
  }
}
