class AppConstants {
  static const String appName = 'BlackWall';
  static const String appTagline = 'Autonomous AI Safety Barrier & Sandbox';

  // Remote & Local Endpoints
  static const String defaultRemoteGateway = 'https://parsabe.com/projects/blackwall/sandbox';
  static const String defaultLocalClassifier = 'http://127.0.0.1:8000';
  static const String defaultLocalOllama = 'http://127.0.0.1:11434';
  static const String defaultLocalGateway = 'http://127.0.0.1:8080/sandbox';

  // Timeouts (Seconds)
  // Dual-barrier + LLM worst-case response window can reach 60-100s on CPU hosts
  static const int minTimeoutSeconds = 15;
  static const int defaultTimeoutSeconds = 90;
  static const int maxTimeoutSeconds = 180;

  // Storage Keys
  static const String tokenKey = 'blackwall_auth_token';
  static const String userKey = 'blackwall_user_data';
  static const String endpointKey = 'blackwall_endpoint_url';
  static const String timeoutKey = 'blackwall_timeout_sec';

  // Status Codes
  static const String statusReleased = 'released';
  static const String statusBlockedIngress = 'blocked_ingress';
  static const String statusBlockedEgress = 'blocked_egress';
  static const String statusOffline = 'offline';
  static const String statusPending = 'pending';
}
