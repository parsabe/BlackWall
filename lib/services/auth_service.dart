import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  UserModel? _currentUser;

  AuthService(this._storage);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated =>
      _currentUser != null && _currentUser!.token.isNotEmpty;

  Future<Map<String, Map<String, dynamic>>> _loadAccounts() async {
    final raw = await _storage.readSecure(AppConstants.accountsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        return decoded.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        );
      } catch (_) {}
    }

    // Seed default demo operator account on first run
    final seeded = <String, Map<String, dynamic>>{
      'operator@blackwall.sec': {
        'id': 'usr_default_operator',
        'name': 'BlackWall Operator',
        'email': 'operator@blackwall.sec',
        'password': _hashPassword('BlackWall2026!'),
        'createdAt': DateTime.now().toIso8601String(),
      },
    };
    await _saveAccounts(seeded);
    return seeded;
  }

  Future<void> _saveAccounts(Map<String, Map<String, dynamic>> accounts) async {
    await _storage.writeSecure(AppConstants.accountsKey, json.encode(accounts));
  }

  String _hashPassword(String password) {
    // Simple deterministic salted digest for local credential storage
    final bytes = utf8.encode('bw_salt_v1:$password');
    int hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return '${hash.toRadixString(16)}_${bytes.length}';
  }

  Future<bool> tryRestoreSession() async {
    try {
      final token = await _storage.readSecure(AppConstants.tokenKey);
      final userJson = await _storage.getString(AppConstants.userKey);

      if (token != null && userJson != null) {
        _currentUser = UserModel.fromJson(userJson);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<UserModel> login(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Invalid email address format.');
    }
    if (password.length < 6) {
      throw Exception('Password must contain at least 6 characters.');
    }

    final accounts = await _loadAccounts();
    final record = accounts[normalizedEmail];
    if (record == null || record['password'] != _hashPassword(password)) {
      throw Exception('Invalid email or password.');
    }

    final user = UserModel(
      id: record['id'] as String,
      email: record['email'] as String,
      name: record['name'] as String,
      token: 'jwt_sec_${DateTime.now().millisecondsSinceEpoch}_blackwall',
      createdAt: DateTime.tryParse(record['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );

    _currentUser = user;
    await _storage.writeSecure(AppConstants.tokenKey, user.token);
    await _storage.setString(AppConstants.userKey, user.toJson());

    return user;
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Invalid email address format.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    final accounts = await _loadAccounts();
    if (accounts.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    final now = DateTime.now();
    final id = 'usr_${now.millisecondsSinceEpoch}';
    accounts[normalizedEmail] = {
      'id': id,
      'name': trimmedName,
      'email': normalizedEmail,
      'password': _hashPassword(password),
      'createdAt': now.toIso8601String(),
    };
    await _saveAccounts(accounts);

    final user = UserModel(
      id: id,
      email: normalizedEmail,
      name: trimmedName,
      token: 'jwt_sec_${now.millisecondsSinceEpoch}_blackwall',
      createdAt: now,
    );

    _currentUser = user;
    await _storage.writeSecure(AppConstants.tokenKey, user.token);
    await _storage.setString(AppConstants.userKey, user.toJson());

    return user;
  }

  Future<String> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }

    final accounts = await _loadAccounts();
    if (!accounts.containsKey(normalizedEmail)) {
      throw Exception('No account found with that email address.');
    }

    final code = (100000 + Random().nextInt(900000)).toString();
    accounts[normalizedEmail]!['resetCode'] = code;
    await _saveAccounts(accounts);
    return code;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final normalizedEmail = email.trim().toLowerCase();
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters.');
    }

    final accounts = await _loadAccounts();
    final record = accounts[normalizedEmail];
    if (record == null) {
      throw Exception('Account not found.');
    }
    if (record['resetCode'] != code.trim()) {
      throw Exception('Invalid verification code.');
    }

    record['password'] = _hashPassword(newPassword);
    record.remove('resetCode');
    await _saveAccounts(accounts);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final current = _currentUser;
    if (current == null) {
      throw Exception('No active user session.');
    }

    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Invalid email address.');
    }

    final accounts = await _loadAccounts();
    final oldEmail = current.email.toLowerCase();
    if (normalizedEmail != oldEmail && accounts.containsKey(normalizedEmail)) {
      throw Exception('That email is already in use by another account.');
    }

    final existing = accounts.remove(oldEmail) ??
        {
          'id': current.id,
          'password': '',
          'createdAt': current.createdAt.toIso8601String(),
        };
    existing['name'] = trimmedName;
    existing['email'] = normalizedEmail;
    accounts[normalizedEmail] = existing;
    await _saveAccounts(accounts);

    final updated = UserModel(
      id: current.id,
      email: normalizedEmail,
      name: trimmedName,
      token: current.token,
      createdAt: current.createdAt,
    );
    _currentUser = updated;
    await _storage.setString(AppConstants.userKey, updated.toJson());
    return updated;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final current = _currentUser;
    if (current == null) {
      throw Exception('No active user session.');
    }
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters.');
    }

    final accounts = await _loadAccounts();
    final record = accounts[current.email.toLowerCase()];
    if (record == null ||
        record['password'] != _hashPassword(currentPassword)) {
      throw Exception('Current password is incorrect.');
    }

    record['password'] = _hashPassword(newPassword);
    await _saveAccounts(accounts);
  }

  Future<void> deleteAccount() async {
    final current = _currentUser;
    if (current != null) {
      final accounts = await _loadAccounts();
      accounts.remove(current.email.toLowerCase());
      await _saveAccounts(accounts);
    }
    await logout();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.deleteSecure(AppConstants.tokenKey);
    await _storage.deleteSecure(AppConstants.userKey);
  }
}
