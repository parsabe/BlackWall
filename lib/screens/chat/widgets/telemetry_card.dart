import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/telemetry_model.dart';

class TelemetryCard extends StatelessWidget {
  final TelemetryModel telemetry;

  const TelemetryCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surfaceSecondary = theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.dividerColor;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                'Trace Telemetry',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _metricItem(
                label: 'Ingress Latency',
                value: '${telemetry.ingressLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.ingressStatusLabel,
                statusColor: telemetry.ingressClassId == 0
                    ? AppTheme.safeGreen
                    : AppTheme.criticalRed,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
              ),
              _metricItem(
                label: 'Gemma 3 1B Inference',
                value: '${telemetry.llmLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.llmLatencyMs > 0 ? 'Executed' : 'Skipped',
                statusColor:
                    telemetry.llmLatencyMs > 0 ? primary : onSurfaceVariant,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
              ),
              _metricItem(
                label: 'Egress Latency',
                value: '${telemetry.egressLatencyMs.toStringAsFixed(1)} ms',
                status: telemetry.egressStatusLabel,
                statusColor: telemetry.egressClassId == 0
                    ? AppTheme.safeGreen
                    : AppTheme.criticalRed,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
              ),
              _metricItem(
                label: 'Barrier Overhead',
                value: '${telemetry.barrierOverheadMs.toStringAsFixed(1)} ms',
                status: 'Dual-Barrier',
                statusColor: AppTheme.warningAmber,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
              ),
              _metricItem(
                label: 'Total Latency',
                value: '${telemetry.totalLatencyMs.toStringAsFixed(1)} ms',
                status: 'End-to-End',
                statusColor: onSurface,
                onSurface: onSurface,
                onSurfaceVariant: onSurfaceVariant,
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
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
