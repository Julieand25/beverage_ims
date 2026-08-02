import 'package:flutter/material.dart';
import 'models/audit_log.dart';
import 'repositories/audit_repository.dart';

class AuditProvider extends ChangeNotifier {
  final AuditRepository _repo;
  List<AuditLog> _logs = [];

  List<AuditLog> get logs => List.unmodifiable(_logs);

  AuditProvider({required AuditRepository repo}) : _repo = repo {
    loadAll();
  }

  Future<void> loadAll() async {
    _logs = await _repo.getAll();
    notifyListeners();
  }

  Future<void> addLog(AuditLog log) async {
    await _repo.addLog(log);
    _logs.insert(0, log);
    notifyListeners();
  }

  Future<List<AuditLog>> getByUser(String userId) async {
    return _repo.getByUser(userId);
  }
}
