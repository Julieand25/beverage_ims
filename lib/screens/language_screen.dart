import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/locale_provider.dart';
import '../app/translations.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final colors = Theme.of(context).extension<AppColors>()!;

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
          t.language,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SegmentedButton<Locale>(
            segments: [
              ButtonSegment(value: const Locale('ms'), label: Text(t.malay)),
              ButtonSegment(value: const Locale('en'), label: Text(t.english)),
            ],
            selected: {localeProvider.locale},
            onSelectionChanged: (set) => localeProvider.setLocale(set.first),
          ),
        ),
      ),
    );
  }
}
