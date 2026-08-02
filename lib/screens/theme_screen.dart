import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/theme_provider.dart';
import '../app/translations.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    const primaryGreen = Color(0xFF5BA154);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back_ios, size: 20, color: colors.text),
        ),
        centerTitle: true,
        title: Text(
          t.appearance,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                title: Text(t.theme, style: TextStyle(color: colors.text)),
                subtitle: Text(themeProvider.isDark ? t.dark : t.light),
                value: themeProvider.isDark,
                activeThumbColor: primaryGreen,
                onChanged: (value) => themeProvider.setDarkMode(value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
