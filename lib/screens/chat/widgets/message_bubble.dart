import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';
import '../../../widgets/status_badge.dart';
import 'telemetry_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A), // Deep Navy
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2),
            ),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'USER OPERATOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                message.text,
                style: const TextStyle(
                    fontSize: 14, color: Colors.white, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    // BlackWall Assistant Output
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getBorderColor(message.status),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, size: 14, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Text(
                        'BLACKWALL DEFENSE CORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: message.status),
                ],
              ),
            ),
            const Divider(height: 16, color: AppTheme.border),

            // Warning or Alert message if blocked or offline
            if (message.message != null && message.message!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getAlertBgColor(message.status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getAlertIcon(message.status),
                      size: 16,
                      color: _getAlertFgColor(message.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.message!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getAlertFgColor(message.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Released Vetted Response
            if (message.isReleased && message.text.isNotEmpty)
              SelectableText(
                message.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),

            // Trace Telemetry Card
            if (message.telemetry != null)
              TelemetryCard(telemetry: message.telemetry!),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'released':
        return AppTheme.safeGreen.withValues(alpha: 0.5);
      case 'blocked_ingress':
        return AppTheme.criticalRed.withValues(alpha: 0.5);
      case 'blocked_egress':
        return Colors.purpleAccent.withValues(alpha: 0.5);
      case 'offline':
        return AppTheme.warningAmber.withValues(alpha: 0.5);
      default:
        return AppTheme.border;
    }
  }

  Color _getAlertBgColor(String status) {
    switch (status) {
      case 'released':
        return AppTheme.safeGreen.withValues(alpha: 0.1);
      case 'blocked_ingress':
      case 'blocked_egress':
        return AppTheme.criticalRed.withValues(alpha: 0.12);
      case 'offline':
        return AppTheme.warningAmber.withValues(alpha: 0.12);
      default:
        return AppTheme.surfaceLight;
    }
  }

  Color _getAlertFgColor(String status) {
    switch (status) {
      case 'released':
        return AppTheme.safeGreen;
      case 'blocked_ingress':
      case 'blocked_egress':
        return AppTheme.criticalRed;
      case 'offline':
        return AppTheme.warningAmber;
      default:
        return AppTheme.textPrimary;
    }
  }

  IconData _getAlertIcon(String status) {
    switch (status) {
      case 'released':
        return Icons.check_circle_outline;
      case 'blocked_ingress':
        return Icons.security_update_warning;
      case 'blocked_egress':
        return Icons.privacy_tip_outlined;
      case 'offline':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
