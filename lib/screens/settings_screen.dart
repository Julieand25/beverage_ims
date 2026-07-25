import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    const backgroundColor = Color(0xFFF9F9F9);
    const textDark = Color(0xFF2C3E50);
    const primaryGreen = Color(0xFF5BA154);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textDark),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.appearance,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(t.theme),
                    subtitle: Text(themeProvider.isDark ? t.dark : t.light),
                    value: themeProvider.isDark,
                    activeThumbColor: primaryGreen,
                    onChanged: (value) => themeProvider.setDarkMode(value),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: Text(t.language),
                    trailing: SegmentedButton<Locale>(
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
          ],
        ),
      ),
    );
  }
}
