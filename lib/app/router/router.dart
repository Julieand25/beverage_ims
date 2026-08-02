import 'package:go_router/go_router.dart';
import '../../screens/about_screen.dart';
import '../../screens/audit_log_screen.dart';
import '../../screens/language_screen.dart';
import '../../screens/theme_screen.dart';
import '../../screens/change_password_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/recipe_screen.dart';
import '../../screens/register_staff_screen.dart';
import '../../screens/report_screen.dart';
import '../../screens/settings_screen.dart';
import '../widgets/app_shell.dart';

GoRouter createRouter({required bool isLoggedIn}) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
        path: '/audit-logs',
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/theme',
        builder: (context, state) => const ThemeScreen(),
      ),
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
                builder: (context, state) => const InventoryScreen(),
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
}
