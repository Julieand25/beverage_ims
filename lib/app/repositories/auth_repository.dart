import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'dart:convert';
import '../models/user.dart' show User;

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<bool> changePassword(String userId, String currentPassword, String newPassword);
  Future<User?> getStoredSession();
}

class SupabaseAuthRepository implements AuthRepository {
  static const _sessionKey = 'auth_user_id';
  final SupabaseClient _client;

  const SupabaseAuthRepository(this._client);

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Future<User?> login(String email, String password) async {
    final hash = _hashPassword(password);
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password_hash', hash)
        .maybeSingle();

    if (response == null) return null;

    final user = User.fromJson(response);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  @override
  Future<User?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    if (userId == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      await prefs.remove(_sessionKey);
      return null;
    }

    return User.fromJson(response);
  }

  @override
  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    final currentHash = _hashPassword(currentPassword);
    final user = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .eq('password_hash', currentHash)
        .maybeSingle();

    if (user == null) return false;

    final newHash = _hashPassword(newPassword);
    await _client
        .from('users')
        .update({'password_hash': newHash})
        .eq('id', userId);

    return true;
  }
}
