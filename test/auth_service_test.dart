import 'package:flutter_test/flutter_test.dart';
import 'package:blackwall/models/user_model.dart';
import 'package:blackwall/models/telemetry_model.dart';

void main() {
  group('UserModel Tests', () {
    test('serialization and deserialization', () {
      final user = UserModel(
        id: 'usr_123',
        email: 'agent@blackwall.sec',
        name: 'Agent',
        token: 'token_abc',
        createdAt: DateTime(2026, 1, 1),
      );

      final jsonStr = user.toJson();
      final restored = UserModel.fromJson(jsonStr);

      expect(restored.id, 'usr_123');
      expect(restored.email, 'agent@blackwall.sec');
      expect(restored.token, 'token_abc');
    });
  });

  group('TelemetryModel Tests', () {
    test('parse telemetry map properly', () {
      final data = {
        'ingress_latency_ms': 12.5,
        'ingress_class_id': 0,
        'llm_latency_ms': 850.0,
        'egress_latency_ms': 15.2,
        'egress_class_id': 0,
        'barrier_overhead_ms': 27.7,
        'total_latency_ms': 877.7,
      };

      final telemetry = TelemetryModel.fromMap(data);
      expect(telemetry.ingressLatencyMs, 12.5);
      expect(telemetry.ingressClassId, 0);
      expect(telemetry.ingressStatusLabel, 'Safe (0)');
      expect(telemetry.llmLatencyMs, 850.0);
      expect(telemetry.barrierOverheadMs, 27.7);
    });

    test('flagged risk status label', () {
      final telemetry = TelemetryModel(ingressClassId: 2, egressClassId: 1);
      expect(telemetry.ingressStatusLabel, 'Critical Risk (2)');
      expect(telemetry.egressStatusLabel, 'General Risk (1)');
    });
  });
}
