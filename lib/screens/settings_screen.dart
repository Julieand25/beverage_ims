import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
// import '../app/locale_provider.dart';
import '../app/theme_provider.dart';
import '../app/translations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) _nameController.text = user.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName(AuthProvider auth) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    setState(() => _isSavingName = true);
    final success = await auth.updateUserName(newName);
    if (!mounted) return;
    setState(() {
      _isSavingName = false;
      _isEditingName = false;
    });
    final t = Translations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? t.nameUpdated : t.staffRegisterFailed),
        backgroundColor: success ? const Color(0xFF5BA154) : Colors.red,
      ),
    );
  }

  void _cancelEdit() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) _nameController.text = user.name;
    setState(() => _isEditingName = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    // final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryGreen.withAlpha(30),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _isEditingName
                                        ? SizedBox(
                                            height: 36,
                                            child: TextField(
                                              controller: _nameController,
                                              autofocus: true,
                                              textCapitalization: TextCapitalization.words,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: colors.text,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: primaryGreen),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: primaryGreen),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colors.text,
                                            ),
                                          ),
                                  ),
                                  if (_isEditingName) ...[
                                    const SizedBox(width: 8),
                                    if (_isSavingName)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    else ...[
                                      GestureDetector(
                                        onTap: () => _saveName(auth),
                                        child: Icon(Icons.check, size: 20, color: primaryGreen),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _cancelEdit,
                                        child: Icon(Icons.close, size: 20, color: colors.gray),
                                      ),
                                    ],
                                  ] else
                                    GestureDetector(
                                      onTap: () => setState(() => _isEditingName = true),
                                      child: Icon(Icons.edit_outlined, size: 18, color: colors.gray),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: TextStyle(fontSize: 13, color: colors.gray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Appearance section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  t.appearance,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.gray),
                ),
              ),
            const SizedBox(height: 8),

            // Theme row
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
                    onTap: () => context.push('/theme'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.palette_outlined, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.theme,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                            ),
                          ),
                          Text(
                            themeProvider.isDark ? t.dark : t.light,
                            style: TextStyle(fontSize: 13, color: colors.gray),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, size: 20, color: colors.gray),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // // Language section
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Text(
            //     t.language,
            //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.gray),
            //   ),
            // ),
            // const SizedBox(height: 8),
            //
            // // Language row
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: colors.card,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Material(
            //       type: MaterialType.transparency,
            //       child: InkWell(
            //         onTap: () => context.push('/language'),
            //         borderRadius: BorderRadius.circular(12),
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            //           child: Row(
            //             children: [
            //               Icon(Icons.translate, size: 20, color: colors.text),
            //               const SizedBox(width: 12),
            //               Expanded(
            //                 child: Text(
            //                   t.language,
            //                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
            //                 ),
            //               ),
            //               Text(
            //                 localeProvider.locale.languageCode == 'ms' ? t.malay : t.english,
            //                 style: TextStyle(fontSize: 13, color: colors.gray),
            //               ),
            //               const SizedBox(width: 8),
            //               Icon(Icons.chevron_right, size: 20, color: colors.gray),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),

            // Account section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                t.account,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.gray),
              ),
            ),
            const SizedBox(height: 8),

            if (context.watch<AuthProvider>().isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push('/manage-users'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.group_outlined, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.manageUsers,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
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

            if (context.watch<AuthProvider>().isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push('/audit-logs'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.viewAuditLogs,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
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

            if (context.watch<AuthProvider>().isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push('/register-staff'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.person_add_outlined, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.registerStaff,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
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
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
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
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push('/about'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: colors.text),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.aboutApp,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
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
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) context.go('/login');
                    });
                  },
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
      ),
    );
  }
}
