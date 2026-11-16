import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/telemetry_model.dart';

class PipelineVisualizer extends StatelessWidget {
  final TelemetryModel? telemetry;
  final bool isLoading;

  const PipelineVisualizer({
    super.key,
    this.telemetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub_outlined, color: AppTheme.primary, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'BLACKWALL DUAL-BARRIER PIPELINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.primary),
                )
              else if (telemetry != null)
                Text(
                  'Overhead: ${telemetry!.barrierOverheadMs.toStringAsFixed(1)}ms',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStage(
                  title: '1. Ingress Check',
                  sub: telemetry != null
                      ? '${telemetry!.ingressLatencyMs.toStringAsFixed(0)}ms | Class ${telemetry!.ingressClassId}'
                      : 'Port 8000',
                  color: _getIngressColor(),
                  icon: Icons.shield,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward_ios,
                    size: 12, color: AppTheme.textSecondary),
              ),
              Expanded(
                child: _buildStage(
                  title: '2. Gemma Brain',
                  sub: telemetry != null
                      ? '${telemetry!.llmLatencyMs.toStringAsFixed(0)}ms | Gemma 3 1B'
                      : 'Port 11434',
                  color: _getGemmaColor(),
                  icon: Icons.psychology,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward_ios,
                    size: 12, color: AppTheme.textSecondary),
              ),
              Expanded(
                child: _buildStage(
                  title: '3. Egress Check',
                  sub: telemetry != null
                      ? '${telemetry!.egressLatencyMs.toStringAsFixed(0)}ms | Class ${telemetry!.egressClassId}'
                      : 'Port 8000',
                  color: _getEgressColor(),
                  icon: Icons.security,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage({
    required String title,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getIngressColor() {
    if (telemetry == null) return AppTheme.textSecondary;
    if (telemetry!.ingressClassId == 0) return AppTheme.safeGreen;
    return AppTheme.criticalRed;
  }

  Color _getGemmaColor() {
    if (telemetry == null) return AppTheme.textSecondary;
    if (telemetry!.llmLatencyMs > 0) return AppTheme.primary;
    return AppTheme.textSecondary;
  }

  Color _getEgressColor() {
    if (telemetry == null) return AppTheme.textSecondary;
    if (telemetry!.egressClassId == 0 && telemetry!.egressLatencyMs > 0) {
      return AppTheme.safeGreen;
    }
    if (telemetry!.egressClassId != 0) return AppTheme.criticalRed;
    return AppTheme.textSecondary;
  }
}
