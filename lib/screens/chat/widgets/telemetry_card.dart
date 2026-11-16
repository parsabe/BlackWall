import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/telemetry_model.dart';

class TelemetryCard extends StatelessWidget {
  final TelemetryModel telemetry;

  const TelemetryCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, size: 14, color: AppTheme.primary),
              SizedBox(width: 6),
              Text(
                'BARRIER TRACE TELEMETRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _metricItem(
                label: 'Ingress Latency',
                value: '${telemetry.ingressLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.ingressStatusLabel,
                statusColor: telemetry.ingressClassId == 0
                    ? AppTheme.safeGreen
                    : AppTheme.criticalRed,
              ),
              _metricItem(
                label: 'Gemma 3 1B Inference',
                value: '${telemetry.llmLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.llmLatencyMs > 0 ? 'Executed' : 'Skipped',
                statusColor: telemetry.llmLatencyMs > 0
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
              _metricItem(
                label: 'Egress Latency',
                value: '${telemetry.egressLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.egressStatusLabel,
                statusColor: telemetry.egressClassId == 0
                    ? AppTheme.safeGreen
                    : AppTheme.criticalRed,
              ),
              _metricItem(
                label: 'Barrier Overhead',
                value: '${telemetry.barrierOverheadMs.toStringAsFixed(1)} ms',
                status: 'Dual-Barrier',
                statusColor: AppTheme.warningAmber,
              ),
              _metricItem(
                label: 'Total Latency',
                value: '${telemetry.totalLatencyMs.toStringAsFixed(1)} ms',
                status: 'End-to-End',
                statusColor: AppTheme.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem({
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
