class TelemetryModel {
  final double ingressLatencyMs;
  final int ingressClassId;
  final double llmLatencyMs;
  final double egressLatencyMs;
  final int egressClassId;
  final double barrierOverheadMs;
  final double totalLatencyMs;

  TelemetryModel({
    this.ingressLatencyMs = 0.0,
    this.ingressClassId = 0,
    this.llmLatencyMs = 0.0,
    this.egressLatencyMs = 0.0,
    this.egressClassId = 0,
    this.barrierOverheadMs = 0.0,
    this.totalLatencyMs = 0.0,
  });

  factory TelemetryModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return TelemetryModel();
    return TelemetryModel(
      ingressLatencyMs: (map['ingress_latency_ms'] as num?)?.toDouble() ?? 0.0,
      ingressClassId: map['ingress_class_id'] as int? ?? 0,
      llmLatencyMs: (map['llm_latency_ms'] as num?)?.toDouble() ?? 0.0,
      egressLatencyMs: (map['egress_latency_ms'] as num?)?.toDouble() ?? 0.0,
      egressClassId: map['egress_class_id'] as int? ?? 0,
      barrierOverheadMs: (map['barrier_overhead_ms'] as num?)?.toDouble() ?? 0.0,
      totalLatencyMs: (map['total_latency_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingress_latency_ms': ingressLatencyMs,
      'ingress_class_id': ingressClassId,
      'llm_latency_ms': llmLatencyMs,
      'egress_latency_ms': egressLatencyMs,
      'egress_class_id': egressClassId,
      'barrier_overhead_ms': barrierOverheadMs,
      'total_latency_ms': totalLatencyMs,
    };
  }

  String get ingressStatusLabel {
    switch (ingressClassId) {
      case 0:
        return 'Safe (0)';
      case 1:
        return 'General Risk (1)';
      case 2:
        return 'Critical Risk (2)';
      default:
        return 'Unknown ($ingressClassId)';
    }
  }

  String get egressStatusLabel {
    switch (egressClassId) {
      case 0:
        return 'Safe (0)';
      case 1:
        return 'General Risk (1)';
      case 2:
        return 'Critical Risk (2)';
      default:
        return 'Unknown ($egressClassId)';
    }
  }
}
