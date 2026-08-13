import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/translations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isSaving = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = Translations.of(context);
    final password = passwordController.text;
    if (password.length < 6 || password != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            password.length < 6 ? t.invalidPassword : t.passwordMismatch,
          ),
        ),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      await context.read<AuthProvider>().updatePassword(password);
      if (!mounted) return;
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.resetPasswordSuccess)));
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.connectionError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
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
          t.resetPassword,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.newPassword,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: TextStyle(fontSize: 14, color: colors.text),
                    decoration: InputDecoration(
                      hintText: t.newPasswordHint,
                      hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: colors.gray,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => obscurePassword = !obscurePassword),
                        child: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: colors.gray,
                        ),
                      ),
                      filled: true,
                      fillColor: colors.inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.confirmPassword,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    style: TextStyle(fontSize: 14, color: colors.text),
                    decoration: InputDecoration(
                      hintText: t.confirmPasswordHint,
                      hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: colors.gray,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                        child: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: colors.gray,
                        ),
                      ),
                      filled: true,
                      fillColor: colors.inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              t.save,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
