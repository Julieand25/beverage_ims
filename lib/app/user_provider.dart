import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'models/user.dart';
import 'repositories/auth_repository.dart';
import 'repositories/audit_repository.dart';

class UserProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final AuditRepository _auditRepo;

  List<User> _users = [];
  bool _isLoaded = false;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoaded => _isLoaded;

  UserProvider({
    required this._authRepo,
    required this._auditRepo,
  });

  Future<void> loadAllUsers() async {
    _users = await _authRepo.fetchAllUsers();
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> updateUserRole(String targetUserId, String newRole, String performedById, String performedByName) async {
    try {
      await _authRepo.updateUserRole(targetUserId, newRole);
      await _auditRepo.addLog(AuditLog(
        userId: performedById,
        userName: performedByName,
        action: 'CHANGE_ROLE',
        targetType: 'user',
        targetId: targetUserId,
        details: {'new_role': newRole},
        timestamp: DateTime.now(),
      ));
      await loadAllUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleUserActive(String targetUserId, bool isActive, String performedById, String performedByName) async {
    try {
      await _authRepo.toggleUserActive(targetUserId, isActive);
      await _auditRepo.addLog(AuditLog(
        userId: performedById,
        userName: performedByName,
        action: isActive ? 'ACTIVATE_USER' : 'DEACTIVATE_USER',
        targetType: 'user',
        targetId: targetUserId,
        timestamp: DateTime.now(),
      ));
      await loadAllUsers();
      return true;
    } catch (_) {
      return false;
    }
  }
}
