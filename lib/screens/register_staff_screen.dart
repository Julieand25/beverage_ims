import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app/app_colors.dart';
import '../app/auth_provider.dart';
import '../app/translations.dart';

class RegisterStaffScreen extends StatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  State<RegisterStaffScreen> createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
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
          t.registerStaff,
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
              Text(
                t.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: 14, color: colors.text),
                decoration: InputDecoration(
                  hintText: t.nameHint,
                  hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                  prefixIcon: Icon(Icons.person_outline, size: 20, color: colors.gray),
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
              ),
              const SizedBox(height: 20),
              Text(
                t.email,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14, color: colors.text),
                decoration: InputDecoration(
                  hintText: t.emailHint,
                  hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                  prefixIcon: Icon(Icons.email_outlined, size: 20, color: colors.gray),
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
              ),
              const SizedBox(height: 20),
              Text(
                t.password,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                style: TextStyle(fontSize: 14, color: colors.text),
                decoration: InputDecoration(
                  hintText: t.passwordHint,
                  hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.gray),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => obscurePassword = !obscurePassword),
                    child: Icon(
                      obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
              ),
              const SizedBox(height: 20),
              Text(
                t.confirmPassword,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordCtrl,
                obscureText: obscureConfirm,
                style: TextStyle(fontSize: 14, color: colors.text),
                decoration: InputDecoration(
                  hintText: t.confirmPasswordHint,
                  hintStyle: TextStyle(fontSize: 14, color: colors.gray),
                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.gray),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => obscureConfirm = !obscureConfirm),
                    child: Icon(
                      obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                           final email = emailCtrl.text.trim();
                           if (nameCtrl.text.trim().isEmpty || email.isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                               SnackBar(content: Text(t.fillAllFields), backgroundColor: Colors.red),
                             );
                             return;
                           }
                           final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                           if (!emailRegex.hasMatch(email)) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(t.emailInvalid), backgroundColor: Colors.red),
                             );
                             return;
                           }
                           if (passwordCtrl.text.length < 6) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(t.passwordTooShort), backgroundColor: Colors.red),
                             );
                             return;
                           }
                           if (passwordCtrl.text != confirmPasswordCtrl.text) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(t.passwordMismatch), backgroundColor: Colors.red),
                             );
                             return;
                           }
                           setState(() => _isSaving = true);
                           bool success;
                           try {
                             final auth = context.read<AuthProvider>();
                             success = await auth.registerStaff(nameCtrl.text.trim(), email, passwordCtrl.text);
                           } catch (_) {
                             success = false;
                           }
                           if (!mounted) return;
                           setState(() => _isSaving = false);
                           if (success) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(t.staffRegistered), backgroundColor: primaryGreen),
                             );
                             context.pop();
                           } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(t.staffRegisterFailed), backgroundColor: Colors.red),
                             );
                           }
                         },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          t.save,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
