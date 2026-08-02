import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_colors.dart';
import 'audit_provider.dart';
import 'auth_provider.dart';
import 'inventory_provider.dart';
import 'locale_provider.dart';
import 'recipe_provider.dart';
import 'sales_provider.dart';
import 'theme_provider.dart';
import 'repositories/audit_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/recipe_repository.dart';
import 'repositories/sales_repository.dart';
import 'router/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => AuditProvider(repo: SupabaseAuditRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepo: SupabaseAuthRepository(client),
            auditRepo: SupabaseAuditRepository(client),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(repo: SupabaseInventoryRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(repo: SupabaseRecipeRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(repo: SupabaseSalesRepository(client)),
        ),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, AuthProvider>(
        builder: (context, themeProvider, localeProvider, authProvider, _) {
          final router = createRouter(isLoggedIn: authProvider.isLoggedIn);
          return MaterialApp.router(
            title: 'Beverage IMS',
            routerConfig: router,
            locale: localeProvider.locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF9F9F9),
              extensions: const <ThemeExtension<dynamic>>[AppColors.light],
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
            ),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
