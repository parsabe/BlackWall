import 'dart:async';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  UserModel? _currentUser;

  AuthService(this._storage);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!.token.isNotEmpty;

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

  Future<UserModel> login({required String email, required String password}) async {
    // Validate credentials
    await Future.delayed(const Duration(milliseconds: 600)); // Network simulation

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address format.');
    }
    if (password.length < 6) {
      throw Exception('Password must contain at least 6 characters.');
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      name: email.split('@').first,
      token: 'jwt_sec_${DateTime.now().millisecondsSinceEpoch}_blackwall',
      createdAt: DateTime.now(),
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
    await Future.delayed(const Duration(milliseconds: 700));

    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty.');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address format.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      name: name.trim(),
      token: 'jwt_sec_${DateTime.now().millisecondsSinceEpoch}_blackwall',
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storage.writeSecure(AppConstants.tokenKey, user.token);
    await _storage.setString(AppConstants.userKey, user.toJson());

    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.deleteSecure(AppConstants.tokenKey);
    await _storage.deleteSecure(AppConstants.userKey);
  }
}
