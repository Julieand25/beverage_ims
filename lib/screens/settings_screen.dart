import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/locale_provider.dart';
import '../app/theme_provider.dart';
import '../app/translations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;
    const primaryGreen = Color(0xFF5BA154);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.settings,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Appearance header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                t.appearance,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.gray,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    title: Text(t.theme),
                    subtitle: Text(themeProvider.isDark ? t.dark : t.light),
                    value: themeProvider.isDark,
                    activeThumbColor: primaryGreen,
                    onChanged: (value) => themeProvider.setDarkMode(value),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                t.language,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.gray,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Language picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SegmentedButton<Locale>(
                segments: [
                  ButtonSegment(
                    value: const Locale('ms'),
                    label: Text(t.malay),
                  ),
                  ButtonSegment(
                    value: const Locale('en'),
                    label: Text(t.english),
                  ),
                ],
                selected: {localeProvider.locale},
                onSelectionChanged: (set) =>
                    localeProvider.setLocale(set.first),
              ),
            ),
            const SizedBox(height: 24),

            // Account section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.gray,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push('/change-password'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.changePassword,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 20, color: colors.gray),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.logout, size: 20, color: Colors.white),
                  label: Text(
                    t.signOut,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
