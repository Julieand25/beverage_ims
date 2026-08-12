import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/about_screen.dart';
import '../../screens/audit_log_screen.dart';
import '../../screens/language_screen.dart';
import '../../screens/theme_screen.dart';
import '../../screens/change_password_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/recipe_screen.dart';
import '../../screens/register_staff_screen.dart';
import '../../screens/reset_password_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/user_management_screen.dart';
import '../../screens/report_screen.dart';
import '../../screens/settings_screen.dart';
import '../auth_provider.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? goRouter;
}

GoRouter createRouter({required AuthProvider authProvider}) {
  final router = GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (authProvider.isLoading) return null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';
      final isResetPasswordRoute = state.matchedLocation == '/reset-password';
      final isForgotPasswordRoute =
          state.matchedLocation == '/forgot-password';
      // Let Supabase finish processing the recovery session before the page
      // attempts to update the password.
      if (isResetPasswordRoute || isForgotPasswordRoute) return null;
      if (authProvider.isLoggedIn) {
        if (isLoginRoute || isSplashRoute) return '/dashboard';
        return null;
      } else {
        if (isLoginRoute) return null;
        return '/login';
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/register-staff',
        builder: (context, state) => const RegisterStaffScreen(),
      ),
      GoRoute(
        path: '/manage-users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/audit-logs',
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/theme', builder: (context, state) => const ThemeScreen()),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventori',
                name: 'inventori',
                builder: (context, state) {
                  final itemId = state.uri.queryParameters['itemId'];
                  return InventoryScreen(focusItemId: itemId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/resipi',
                builder: (context, state) => const RecipeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/laporan',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tetapan',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  AppRouter.goRouter = router;
  return router;
}
