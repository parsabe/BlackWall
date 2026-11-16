import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/server_config.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  ServerConfig _config = ServerConfig();

  SettingsProvider(this._storage);

  ServerConfig get config => _config;

  Future<void> initialize() async {
    final savedEndpoint = await _storage.getString(AppConstants.endpointKey);
    final savedTimeout = await _storage.getInt(AppConstants.timeoutKey);

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
}
