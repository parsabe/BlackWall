import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (_) {
      // Fallback to shared_preferences if secure storage is unavailable on platform
      await init();
      await _prefs?.setString(key, value);
    }
  }

  Future<String?> readSecure(String key) async {
    try {
      final val = await _secureStorage.read(key: key);
      if (val != null) return val;
    } catch (_) {}
    await init();
    return _prefs?.getString(key);
  }

  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {}
    await init();
    await _prefs?.remove(key);
  }

  Future<void> setString(String key, String value) async {
    await init();
    await _prefs?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs?.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await init();
    await _prefs?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await init();
    return _prefs?.getInt(key);
  }
}
