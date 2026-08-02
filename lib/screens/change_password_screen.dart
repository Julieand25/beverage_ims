import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/translations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
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
          t.changePassword,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Password
              Text(
                t.currentPassword,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              _PasswordField(
                controller: currentPasswordCtrl,
                hintText: t.currentPasswordHint,
                obscureText: obscureCurrent,
                onToggle: () => setState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 20),

              // New Password
              Text(
                t.newPassword,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              _PasswordField(
                controller: newPasswordCtrl,
                hintText: t.newPasswordHint,
                obscureText: obscureNew,
                onToggle: () => setState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              Text(
                t.confirmPassword,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              _PasswordField(
                controller: confirmPasswordCtrl,
                hintText: t.confirmPasswordHint,
                obscureText: obscureConfirm,
                onToggle: () => setState(() => obscureConfirm = !obscureConfirm),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.passwordMismatch),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final auth = context.read<AuthProvider>();
                    final success = await auth.changePassword(
                      currentPasswordCtrl.text,
                      newPasswordCtrl.text,
                    );
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.passwordChangedMsg),
                          backgroundColor: primaryGreen,
                        ),
                      );
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(t.wrongPassword),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
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
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: 14, color: colors.text),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: colors.gray),
        prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.gray),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: colors.gray,
          ),
        ),
        filled: true,
        fillColor: colors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
    );
  }
}
