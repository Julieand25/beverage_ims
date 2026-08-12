import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart' show User;

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<bool> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  );
  Future<User?> getStoredSession();
  Future<void> requestPasswordReset(String email, {required String redirectTo});
  Future<void> updatePassword(String newPassword);
  Future<User> registerUser(
    String name,
    String email,
    String password,
    String role,
  );
  Future<List<User>> fetchAllUsers();
  Future<void> updateUserRole(String userId, String role);
  Future<void> toggleUserActive(String userId, bool isActive);
  Future<void> updateUserName(String userId, String name);
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  const SupabaseAuthRepository(this._client);

  static const _profileColumns =
      'id,name,email,role,is_active,last_open,created_at,auth_user_id';

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<User?> _profileForAuthUser(String authUserId) async {
    final response = await _client
        .from('users')
        .select(_profileColumns)
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    return response == null ? null : User.fromJson(response);
  }

  Future<User?> _activeProfileForCurrentSession() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final profile = await _profileForAuthUser(authUser.id);
    if (profile == null || !profile.isActive) {
      await _client.auth.signOut();
      return null;
    }
    return profile;
  }

  @override
  Future<User?> login(String email, String password) async {
    final AuthResponse response;
    try {
      response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on AuthException {
      return null;
    }

    if (response.user == null) return null;

    final user = await _profileForAuthUser(response.user!.id);
    if (user == null || !user.isActive) {
      await _client.auth.signOut();
      return null;
    }

    await _client
        .from('users')
        .update({'last_open': DateTime.now().toIso8601String()})
        .eq('id', user.id);

    return user;
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  @override
  Future<User?> getStoredSession() => _activeProfileForCurrentSession();

  @override
  Future<void> requestPasswordReset(
    String email, {
    required String redirectTo,
  }) {
    return _client.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: redirectTo,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<bool> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    final profile = await _client
        .from('users')
        .select('email')
        .eq('id', userId)
        .maybeSingle();
    final email = profile?['email'] as String?;
    if (email == null) return false;

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    if (response.user == null) return false;

    await updatePassword(newPassword);
    return true;
  }

  @override
  Future<User> registerUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await _client.functions.invoke(
      'create_staff_user',
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic>) {
      throw StateError('Invalid staff registration response');
    }
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<List<User>> fetchAllUsers() async {
    final response = await _client
        .from('users')
        .select(_profileColumns)
        .order('name');

    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _client.from('users').update({'role': role}).eq('id', userId);
  }

  @override
  Future<void> toggleUserActive(String userId, bool isActive) async {
    await _client
        .from('users')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  @override
  Future<void> updateUserName(String userId, String name) async {
    await _client.from('users').update({'name': name}).eq('id', userId);
  }
}
