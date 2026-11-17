import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/server_config.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  ServerConfig _config = ServerConfig();
  ThemeMode _themeMode = ThemeMode.light;

  SettingsProvider(this._storage);

  ServerConfig get config => _config;
  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final savedEndpoint = await _storage.getString(AppConstants.endpointKey);
    final savedTimeout = await _storage.getInt(AppConstants.timeoutKey);
    final savedTheme = await _storage.getString(AppConstants.themeModeKey);

    _themeMode = switch (savedTheme) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };

    ServerMode mode = ServerMode.remoteGateway;
    String custom = '';

    if (savedEndpoint != null) {
      if (savedEndpoint == AppConstants.defaultRemoteGateway) {
        mode = ServerMode.remoteGateway;
      } else if (savedEndpoint == AppConstants.defaultLocalGateway) {
        mode = ServerMode.localGateway;
      } else {
        mode = ServerMode.custom;
        custom = savedEndpoint;
      }
    }

    _config = ServerConfig(
      mode: mode,
      customEndpoint: custom,
      timeoutSeconds: savedTimeout ?? AppConstants.defaultTimeoutSeconds,
    );

    notifyListeners();
  }

  Future<void> updateMode(ServerMode mode, {String? customUrl}) async {
    _config = _config.copyWith(
      mode: mode,
      customEndpoint: customUrl ?? _config.customEndpoint,
    );
    await _storage.setString(AppConstants.endpointKey, _config.activeEndpoint);
    notifyListeners();
  }

  Future<void> updateTimeout(int seconds) async {
    _config = _config.copyWith(timeoutSeconds: seconds);
    await _storage.setInt(AppConstants.timeoutKey, seconds);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final serialized = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await _storage.setString(AppConstants.themeModeKey, serialized);
    notifyListeners();
  }
}
