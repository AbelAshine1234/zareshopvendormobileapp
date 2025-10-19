import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/forgot_password_otp_screen.dart';
import '../../features/onboarding/screens/onboarding_main_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/onboarding/steps/admin_approval_screen.dart';

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
            return const AdminApprovalScreen();
          },
        ),
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) {
            print('🏠 [SIMPLE_ROUTER] Dashboard route (/) accessed');
            return const DashboardScreen();
          },
        ),
      ],
    );
    print('🛣️ [SIMPLE_ROUTER] GoRouter created successfully');
    return router;
  }
}
