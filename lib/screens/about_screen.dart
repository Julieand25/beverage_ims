import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/app_colors.dart';
import '../app/translations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
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
          t.aboutApp,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🥤', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  t.appTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.isMs ? 'Sistem Pengurusan Inventori untuk Kedai Minuman' : 'Inventory Management System for Beverage Shops',
                  style: TextStyle(fontSize: 14, color: colors.gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Version', '1.0.0+1', colors),
                      const Divider(height: 20),
                      _infoRow(t.isMs ? 'Dibina Dengan' : 'Built With', 'Flutter + Supabase', colors),
                      const Divider(height: 20),
                      _infoRow(t.isMs ? 'Lesen' : 'License', 'Internal Use Only', colors),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '© 2026 Cuyaa Matcha Latte',
                  style: TextStyle(fontSize: 12, color: colors.gray),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colors.gray),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}
