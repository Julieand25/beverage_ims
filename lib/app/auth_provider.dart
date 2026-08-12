import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'models/audit_log.dart';
import 'models/user.dart';
import 'repositories/auth_repository.dart';
import 'repositories/audit_repository.dart';
import 'services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final AuditRepository _auditRepo;
  User? _currentUser;
  bool _isLoading = true;
  bool _isPasswordRecovery = false;
  late final StreamSubscription<AuthState> _authSubscription;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isLoading => _isLoading;
  bool get isPasswordRecovery => _isPasswordRecovery;

  AuthProvider({required this._authRepo, required this._auditRepo}) {
    _authSubscription = _authRepo.authStateChanges.listen(_handleAuthState);
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      _currentUser = await _authRepo.getStoredSession();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthState(AuthState state) async {
    _isPasswordRecovery = state.event == AuthChangeEvent.passwordRecovery;

    if (state.event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    if (state.session == null) return;

    try {
      _currentUser = await _authRepo.getStoredSession();
    } catch (_) {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await _authRepo.login(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      NotificationService.instance.registerToken(
        user.id,
        Supabase.instance.client,
      );
      try {
        await _auditRepo.addLog(
          AuditLog(
            userId: user.id,
            userName: user.name,
            action: 'LOGIN',
            targetType: 'auth',
            details: {'email': email},
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {}
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      final currentId = _currentUser!.id;
      try {
        await _auditRepo.addLog(
          AuditLog(
            userId: currentId,
            userName: _currentUser!.name,
            action: 'SIGN_OUT',
            targetType: 'auth',
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {}
      NotificationService.instance.removeToken(
        currentId,
        Supabase.instance.client,
      );
    }
    await _authRepo.logout();
    _currentUser = null;
    _isPasswordRecovery = false;
    notifyListeners();
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_currentUser == null) return false;
    final success = await _authRepo.changePassword(
      _currentUser!.id,
      currentPassword,
      newPassword,
    );
    if (success) {
      try {
        await _auditRepo.addLog(
          AuditLog(
            userId: _currentUser!.id,
            userName: _currentUser!.name,
            action: 'CHANGE_PASSWORD',
            targetType: 'auth',
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {}
    }
    return success;
  }

  Future<void> requestPasswordReset(String email) {
    return _authRepo.requestPasswordReset(
      email,
      redirectTo: _passwordResetRedirectUrl(),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _authRepo.updatePassword(newPassword);
    _isPasswordRecovery = false;
    notifyListeners();
  }

  String _passwordResetRedirectUrl() {
    if (kIsWeb) return '${Uri.base.origin}/reset-password';
    return 'beverageims://reset-password';
  }

  Future<bool> registerStaff(String name, String email, String password) async {
    if (_currentUser == null || !isAdmin) return false;
    try {
      await _authRepo.registerUser(name, email, password, 'staff');
      await _auditRepo.addLog(
        AuditLog(
          userId: _currentUser!.id,
          userName: _currentUser!.name,
          action: 'REGISTER_STAFF',
          targetType: 'auth',
          details: {'staff_name': name, 'staff_email': email},
          timestamp: DateTime.now(),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUserName(String name) async {
    if (_currentUser == null) return false;
    try {
      await _authRepo.updateUserName(_currentUser!.id, name);
      _currentUser = _currentUser!.copyWith(name: name);
      notifyListeners();
      await _auditRepo.addLog(
        AuditLog(
          userId: _currentUser!.id,
          userName: name,
          action: 'UPDATE_NAME',
          targetType: 'auth',
          timestamp: DateTime.now(),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
