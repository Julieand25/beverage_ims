import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'models/user.dart';
import 'repositories/auth_repository.dart';
import 'repositories/audit_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final AuditRepository _auditRepo;
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isLoading => _isLoading;

  AuthProvider({required AuthRepository authRepo, required AuditRepository auditRepo})
      : _authRepo = authRepo,
        _auditRepo = auditRepo {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    _currentUser = await _authRepo.getStoredSession();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await _authRepo.login(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      await _auditRepo.addLog(AuditLog(
        userId: user.id,
        userName: user.name,
        action: 'LOGIN',
        targetType: 'auth',
        details: {'email': email},
        timestamp: DateTime.now(),
      ));
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      await _auditRepo.addLog(AuditLog(
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        action: 'SIGN_OUT',
        targetType: 'auth',
        timestamp: DateTime.now(),
      ));
    }
    await _authRepo.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    final success = await _authRepo.changePassword(
      _currentUser!.id,
      currentPassword,
      newPassword,
    );
    if (success) {
      await _auditRepo.addLog(AuditLog(
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        action: 'CHANGE_PASSWORD',
        targetType: 'auth',
        timestamp: DateTime.now(),
      ));
    }
    return success;
  }

  Future<bool> registerStaff(String name, String email, String password) async {
    if (_currentUser == null || !isAdmin) return false;
    try {
      await _authRepo.registerUser(name, email, password, 'staff');
      await _auditRepo.addLog(AuditLog(
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        action: 'REGISTER_STAFF',
        targetType: 'auth',
        details: {'staff_name': name, 'staff_email': email},
        timestamp: DateTime.now(),
      ));
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
      await _auditRepo.addLog(AuditLog(
        userId: _currentUser!.id,
        userName: name,
        action: 'UPDATE_NAME',
        targetType: 'auth',
        timestamp: DateTime.now(),
      ));
      return true;
    } catch (_) {
      return false;
    }
  }
}
