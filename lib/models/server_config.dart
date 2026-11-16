import '../core/constants/app_constants.dart';

enum ServerMode { remoteGateway, localGateway, custom }

class ServerConfig {
  final ServerMode mode;
  final String customEndpoint;
  final int timeoutSeconds;

  ServerConfig({
    this.mode = ServerMode.remoteGateway,
    this.customEndpoint = '',
    this.timeoutSeconds = AppConstants.defaultTimeoutSeconds,
  });

  String get activeEndpoint {
    switch (mode) {
      case ServerMode.remoteGateway:
        return AppConstants.defaultRemoteGateway;
      case ServerMode.localGateway:
        return AppConstants.defaultLocalGateway;
      case ServerMode.custom:
        return customEndpoint.isNotEmpty ? customEndpoint : AppConstants.defaultRemoteGateway;
    }
  }

  ServerConfig copyWith({
    ServerMode? mode,
    String? customEndpoint,
    int? timeoutSeconds,
  }) {
    return ServerConfig(
      mode: mode ?? this.mode,
      customEndpoint: customEndpoint ?? this.customEndpoint,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }
}
