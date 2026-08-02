import 'package:flutter/material.dart';
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
                child: SwitchListTile(
                  title: Text(t.theme),
                  subtitle: Text(themeProvider.isDark ? t.dark : t.light),
                  value: themeProvider.isDark,
                  activeThumbColor: primaryGreen,
                  onChanged: (value) => themeProvider.setDarkMode(value),
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
          ],
        ),
      ),
    );
  }
}
