import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audit_log.dart';

abstract class AuditRepository {
  Future<void> addLog(AuditLog log);
  Future<List<AuditLog>> getAll();
  Future<List<AuditLog>> getByUser(String userId);
}

class SupabaseAuditRepository implements AuditRepository {
  final SupabaseClient _client;

  const SupabaseAuditRepository(this._client);

  @override
  Future<void> addLog(AuditLog log) async {
    await _client.from('audit_logs').insert(log.toJson());
  }

  @override
  Future<List<AuditLog>> getAll() async {
    final response = await _client
        .from('audit_logs')
        .select()
        .order('timestamp', ascending: false);

    return (response as List)
        .map((j) => AuditLog.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AuditLog>> getByUser(String userId) async {
    final response = await _client
        .from('audit_logs')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);

    return (response as List)
        .map((j) => AuditLog.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
